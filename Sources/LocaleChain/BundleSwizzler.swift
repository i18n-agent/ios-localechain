import Foundation
import ObjectiveC

/// Swizzles Bundle.localizedString(forKey:value:table:) to inject
/// fallback chain resolution when a key is not found in the current locale.
enum BundleSwizzler {

    private static var _isActive = false
    private static var resolver: FallbackBundleResolver?
    private static let lock = NSLock()

    /// Thread-local key for re-entrancy guard to prevent recursive fallback lookups.
    private static let resolvingKey = "com.localechain.isResolving"

    /// Injectable locale provider for testing. Defaults to Locale.preferredLanguages.
    static var preferredLanguagesProvider: () -> [String] = { Locale.preferredLanguages }

    static var isActive: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _isActive
    }

    /// Activate swizzling with the given resolver.
    /// If already active, updates the resolver in-place without re-swizzling.
    static func activate(resolver: FallbackBundleResolver) {
        lock.lock()
        defer { lock.unlock() }

        self.resolver = resolver

        guard !_isActive else { return }

        swizzle()
        _isActive = true
    }

    /// Deactivate swizzling and release the resolver.
    static func reset() {
        lock.lock()
        defer { lock.unlock() }

        guard _isActive else { return }

        unswizzle()
        resolver = nil
        _isActive = false
    }

    /// Resolve a key through the fallback chain.
    /// Called from the swizzled method.
    static func resolveFallback(key: String, value: String?, table: String?, bundle: Bundle) -> String? {
        lock.lock()
        let currentResolver = resolver
        lock.unlock()

        guard let currentResolver else { return nil }

        // Use the user's actual preferred languages, not the bundle's negotiated locale.
        // Locale.preferredLanguages gives raw user preferences (e.g., "pt-BR")
        // even when the bundle doesn't support that locale.
        let preferredLanguages = preferredLanguagesProvider()

        for language in preferredLanguages {
            if let result = currentResolver.resolve(key: key, table: table, locale: language) {
                return result
            }
        }

        return nil
    }

    // MARK: - Private

    private static var originalIMP: IMP?

    private static func swizzle() {
        let cls: AnyClass = Bundle.self
        let selector = #selector(Bundle.localizedString(forKey:value:table:))
        guard let method = class_getInstanceMethod(cls, selector) else { return }

        originalIMP = method_getImplementation(method)

        let block: @convention(block) (Bundle, String, String?, String?) -> String = { bundle, key, value, table in
            // Call original implementation
            typealias OriginalFunc = @convention(c) (Bundle, Selector, String, String?, String?) -> String
            let original = unsafeBitCast(BundleSwizzler.originalIMP!, to: OriginalFunc.self)
            let result = original(bundle, selector, key, value, table)

            // Re-entrancy guard: skip fallback if we're already resolving.
            // Each thread has its own flag via threadDictionary, so concurrent
            // lookups on different threads are independent.
            if Thread.current.threadDictionary[BundleSwizzler.resolvingKey] as? Bool == true {
                return result
            }

            // Detect if the key was not found:
            // - value is nil/empty: localizedString returns key on miss
            // - value is non-nil/non-empty: localizedString returns value on miss
            let keyNotFound: Bool
            if let value = value, !value.isEmpty {
                keyNotFound = (result == value)
            } else {
                keyNotFound = (result == key)
            }

            if keyNotFound {
                Thread.current.threadDictionary[BundleSwizzler.resolvingKey] = true
                defer { Thread.current.threadDictionary[BundleSwizzler.resolvingKey] = false }

                if let fallback = BundleSwizzler.resolveFallback(
                    key: key, value: value, table: table, bundle: bundle
                ) {
                    return fallback
                }
            }

            return result
        }

        let imp = imp_implementationWithBlock(block as Any)
        method_setImplementation(method, imp)
    }

    private static func unswizzle() {
        guard let originalIMP else { return }
        let cls: AnyClass = Bundle.self
        let selector = #selector(Bundle.localizedString(forKey:value:table:))
        guard let method = class_getInstanceMethod(cls, selector) else { return }
        method_setImplementation(method, originalIMP)
        self.originalIMP = nil
    }
}

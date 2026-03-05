import Foundation
import ObjectiveC

/// Swizzles Bundle.localizedString(forKey:value:table:) to inject
/// fallback chain resolution when a key is not found in the current locale.
enum BundleSwizzler {

    private static var _isActive = false
    private static var resolver: FallbackBundleResolver?
    private static let lock = NSLock()

    static var isActive: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _isActive
    }

    /// Activate swizzling with the given resolver. Safe to call multiple times.
    static func activate(resolver: FallbackBundleResolver) {
        lock.lock()
        defer { lock.unlock() }

        guard !_isActive else { return }

        self.resolver = resolver
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

        // Determine current locale from the bundle's preferred localizations
        guard let currentLocale = bundle.preferredLocalizations.first else { return nil }

        return currentResolver.resolve(key: key, table: table, locale: currentLocale)
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

            // If result equals key, the string was not found — try fallback
            if result == key {
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

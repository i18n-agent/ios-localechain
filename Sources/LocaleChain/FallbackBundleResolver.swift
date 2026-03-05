import Foundation

/// Resolves localized strings by walking a fallback chain.
/// Lazily loads .lproj bundles and caches them for performance.
final class FallbackBundleResolver: @unchecked Sendable {

    private let parentBundle: Bundle
    private let fallbacks: [String: [String]]
    private let developmentLanguage: String

    /// Cache of locale identifier -> loaded Bundle (or nil if .lproj doesn't exist)
    private var bundleCache: [String: Bundle?] = [:]
    private let lock = NSLock()

    /// Number of cached bundles (for testing)
    var cachedBundleCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return bundleCache.count
    }

    init(
        parentBundle: Bundle,
        fallbacks: [String: [String]],
        developmentLanguage: String
    ) {
        self.parentBundle = parentBundle
        self.fallbacks = fallbacks
        self.developmentLanguage = developmentLanguage
    }

    /// Build the full fallback chain for a locale, appending dev language at the end.
    func fullChain(for locale: String) -> [String] {
        var chain = fallbacks[locale] ?? []
        if !chain.contains(developmentLanguage) {
            chain.append(developmentLanguage)
        }
        return chain
    }

    /// Attempt to resolve a key by walking the fallback chain.
    /// Returns the localized string, or nil if not found in any fallback.
    func resolve(key: String, table: String?, locale: String) -> String? {
        let chain = fullChain(for: locale)

        for fallbackLocale in chain {
            guard let bundle = loadBundle(for: fallbackLocale) else { continue }
            let value = bundle.localizedString(forKey: key, value: nil, table: table)
            // If the value differs from the key, we found a translation
            if value != key {
                return value
            }
        }
        return nil
    }

    /// Load the .lproj bundle for a locale, using the cache.
    private func loadBundle(for locale: String) -> Bundle? {
        lock.lock()
        if let cached = bundleCache[locale] {
            lock.unlock()
            return cached
        }
        lock.unlock()

        // Try to find the .lproj directory
        let bundle = findLprojBundle(for: locale)

        lock.lock()
        bundleCache[locale] = bundle
        lock.unlock()

        return bundle
    }

    /// Search for a .lproj bundle in the parent bundle.
    private func findLprojBundle(for locale: String) -> Bundle? {
        // Try exact match first
        if let path = parentBundle.path(forResource: locale, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }

        // Try with underscore variant (pt_BR vs pt-BR)
        let underscored = locale.replacingOccurrences(of: "-", with: "_")
        if underscored != locale,
           let path = parentBundle.path(forResource: underscored, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }

        // SPM may nest resources inside a Resources/ subdirectory
        if let resourcePath = parentBundle.resourcePath {
            let resourcesDir = (resourcePath as NSString).appendingPathComponent("Resources")
            let lprojPath = (resourcesDir as NSString).appendingPathComponent("\(locale).lproj")
            if FileManager.default.fileExists(atPath: lprojPath),
               let bundle = Bundle(path: lprojPath) {
                return bundle
            }

            // Try underscore variant in Resources/ subdirectory
            if underscored != locale {
                let underscoredPath = (resourcesDir as NSString).appendingPathComponent("\(underscored).lproj")
                if FileManager.default.fileExists(atPath: underscoredPath),
                   let bundle = Bundle(path: underscoredPath) {
                    return bundle
                }
            }
        }

        return nil
    }
}

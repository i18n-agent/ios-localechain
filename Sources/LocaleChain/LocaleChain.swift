import Foundation

/// iOS locale fallback chain library.
/// Fixes iOS's default behavior of skipping linguistically-related locales.
public enum LocaleChain {

    /// Library version.
    public static let version = "0.1.0"

    /// Configure LocaleChain with default fallback chains.
    /// Call once at app launch (e.g., in AppDelegate or @main App init).
    ///
    /// - Parameter bundle: The bundle to resolve localizations from. Defaults to `.main`.
    public static func configure(bundle: Bundle = .main) {
        let devLanguage = detectDevelopmentLanguage(from: bundle)
        let resolver = FallbackBundleResolver(
            parentBundle: bundle,
            fallbacks: FallbackMap.defaultFallbacks,
            developmentLanguage: devLanguage
        )
        BundleSwizzler.activate(resolver: resolver)
    }

    /// Configure with custom overrides merged with default fallback chains.
    ///
    /// - Parameters:
    ///   - overrides: Locale fallback overrides. These replace matching defaults and add new ones.
    ///   - bundle: The bundle to resolve localizations from. Defaults to `.main`.
    public static func configure(
        overrides: [String: [String]],
        bundle: Bundle = .main
    ) {
        let devLanguage = detectDevelopmentLanguage(from: bundle)
        let merged = FallbackMap.merge(
            defaults: FallbackMap.defaultFallbacks,
            overrides: overrides
        )
        let resolver = FallbackBundleResolver(
            parentBundle: bundle,
            fallbacks: merged,
            developmentLanguage: devLanguage
        )
        BundleSwizzler.activate(resolver: resolver)
    }

    /// Configure with fully custom fallback chains.
    ///
    /// - Parameters:
    ///   - fallbacks: Complete fallback chain map.
    ///   - mergeDefaults: If true, merges with built-in defaults. If false, uses only provided chains.
    ///   - bundle: The bundle to resolve localizations from. Defaults to `.main`.
    public static func configure(
        fallbacks: [String: [String]],
        mergeDefaults: Bool,
        bundle: Bundle = .main
    ) {
        let devLanguage = detectDevelopmentLanguage(from: bundle)
        let effectiveFallbacks = mergeDefaults
            ? FallbackMap.merge(defaults: FallbackMap.defaultFallbacks, overrides: fallbacks)
            : fallbacks
        let resolver = FallbackBundleResolver(
            parentBundle: bundle,
            fallbacks: effectiveFallbacks,
            developmentLanguage: devLanguage
        )
        BundleSwizzler.activate(resolver: resolver)
    }

    /// Deactivate LocaleChain and restore original Bundle behavior.
    public static func reset() {
        BundleSwizzler.reset()
    }

    // MARK: - Private

    private static func detectDevelopmentLanguage(from bundle: Bundle) -> String {
        if let region = bundle.infoDictionary?["CFBundleDevelopmentRegion"] as? String {
            return region
        }
        return bundle.developmentLocalization ?? "en"
    }
}

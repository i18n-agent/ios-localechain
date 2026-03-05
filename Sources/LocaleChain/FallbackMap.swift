import Foundation

/// Comprehensive default locale fallback chains.
/// Maps regional locale identifiers to ordered fallback lists.
public enum FallbackMap {

    /// Built-in fallback chains covering common regional variants.
    /// The development language is NOT included here — it is appended
    /// automatically by the resolver at runtime.
    public static let defaultFallbacks: [String: [String]] = [
        // Portuguese
        "pt-BR": ["pt-PT", "pt"],
        "pt-PT": ["pt"],

        // Spanish (Latin America uses es-419 as intermediate)
        "es-419": ["es"],
        "es-MX": ["es-419", "es"],
        "es-AR": ["es-419", "es"],
        "es-CO": ["es-419", "es"],
        "es-CL": ["es-419", "es"],
        "es-PE": ["es-419", "es"],
        "es-VE": ["es-419", "es"],
        "es-EC": ["es-419", "es"],
        "es-GT": ["es-419", "es"],
        "es-CU": ["es-419", "es"],
        "es-BO": ["es-419", "es"],
        "es-DO": ["es-419", "es"],
        "es-HN": ["es-419", "es"],
        "es-PY": ["es-419", "es"],
        "es-SV": ["es-419", "es"],
        "es-NI": ["es-419", "es"],
        "es-CR": ["es-419", "es"],
        "es-PA": ["es-419", "es"],
        "es-UY": ["es-419", "es"],
        "es-PR": ["es-419", "es"],

        // French
        "fr-CA": ["fr"],
        "fr-BE": ["fr"],
        "fr-CH": ["fr"],
        "fr-LU": ["fr"],
        "fr-MC": ["fr"],
        "fr-SN": ["fr"],
        "fr-CI": ["fr"],
        "fr-ML": ["fr"],
        "fr-CM": ["fr"],
        "fr-MG": ["fr"],
        "fr-CD": ["fr"],

        // German
        "de-AT": ["de"],
        "de-CH": ["de"],
        "de-LU": ["de"],
        "de-LI": ["de"],

        // Italian
        "it-CH": ["it"],

        // Dutch
        "nl-BE": ["nl"],

        // Norwegian
        "nb": ["no"],
        "nn": ["nb", "no"],

        // Malay
        "ms-MY": ["ms"],
        "ms-SG": ["ms"],
        "ms-BN": ["ms"],
    ]

    /// Merge default fallbacks with user-provided overrides.
    /// Overrides replace the default chain for a given locale.
    /// New locales in overrides are added to the result.
    public static func merge(
        defaults: [String: [String]],
        overrides: [String: [String]]
    ) -> [String: [String]] {
        var result = defaults
        for (locale, chain) in overrides {
            result[locale] = chain
        }
        return result
    }
}

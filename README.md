# LocaleChain

Smart locale fallback chains for iOS — because pt-BR users deserve pt-PT, not English.

## The Problem

iOS's `NSBundle` falls back directly to the development language when a regional locale variant is missing. There is no intermediate fallback.

**Example:** A user's device is set to `pt-BR`. Your app has `pt-PT` translations but no `pt-BR` bundle. iOS skips `pt-PT` entirely and shows English (or whatever your development language is).

The same thing happens with `es-MX` -> `es`, `fr-CA` -> `fr`, `de-AT` -> `de`, and every other regional variant.

Your users see English when a perfectly good translation exists in a sibling locale.

## The Solution

One-line setup. Zero changes to your existing localization code.

LocaleChain intercepts `Bundle.localizedString(forKey:value:table:)` and walks a configurable fallback chain before giving up and returning the development language. It works with everything that uses `Bundle` under the hood:

- `NSLocalizedString("key", comment: "")`
- SwiftUI `Text("key")`
- Storyboard and XIB localization
- `.stringsdict` pluralization files

## Installation

**Swift Package Manager** (only supported method).

### Xcode

File > Add Package Dependencies > Enter:

```
https://github.com/i18n-agent/ios-localechain.git
```

### Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/i18n-agent/ios-localechain.git", from: "0.1.0")
]
```

Then add `"LocaleChain"` to your target's dependencies.

## Quick Start

```swift
import LocaleChain

// In AppDelegate or @main App init
LocaleChain.configure()  // That's it!
```

All default fallback chains are active. A `pt-BR` user will now see `pt-PT` translations when `pt-BR` is not available.

## Custom Configuration

### Default (zero config)

```swift
LocaleChain.configure()
```

Uses all built-in fallback chains. Covers Portuguese, Spanish, French, German, Italian, Dutch, Norwegian, and Malay regional variants.

### With overrides (merge with defaults)

```swift
// Override specific chains while keeping all defaults
LocaleChain.configure(
    overrides: ["pt-BR": ["pt-PT", "pt"]]
)
```

Your overrides replace matching keys in the default map. All other defaults remain.

### Full custom (replace defaults)

```swift
// Full control — only use your chains
LocaleChain.configure(
    fallbacks: [
        "pt-BR": ["pt-PT", "pt"],
        "es-MX": ["es-419", "es"]
    ],
    mergeDefaults: false
)
```

Only the chains you specify will be active. No defaults.

## Default Fallback Map

### Portuguese

| Locale | Fallback Chain |
|--------|---------------|
| pt-BR | pt-PT -> pt -> (dev language) |
| pt-PT | pt -> (dev language) |

### Spanish

| Locale | Fallback Chain |
|--------|---------------|
| es-419 | es -> (dev language) |
| es-MX | es-419 -> es -> (dev language) |
| es-AR | es-419 -> es -> (dev language) |
| es-CO | es-419 -> es -> (dev language) |
| es-CL | es-419 -> es -> (dev language) |
| es-PE | es-419 -> es -> (dev language) |
| es-VE | es-419 -> es -> (dev language) |
| es-EC | es-419 -> es -> (dev language) |
| es-GT | es-419 -> es -> (dev language) |
| es-CU | es-419 -> es -> (dev language) |
| es-BO | es-419 -> es -> (dev language) |
| es-DO | es-419 -> es -> (dev language) |
| es-HN | es-419 -> es -> (dev language) |
| es-PY | es-419 -> es -> (dev language) |
| es-SV | es-419 -> es -> (dev language) |
| es-NI | es-419 -> es -> (dev language) |
| es-CR | es-419 -> es -> (dev language) |
| es-PA | es-419 -> es -> (dev language) |
| es-UY | es-419 -> es -> (dev language) |
| es-PR | es-419 -> es -> (dev language) |

### French

| Locale | Fallback Chain |
|--------|---------------|
| fr-CA | fr -> (dev language) |
| fr-BE | fr -> (dev language) |
| fr-CH | fr -> (dev language) |
| fr-LU | fr -> (dev language) |
| fr-MC | fr -> (dev language) |
| fr-SN | fr -> (dev language) |
| fr-CI | fr -> (dev language) |
| fr-ML | fr -> (dev language) |
| fr-CM | fr -> (dev language) |
| fr-MG | fr -> (dev language) |
| fr-CD | fr -> (dev language) |

### German

| Locale | Fallback Chain |
|--------|---------------|
| de-AT | de -> (dev language) |
| de-CH | de -> (dev language) |
| de-LU | de -> (dev language) |
| de-LI | de -> (dev language) |

### Italian

| Locale | Fallback Chain |
|--------|---------------|
| it-CH | it -> (dev language) |

### Dutch

| Locale | Fallback Chain |
|--------|---------------|
| nl-BE | nl -> (dev language) |

### Norwegian

| Locale | Fallback Chain |
|--------|---------------|
| nb | no -> (dev language) |
| nn | nb -> no -> (dev language) |

### Malay

| Locale | Fallback Chain |
|--------|---------------|
| ms-MY | ms -> (dev language) |
| ms-SG | ms -> (dev language) |
| ms-BN | ms -> (dev language) |

## How It Works

1. `configure()` swizzles `Bundle.localizedString(forKey:value:table:)` with a custom implementation.
2. When a key is not found in the current locale's bundle, LocaleChain walks the fallback chain in order.
3. Each fallback `.lproj` bundle is loaded lazily on first access and cached for subsequent lookups.
4. The development language is auto-detected from `CFBundleDevelopmentRegion` in your app's Info.plist.
5. All shared state is protected by `NSLock` for thread safety.

## FAQ

**Is this App Store safe?**
Yes. Method swizzling is widely used in production iOS apps. Firebase, Crashlytics, and most analytics SDKs use the same technique. Apple has never rejected apps for swizzling `Bundle` methods.

**Performance impact?**
Negligible. Fallback bundles are loaded lazily and cached. The fallback path only triggers on cache misses — when the primary locale genuinely does not have a translation for a given key.

**SwiftUI compatibility?**
Yes. SwiftUI's `Text("key")` calls `Bundle.localizedString` internally, so it works automatically with zero additional setup.

**What about .stringsdict?**
Works with `.stringsdict` files too. Pluralization lookups go through the same `Bundle.localizedString` path.

**Can I deactivate it?**
Yes. Call `LocaleChain.reset()` to restore original `Bundle` behavior.

**Minimum iOS version?**
iOS 13+.

## Contributing

- Open issues for bugs or feature requests.
- PRs welcome, especially for adding new locale fallback chains.
- Run `swift test` before submitting.

## License

MIT License - see [LICENSE](LICENSE) file.

Built by [i18nagent.ai](https://i18nagent.ai)

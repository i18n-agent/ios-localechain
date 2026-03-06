import XCTest
@testable import LocaleChain

final class BundleSwizzlerTests: XCTestCase {

    override func tearDown() {
        BundleSwizzler.reset()
        BundleSwizzler.preferredLanguagesProvider = { Locale.preferredLanguages }
        super.tearDown()
    }

    // MARK: - Lifecycle

    func testSwizzleOnlyOnce() {
        let resolver = FallbackBundleResolver(
            parentBundle: Bundle.module,
            fallbacks: FallbackMap.defaultFallbacks,
            developmentLanguage: "en"
        )
        BundleSwizzler.activate(resolver: resolver)
        BundleSwizzler.activate(resolver: resolver) // second call updates resolver, no re-swizzle
        XCTAssertTrue(BundleSwizzler.isActive)
    }

    func testResetDeactivatesSwizzling() {
        let resolver = FallbackBundleResolver(
            parentBundle: Bundle.module,
            fallbacks: FallbackMap.defaultFallbacks,
            developmentLanguage: "en"
        )
        BundleSwizzler.activate(resolver: resolver)
        BundleSwizzler.reset()
        XCTAssertFalse(BundleSwizzler.isActive)
    }

    func testIsActiveReflectsState() {
        XCTAssertFalse(BundleSwizzler.isActive)
        let resolver = FallbackBundleResolver(
            parentBundle: Bundle.module,
            fallbacks: FallbackMap.defaultFallbacks,
            developmentLanguage: "en"
        )
        BundleSwizzler.activate(resolver: resolver)
        XCTAssertTrue(BundleSwizzler.isActive)
    }

    // MARK: - Reconfiguration

    func testReconfigurationUpdatesResolver() {
        // First config: pt-BR falls back to pt only (no pt-PT)
        let resolver1 = FallbackBundleResolver(
            parentBundle: Bundle.module,
            fallbacks: ["pt-BR": ["pt"]],
            developmentLanguage: "en"
        )
        BundleSwizzler.activate(resolver: resolver1)
        BundleSwizzler.preferredLanguagesProvider = { ["pt-BR"] }

        // With resolver1, "greeting" for pt-BR walks: pt -> en
        // pt.lproj has "greeting" = "Ola (pt)"
        let result1 = BundleSwizzler.resolveFallback(
            key: "greeting", value: nil, table: nil, bundle: Bundle.module
        )
        XCTAssertEqual(result1, "Ola (pt)")

        // Second config: pt-BR falls back to pt-PT then pt (default chain)
        let resolver2 = FallbackBundleResolver(
            parentBundle: Bundle.module,
            fallbacks: FallbackMap.defaultFallbacks,
            developmentLanguage: "en"
        )
        BundleSwizzler.activate(resolver: resolver2)

        // With resolver2, "greeting" for pt-BR walks: pt-PT -> pt -> en
        // pt-PT.lproj has "greeting" = "Ola (pt-PT)"
        let result2 = BundleSwizzler.resolveFallback(
            key: "greeting", value: nil, table: nil, bundle: Bundle.module
        )
        XCTAssertEqual(result2, "Ola (pt-PT)")
    }

    // MARK: - Locale detection

    func testResolveFallbackUsesPreferredLanguages() {
        let resolver = FallbackBundleResolver(
            parentBundle: Bundle.module,
            fallbacks: FallbackMap.defaultFallbacks,
            developmentLanguage: "en"
        )
        BundleSwizzler.activate(resolver: resolver)
        BundleSwizzler.preferredLanguagesProvider = { ["pt-BR"] }

        let result = BundleSwizzler.resolveFallback(
            key: "greeting", value: nil, table: nil, bundle: Bundle.module
        )
        XCTAssertEqual(result, "Ola (pt-PT)")
    }

    func testResolveFallbackTriesMultiplePreferredLanguages() {
        // Only pt-BR has a chain that reaches pt-PT
        let resolver = FallbackBundleResolver(
            parentBundle: Bundle.module,
            fallbacks: ["pt-BR": ["pt-PT", "pt"]],
            developmentLanguage: "en"
        )
        BundleSwizzler.activate(resolver: resolver)

        // ja-JP has no chain entry, so fullChain = ["en"]. en doesn't have "pt_pt_only".
        // pt-BR chain is ["pt-PT", "pt", "en"]. pt-PT has "pt_pt_only".
        BundleSwizzler.preferredLanguagesProvider = { ["ja-JP", "pt-BR"] }

        let result = BundleSwizzler.resolveFallback(
            key: "pt_pt_only", value: nil, table: nil, bundle: Bundle.module
        )
        XCTAssertEqual(result, "Apenas portugues europeu")
    }

    // MARK: - End-to-end swizzled path

    func testSwizzledLookupFallsBackThroughChain() {
        let resolver = FallbackBundleResolver(
            parentBundle: Bundle.module,
            fallbacks: FallbackMap.defaultFallbacks,
            developmentLanguage: "en"
        )
        BundleSwizzler.activate(resolver: resolver)
        BundleSwizzler.preferredLanguagesProvider = { ["pt-BR"] }

        // "pt_pt_only" exists only in pt-PT.lproj, not in en.lproj.
        // Original localizedString returns the key (miss).
        // Swizzle triggers fallback: pt-BR -> pt-PT -> pt -> en.
        // pt-PT has "pt_pt_only".
        let result = Bundle.module.localizedString(forKey: "pt_pt_only", value: nil, table: nil)
        XCTAssertEqual(result, "Apenas portugues europeu")
    }

    func testSwizzledLookupWithValueParameter() {
        let resolver = FallbackBundleResolver(
            parentBundle: Bundle.module,
            fallbacks: FallbackMap.defaultFallbacks,
            developmentLanguage: "en"
        )
        BundleSwizzler.activate(resolver: resolver)
        BundleSwizzler.preferredLanguagesProvider = { ["pt-BR"] }

        // With a non-nil value, original returns value on miss.
        // The swizzle detects result == value and triggers fallback.
        let result = Bundle.module.localizedString(
            forKey: "pt_pt_only", value: "Default Text", table: nil
        )
        XCTAssertEqual(result, "Apenas portugues europeu")
    }

    func testSwizzledLookupReturnsOriginalWhenFound() {
        let resolver = FallbackBundleResolver(
            parentBundle: Bundle.module,
            fallbacks: FallbackMap.defaultFallbacks,
            developmentLanguage: "en"
        )
        BundleSwizzler.activate(resolver: resolver)
        BundleSwizzler.preferredLanguagesProvider = { ["en"] }

        // "greeting" exists in en.lproj, so original returns "Hello" directly.
        // No fallback needed.
        let result = Bundle.module.localizedString(forKey: "greeting", value: nil, table: nil)
        XCTAssertEqual(result, "Hello")
    }

    // MARK: - Re-entrancy protection

    func testNoInfiniteRecursionOnMissingKey() {
        let resolver = FallbackBundleResolver(
            parentBundle: Bundle.module,
            fallbacks: FallbackMap.defaultFallbacks,
            developmentLanguage: "en"
        )
        BundleSwizzler.activate(resolver: resolver)
        BundleSwizzler.preferredLanguagesProvider = { ["pt-BR"] }

        // Key doesn't exist anywhere. Without re-entrancy protection this would
        // stack overflow as each fallback bundle lookup re-triggers swizzle.
        let result = Bundle.module.localizedString(
            forKey: "completely_nonexistent_key", value: nil, table: nil
        )
        XCTAssertEqual(result, "completely_nonexistent_key")
    }

    func testNoInfiniteRecursionWithCyclicCustomChain() {
        // Intentionally cyclic chain - should not stack overflow
        let resolver = FallbackBundleResolver(
            parentBundle: Bundle.module,
            fallbacks: ["en": ["fr"], "fr": ["en"]],
            developmentLanguage: "en"
        )
        BundleSwizzler.activate(resolver: resolver)
        BundleSwizzler.preferredLanguagesProvider = { ["en"] }

        let result = Bundle.module.localizedString(
            forKey: "completely_nonexistent_key", value: nil, table: nil
        )
        XCTAssertEqual(result, "completely_nonexistent_key")
    }

    // MARK: - Concurrent access

    func testConcurrentSwizzledAccess() {
        let resolver = FallbackBundleResolver(
            parentBundle: Bundle.module,
            fallbacks: FallbackMap.defaultFallbacks,
            developmentLanguage: "en"
        )
        BundleSwizzler.activate(resolver: resolver)
        BundleSwizzler.preferredLanguagesProvider = { ["pt-BR"] }

        let exp = expectation(description: "concurrent")
        exp.expectedFulfillmentCount = 100
        let queue = DispatchQueue(label: "test", attributes: .concurrent)

        for _ in 0..<100 {
            queue.async {
                let result = Bundle.module.localizedString(
                    forKey: "pt_pt_only", value: nil, table: nil
                )
                XCTAssertEqual(result, "Apenas portugues europeu")
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 10)
    }
}

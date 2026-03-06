import XCTest
@testable import LocaleChain

final class LocaleChainTests: XCTestCase {

    override func tearDown() {
        LocaleChain.reset()
        BundleSwizzler.preferredLanguagesProvider = { Locale.preferredLanguages }
        super.tearDown()
    }

    // MARK: - Configuration

    func testConfigureWithDefaults() {
        LocaleChain.configure()
        XCTAssertTrue(BundleSwizzler.isActive)
    }

    func testConfigureWithOverrides() {
        LocaleChain.configure(overrides: ["xx-YY": ["xx"]])
        XCTAssertTrue(BundleSwizzler.isActive)
    }

    func testConfigureWithCustomFallbacksNoMerge() {
        LocaleChain.configure(
            fallbacks: ["pt-BR": ["pt"]],
            mergeDefaults: false
        )
        XCTAssertTrue(BundleSwizzler.isActive)
    }

    func testResetDeactivates() {
        LocaleChain.configure()
        LocaleChain.reset()
        XCTAssertFalse(BundleSwizzler.isActive)
    }

    func testConfigureTwiceIsIdempotent() {
        LocaleChain.configure()
        LocaleChain.configure()  // should not crash
        XCTAssertTrue(BundleSwizzler.isActive)
    }

    // MARK: - Reconfiguration

    func testReconfigurationAppliesNewOverrides() {
        // First: defaults only
        LocaleChain.configure(bundle: Bundle.module)
        BundleSwizzler.preferredLanguagesProvider = { ["pt-BR"] }

        // Default chain: pt-BR -> pt-PT -> pt -> en
        // "greeting" found in pt-PT
        let result1 = BundleSwizzler.resolveFallback(
            key: "greeting", value: nil, table: nil, bundle: Bundle.module
        )
        XCTAssertEqual(result1, "Ola (pt-PT)")

        // Reconfigure: pt-BR now falls back to pt only (skipping pt-PT)
        LocaleChain.configure(
            fallbacks: ["pt-BR": ["pt"]],
            mergeDefaults: false,
            bundle: Bundle.module
        )

        // New chain: pt-BR -> pt -> en
        // "greeting" found in pt (not pt-PT)
        let result2 = BundleSwizzler.resolveFallback(
            key: "greeting", value: nil, table: nil, bundle: Bundle.module
        )
        XCTAssertEqual(result2, "Ola (pt)")
    }

    // MARK: - Version

    func testVersionIsSet() {
        XCTAssertFalse(LocaleChain.version.isEmpty)
    }
}

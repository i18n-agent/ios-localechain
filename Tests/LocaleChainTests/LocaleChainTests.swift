import XCTest
@testable import LocaleChain

final class LocaleChainTests: XCTestCase {

    override func tearDown() {
        LocaleChain.reset()
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

    // MARK: - Version

    func testVersionIsSet() {
        XCTAssertFalse(LocaleChain.version.isEmpty)
    }
}

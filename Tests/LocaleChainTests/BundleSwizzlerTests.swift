import XCTest
@testable import LocaleChain

final class BundleSwizzlerTests: XCTestCase {

    override func tearDown() {
        BundleSwizzler.reset()
        super.tearDown()
    }

    func testSwizzleOnlyOnce() {
        let resolver = FallbackBundleResolver(
            parentBundle: Bundle.module,
            fallbacks: FallbackMap.defaultFallbacks,
            developmentLanguage: "en"
        )
        BundleSwizzler.activate(resolver: resolver)
        BundleSwizzler.activate(resolver: resolver) // second call is no-op
        // No crash means it worked
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
}

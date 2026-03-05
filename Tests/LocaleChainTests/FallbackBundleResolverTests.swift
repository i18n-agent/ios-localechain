import XCTest
@testable import LocaleChain

final class FallbackBundleResolverTests: XCTestCase {

    var resolver: FallbackBundleResolver!
    var testBundle: Bundle!

    override func setUp() {
        super.setUp()
        testBundle = Bundle.module
        resolver = FallbackBundleResolver(
            parentBundle: testBundle,
            fallbacks: FallbackMap.defaultFallbacks,
            developmentLanguage: "en"
        )
    }

    override func tearDown() {
        resolver = nil
        testBundle = nil
        super.tearDown()
    }

    // MARK: - Chain building

    func testFullChainIncludesDevLanguage() {
        let chain = resolver.fullChain(for: "pt-BR")
        XCTAssertEqual(chain, ["pt-PT", "pt", "en"])
    }

    func testFullChainForUnknownLocaleOnlyHasDevLanguage() {
        let chain = resolver.fullChain(for: "xx-YY")
        XCTAssertEqual(chain, ["en"])
    }

    func testFullChainDoesNotDuplicateDevLanguage() {
        let customResolver = FallbackBundleResolver(
            parentBundle: testBundle,
            fallbacks: ["test": ["en"]],
            developmentLanguage: "en"
        )
        let chain = customResolver.fullChain(for: "test")
        XCTAssertEqual(chain, ["en"])
    }

    // MARK: - String resolution

    func testResolvesFromFallbackWhenMissing() {
        // pt-BR.lproj doesn't have "greeting", pt-PT.lproj does
        let result = resolver.resolve(key: "greeting", table: nil, locale: "pt-BR")
        XCTAssertEqual(result, "Ola (pt-PT)")
    }

    func testResolvesFromSecondFallback() {
        // pt-BR doesn't have "farewell", pt-PT doesn't either, pt does
        let result = resolver.resolve(key: "farewell", table: nil, locale: "pt-BR")
        XCTAssertEqual(result, "Adeus (pt)")
    }

    func testResolvesFromDevLanguageAsFinalFallback() {
        // pt-BR doesn't have "en_only", neither does pt-PT or pt
        let result = resolver.resolve(key: "en_only", table: nil, locale: "pt-BR")
        XCTAssertEqual(result, "English only")
    }

    func testReturnsNilWhenKeyMissingEverywhere() {
        let result = resolver.resolve(key: "nonexistent_key", table: nil, locale: "pt-BR")
        XCTAssertNil(result)
    }

    func testSpanishFallbackChain() {
        // es-MX -> es-419 -> es. es-419 has "greeting"
        let result = resolver.resolve(key: "greeting", table: nil, locale: "es-MX")
        XCTAssertEqual(result, "Hola (es-419)")
    }

    func testSpanishFallbackToBase() {
        let result = resolver.resolve(key: "es_only", table: nil, locale: "es-MX")
        XCTAssertEqual(result, "Solo espanol")
    }

    // MARK: - Caching

    func testBundleCachingWorks() {
        _ = resolver.resolve(key: "greeting", table: nil, locale: "pt-BR")
        _ = resolver.resolve(key: "farewell", table: nil, locale: "pt-BR")
        XCTAssertTrue(resolver.cachedBundleCount > 0)
    }

    // MARK: - Thread safety

    func testConcurrentAccess() {
        let expectation = expectation(description: "concurrent")
        expectation.expectedFulfillmentCount = 100
        let queue = DispatchQueue(label: "test", attributes: .concurrent)

        for _ in 0..<100 {
            queue.async {
                _ = self.resolver.resolve(key: "greeting", table: nil, locale: "pt-BR")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 10)
    }
}

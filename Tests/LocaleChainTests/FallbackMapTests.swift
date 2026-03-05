import XCTest
@testable import LocaleChain

final class FallbackMapTests: XCTestCase {

    // MARK: - Portuguese

    func testPtBRFallsBackToPtPTThenPt() {
        let chain = FallbackMap.defaultFallbacks["pt-BR"]
        XCTAssertEqual(chain, ["pt-PT", "pt"])
    }

    func testPtPTFallsBackToPt() {
        let chain = FallbackMap.defaultFallbacks["pt-PT"]
        XCTAssertEqual(chain, ["pt"])
    }

    // MARK: - Spanish

    func testEs419FallsBackToEs() {
        let chain = FallbackMap.defaultFallbacks["es-419"]
        XCTAssertEqual(chain, ["es"])
    }

    func testEsMXFallsBackToEs419ThenEs() {
        let chain = FallbackMap.defaultFallbacks["es-MX"]
        XCTAssertEqual(chain, ["es-419", "es"])
    }

    func testEsARFallsBackToEs419ThenEs() {
        let chain = FallbackMap.defaultFallbacks["es-AR"]
        XCTAssertEqual(chain, ["es-419", "es"])
    }

    func testEsCOFallsBackToEs419ThenEs() {
        let chain = FallbackMap.defaultFallbacks["es-CO"]
        XCTAssertEqual(chain, ["es-419", "es"])
    }

    func testEsCLFallsBackToEs419ThenEs() {
        let chain = FallbackMap.defaultFallbacks["es-CL"]
        XCTAssertEqual(chain, ["es-419", "es"])
    }

    // MARK: - French

    func testFrCAFallsBackToFr() {
        let chain = FallbackMap.defaultFallbacks["fr-CA"]
        XCTAssertEqual(chain, ["fr"])
    }

    func testFrBEFallsBackToFr() {
        let chain = FallbackMap.defaultFallbacks["fr-BE"]
        XCTAssertEqual(chain, ["fr"])
    }

    func testFrCHFallsBackToFr() {
        let chain = FallbackMap.defaultFallbacks["fr-CH"]
        XCTAssertEqual(chain, ["fr"])
    }

    // MARK: - German

    func testDeATFallsBackToDe() {
        let chain = FallbackMap.defaultFallbacks["de-AT"]
        XCTAssertEqual(chain, ["de"])
    }

    func testDeCHFallsBackToDe() {
        let chain = FallbackMap.defaultFallbacks["de-CH"]
        XCTAssertEqual(chain, ["de"])
    }

    // MARK: - Other

    func testItCHFallsBackToIt() {
        let chain = FallbackMap.defaultFallbacks["it-CH"]
        XCTAssertEqual(chain, ["it"])
    }

    func testNlBEFallsBackToNl() {
        let chain = FallbackMap.defaultFallbacks["nl-BE"]
        XCTAssertEqual(chain, ["nl"])
    }

    func testNbFallsBackToNo() {
        let chain = FallbackMap.defaultFallbacks["nb"]
        XCTAssertEqual(chain, ["no"])
    }

    func testNnFallsBackToNbThenNo() {
        let chain = FallbackMap.defaultFallbacks["nn"]
        XCTAssertEqual(chain, ["nb", "no"])
    }

    // MARK: - Merge behavior

    func testMergeWithOverrides() {
        let overrides = ["pt-BR": ["pt"]]
        let merged = FallbackMap.merge(defaults: FallbackMap.defaultFallbacks, overrides: overrides)
        XCTAssertEqual(merged["pt-BR"], ["pt"])
        XCTAssertEqual(merged["fr-CA"], ["fr"])
    }

    func testMergeAddsNewLocales() {
        let overrides = ["custom-XX": ["custom", "en"]]
        let merged = FallbackMap.merge(defaults: FallbackMap.defaultFallbacks, overrides: overrides)
        XCTAssertEqual(merged["custom-XX"], ["custom", "en"])
        XCTAssertNotNil(merged["pt-BR"])
    }

    // MARK: - Completeness

    func testAllChainsAreNonEmpty() {
        for (locale, chain) in FallbackMap.defaultFallbacks {
            XCTAssertFalse(chain.isEmpty, "Fallback chain for \(locale) should not be empty")
        }
    }

    func testNoCyclicFallbacks() {
        for (locale, chain) in FallbackMap.defaultFallbacks {
            XCTAssertFalse(chain.contains(locale), "Fallback chain for \(locale) must not contain itself")
        }
    }
}

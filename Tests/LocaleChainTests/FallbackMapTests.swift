import XCTest
@testable import LocaleChain

final class FallbackMapTests: XCTestCase {

    // MARK: - Chinese

    func testZhHantHKFallsBackToZhHantTWThenZhHant() {
        let chain = FallbackMap.defaultFallbacks["zh-Hant-HK"]
        XCTAssertEqual(chain, ["zh-Hant-TW", "zh-Hant"])
    }

    func testZhHantMOFallsBackToZhHantHKThenZhHantTWThenZhHant() {
        let chain = FallbackMap.defaultFallbacks["zh-Hant-MO"]
        XCTAssertEqual(chain, ["zh-Hant-HK", "zh-Hant-TW", "zh-Hant"])
    }

    func testZhHantTWFallsBackToZhHant() {
        let chain = FallbackMap.defaultFallbacks["zh-Hant-TW"]
        XCTAssertEqual(chain, ["zh-Hant"])
    }

    func testZhHansSGFallsBackToZhHans() {
        let chain = FallbackMap.defaultFallbacks["zh-Hans-SG"]
        XCTAssertEqual(chain, ["zh-Hans"])
    }

    func testZhHansMYFallsBackToZhHans() {
        let chain = FallbackMap.defaultFallbacks["zh-Hans-MY"]
        XCTAssertEqual(chain, ["zh-Hans"])
    }

    // MARK: - Portuguese

    func testPtBRFallsBackToPtPTThenPt() {
        let chain = FallbackMap.defaultFallbacks["pt-BR"]
        XCTAssertEqual(chain, ["pt-PT", "pt"])
    }

    func testPtPTFallsBackToPt() {
        let chain = FallbackMap.defaultFallbacks["pt-PT"]
        XCTAssertEqual(chain, ["pt"])
    }

    func testPtAOFallsBackToPtPTThenPt() {
        let chain = FallbackMap.defaultFallbacks["pt-AO"]
        XCTAssertEqual(chain, ["pt-PT", "pt"])
    }

    func testPtMZFallsBackToPtPTThenPt() {
        let chain = FallbackMap.defaultFallbacks["pt-MZ"]
        XCTAssertEqual(chain, ["pt-PT", "pt"])
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

    // MARK: - English

    func testEnGBFallsBackToEn() {
        let chain = FallbackMap.defaultFallbacks["en-GB"]
        XCTAssertEqual(chain, ["en"])
    }

    func testEnAUFallsBackToEnGBThenEn() {
        let chain = FallbackMap.defaultFallbacks["en-AU"]
        XCTAssertEqual(chain, ["en-GB", "en"])
    }

    func testEnNZFallsBackToEnAUThenEnGBThenEn() {
        let chain = FallbackMap.defaultFallbacks["en-NZ"]
        XCTAssertEqual(chain, ["en-AU", "en-GB", "en"])
    }

    func testEnINFallsBackToEnGBThenEn() {
        let chain = FallbackMap.defaultFallbacks["en-IN"]
        XCTAssertEqual(chain, ["en-GB", "en"])
    }

    func testEnCAFallsBackToEn() {
        let chain = FallbackMap.defaultFallbacks["en-CA"]
        XCTAssertEqual(chain, ["en"])
    }

    func testEnZAFallsBackToEnGBThenEn() {
        let chain = FallbackMap.defaultFallbacks["en-ZA"]
        XCTAssertEqual(chain, ["en-GB", "en"])
    }

    func testEnIEFallsBackToEnGBThenEn() {
        let chain = FallbackMap.defaultFallbacks["en-IE"]
        XCTAssertEqual(chain, ["en-GB", "en"])
    }

    func testEnSGFallsBackToEnGBThenEn() {
        let chain = FallbackMap.defaultFallbacks["en-SG"]
        XCTAssertEqual(chain, ["en-GB", "en"])
    }

    // MARK: - Arabic

    func testArSAFallsBackToAr() {
        let chain = FallbackMap.defaultFallbacks["ar-SA"]
        XCTAssertEqual(chain, ["ar"])
    }

    func testArEGFallsBackToAr() {
        let chain = FallbackMap.defaultFallbacks["ar-EG"]
        XCTAssertEqual(chain, ["ar"])
    }

    func testArAEFallsBackToAr() {
        let chain = FallbackMap.defaultFallbacks["ar-AE"]
        XCTAssertEqual(chain, ["ar"])
    }

    func testArMAFallsBackToAr() {
        let chain = FallbackMap.defaultFallbacks["ar-MA"]
        XCTAssertEqual(chain, ["ar"])
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

    func testNoTransitiveCycles() {
        // Verify no chain A -> B -> A cycles exist in the default map
        let fallbacks = FallbackMap.defaultFallbacks
        for (locale, chain) in fallbacks {
            for target in chain {
                if let targetChain = fallbacks[target] {
                    XCTAssertFalse(
                        targetChain.contains(locale),
                        "Transitive cycle detected: \(locale) -> \(target) -> \(locale)"
                    )
                }
            }
        }
    }
}

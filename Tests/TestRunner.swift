import Foundation

@main
struct TestRunner {
    static func main() {
        print("\u{001B}[1;35m")
        print("╔══════════════════════════════════════╗")
        print("║  DoubleCmdTranslator Test Suite      ║")
        print("╚══════════════════════════════════════╝")
        print("\u{001B}[0m")
        
        // Run all test suites
        runTranslationItemTests()
        runVocabularyManagerTests()
        runTranslationServiceIntegrationTests()
        runTranslationProviderTests()
        
        // Print summary
        printSummary()
        
        // Exit with appropriate code
        exit(failedTests > 0 ? 1 : 0)
    }
}

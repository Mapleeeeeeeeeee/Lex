import Foundation

@main
struct TestRunner {
    static func main() {
        print("Running Lex tests...\n")
        
        runAllTests()
        
        printSummary()
        
        if failedTests > 0 {
            exit(1)
        }
    }
}

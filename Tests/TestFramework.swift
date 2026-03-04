import Foundation

/// Lightweight BDD-style test framework that works without Xcode/XCTest
/// Supports given/when/then naming convention and parameterized tests.

var totalTests = 0
var passedTests = 0
var failedTests = 0
var failedMessages: [(test: String, message: String)] = []

func describe(_ suiteName: String, _ block: () -> Void) {
    print("\n\u{001B}[1;36m📦 \(suiteName)\u{001B}[0m")
    block()
}

func it(_ testName: String, _ block: () throws -> Void) {
    totalTests += 1
    do {
        try block()
        passedTests += 1
        print("  \u{001B}[32m✅ \(testName)\u{001B}[0m")
    } catch {
        failedTests += 1
        let msg = "\(error)"
        failedMessages.append((test: testName, message: msg))
        print("  \u{001B}[31m❌ \(testName)\u{001B}[0m")
        print("     \u{001B}[31m→ \(msg)\u{001B}[0m")
    }
}

struct AssertionError: Error, CustomStringConvertible {
    let description: String
}

func assertEqual<T: Equatable>(_ a: T, _ b: T, _ message: String = "", file: String = #file, line: Int = #line) throws {
    guard a == b else {
        let detail = message.isEmpty ? "Expected '\(a)' to equal '\(b)'" : "\(message): Expected '\(a)' to equal '\(b)'"
        throw AssertionError(description: "\(detail) (line \(line))")
    }
}

func assertNotEqual<T: Equatable>(_ a: T, _ b: T, _ message: String = "", file: String = #file, line: Int = #line) throws {
    guard a != b else {
        let detail = message.isEmpty ? "Expected values to not be equal: '\(a)'" : "\(message)"
        throw AssertionError(description: "\(detail) (line \(line))")
    }
}

func assertTrue(_ value: Bool, _ message: String = "", file: String = #file, line: Int = #line) throws {
    guard value else {
        let detail = message.isEmpty ? "Expected true but got false" : message
        throw AssertionError(description: "\(detail) (line \(line))")
    }
}

func assertFalse(_ value: Bool, _ message: String = "", file: String = #file, line: Int = #line) throws {
    guard !value else {
        let detail = message.isEmpty ? "Expected false but got true" : message
        throw AssertionError(description: "\(detail) (line \(line))")
    }
}

func assertNil<T>(_ value: T?, _ message: String = "", file: String = #file, line: Int = #line) throws {
    guard value == nil else {
        let detail = message.isEmpty ? "Expected nil but got '\(value!)'" : message
        throw AssertionError(description: "\(detail) (line \(line))")
    }
}

func assertNotNil<T>(_ value: T?, _ message: String = "", file: String = #file, line: Int = #line) throws {
    guard value != nil else {
        let detail = message.isEmpty ? "Expected non-nil value" : message
        throw AssertionError(description: "\(detail) (line \(line))")
    }
}

func assertGreaterThan<T: Comparable>(_ a: T, _ b: T, _ message: String = "", file: String = #file, line: Int = #line) throws {
    guard a > b else {
        let detail = message.isEmpty ? "Expected '\(a)' > '\(b)'" : "\(message): Expected '\(a)' > '\(b)'"
        throw AssertionError(description: "\(detail) (line \(line))")
    }
}

func printSummary() {
    print("\n\u{001B}[1m══════════════════════════════════════\u{001B}[0m")
    print("\u{001B}[1m Test Results: \(passedTests)/\(totalTests) passed\u{001B}[0m")
    if failedTests > 0 {
        print("\u{001B}[31m ❌ \(failedTests) FAILED\u{001B}[0m")
        for f in failedMessages {
            print("\u{001B}[31m   • \(f.test): \(f.message)\u{001B}[0m")
        }
    } else {
        print("\u{001B}[32m ✅ ALL TESTS PASSED\u{001B}[0m")
    }
    print("\u{001B}[1m══════════════════════════════════════\u{001B}[0m\n")
}

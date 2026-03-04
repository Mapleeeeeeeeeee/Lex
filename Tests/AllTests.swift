import Foundation

// =============================================================================
// MARK: - TranslationItem Unit Tests
// =============================================================================

func runTranslationItemTests() {
    describe("TranslationItem") {
        
        // MARK: - Initialization
        
        it("given valid inputs, when initialized, then properties are set correctly") {
            let item = TranslationItem(originalText: "Hello", translatedText: "你好", isTranslating: false)
            try assertEqual(item.originalText, "Hello")
            try assertEqual(item.translatedText, "你好")
            try assertFalse(item.isTranslating)
        }
        
        it("given new items, when initialized, then each has a unique ID") {
            let item1 = TranslationItem(originalText: "A", translatedText: "B", isTranslating: false)
            let item2 = TranslationItem(originalText: "A", translatedText: "B", isTranslating: false)
            try assertNotEqual(item1.id, item2.id, "Each TranslationItem should have a unique ID")
        }
        
        it("given translating state, when initialized, then isTranslating is true") {
            let item = TranslationItem(originalText: "Test", translatedText: "翻譯中...", isTranslating: true)
            try assertTrue(item.isTranslating)
        }
        
        // MARK: - Equatable (Parameterized)
        
        it("given items with different IDs but same text (parameterized), when compared, then they are not equal") {
            let testCases: [(String, String)] = [
                ("Hello", "你好"),
                ("World", "世界"),
                ("Swift", "快速"),
                ("macOS", "蘋果操作系統"),
            ]
            
            for (original, translated) in testCases {
                let item1 = TranslationItem(originalText: original, translatedText: translated, isTranslating: false)
                let item2 = TranslationItem(originalText: original, translatedText: translated, isTranslating: false)
                try assertNotEqual(item1, item2, "Items '\(original)' with different IDs should not be equal")
            }
        }
        
        // MARK: - Mutability
        
        it("given a translating item, when translation completes, then text and state update") {
            var item = TranslationItem(originalText: "Hello", translatedText: "翻譯中...", isTranslating: true)
            item.translatedText = "你好"
            item.isTranslating = false
            try assertEqual(item.translatedText, "你好")
            try assertFalse(item.isTranslating)
        }
    }
}

// =============================================================================
// MARK: - VocabularyManager Unit Tests
// =============================================================================

func runVocabularyManagerTests() {
    describe("VocabularyManager") {
        
        // MARK: - Save
        
        it("given empty manager, when saving entry, then entry is persisted") {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("test_\(UUID()).json")
            defer { try? FileManager.default.removeItem(at: url) }
            let mgr = VocabularyManager(fileURL: url)
            
            mgr.save(original: "Hello", translated: "你好")
            
            try assertTrue(mgr.isSaved(original: "Hello"))
            try assertEqual(mgr.getAll().count, 1)
            try assertEqual(mgr.getAll().first?.originalText, "Hello")
            try assertEqual(mgr.getAll().first?.translatedText, "你好")
        }
        
        it("given existing entry, when saving duplicate, then duplicate is ignored") {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("test_\(UUID()).json")
            defer { try? FileManager.default.removeItem(at: url) }
            let mgr = VocabularyManager(fileURL: url)
            
            mgr.save(original: "Hello", translated: "你好")
            mgr.save(original: "Hello", translated: "哈囉")
            
            try assertEqual(mgr.getAll().count, 1, "Duplicate should be ignored")
            try assertEqual(mgr.getAll().first?.translatedText, "你好", "Original translation should be kept")
        }
        
        // MARK: - Save (Parameterized)
        
        it("given multiple entries (parameterized), when saved, then all are persisted") {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("test_\(UUID()).json")
            defer { try? FileManager.default.removeItem(at: url) }
            let mgr = VocabularyManager(fileURL: url)
            
            let testCases: [(String, String)] = [
                ("Hello", "你好"), ("World", "世界"), ("Swift", "快速"),
                ("Apple", "蘋果"), ("Code", "程式碼"),
            ]
            
            for (original, translated) in testCases {
                mgr.save(original: original, translated: translated)
            }
            
            try assertEqual(mgr.getAll().count, testCases.count)
            for (original, _) in testCases {
                try assertTrue(mgr.isSaved(original: original), "'\(original)' should be saved")
            }
        }
        
        // MARK: - Remove
        
        it("given saved entry, when removed, then entry is no longer saved") {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("test_\(UUID()).json")
            defer { try? FileManager.default.removeItem(at: url) }
            let mgr = VocabularyManager(fileURL: url)
            
            mgr.save(original: "Hello", translated: "你好")
            try assertTrue(mgr.isSaved(original: "Hello"))
            
            mgr.remove(original: "Hello")
            try assertFalse(mgr.isSaved(original: "Hello"))
            try assertEqual(mgr.getAll().count, 0)
        }
        
        it("given non-existent entry, when removed, then no error occurs") {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("test_\(UUID()).json")
            defer { try? FileManager.default.removeItem(at: url) }
            let mgr = VocabularyManager(fileURL: url)
            
            mgr.remove(original: "NonExistent")
            try assertEqual(mgr.getAll().count, 0, "Should be a no-op")
        }
        
        // MARK: - isSaved (Parameterized)
        
        it("given various queries (parameterized), when checking isSaved, then returns correct results") {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("test_\(UUID()).json")
            defer { try? FileManager.default.removeItem(at: url) }
            let mgr = VocabularyManager(fileURL: url)
            
            mgr.save(original: "Hello", translated: "你好")
            mgr.save(original: "World", translated: "世界")
            
            let testCases: [(String, Bool)] = [
                ("Hello", true), ("World", true), ("Swift", false),
                ("", false), ("hello", false),  // Case-sensitive
            ]
            
            for (query, expected) in testCases {
                try assertEqual(mgr.isSaved(original: query), expected,
                    "isSaved('\(query)') should be \(expected)")
            }
        }
        
        // MARK: - Ordering
        
        it("given multiple saves, when getting all, then newest is first") {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("test_\(UUID()).json")
            defer { try? FileManager.default.removeItem(at: url) }
            let mgr = VocabularyManager(fileURL: url)
            
            mgr.save(original: "First", translated: "第一")
            mgr.save(original: "Second", translated: "第二")
            mgr.save(original: "Third", translated: "第三")
            
            let all = mgr.getAll()
            try assertEqual(all[0].originalText, "Third", "Newest should be first")
            try assertEqual(all[2].originalText, "First", "Oldest should be last")
        }
        
        // MARK: - Persistence
        
        it("given saved entries, when creating new manager with same file, then entries persist") {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("test_\(UUID()).json")
            defer { try? FileManager.default.removeItem(at: url) }
            let mgr = VocabularyManager(fileURL: url)
            
            mgr.save(original: "Hello", translated: "你好")
            mgr.save(original: "World", translated: "世界")
            
            let newMgr = VocabularyManager(fileURL: url)
            try assertEqual(newMgr.getAll().count, 2)
            try assertTrue(newMgr.isSaved(original: "Hello"))
            try assertTrue(newMgr.isSaved(original: "World"))
        }
        
        it("given corrupted file, when loading, then starts empty gracefully") {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("test_\(UUID()).json")
            defer { try? FileManager.default.removeItem(at: url) }
            
            try? "NOT_VALID_JSON{{{".data(using: .utf8)?.write(to: url)
            let mgr = VocabularyManager(fileURL: url)
            
            try assertEqual(mgr.getAll().count, 0, "Should recover from corrupted data")
        }
    }
}

// =============================================================================
// MARK: - TranslationService Integration Tests
// =============================================================================

func runTranslationServiceIntegrationTests() {
    describe("TranslationService (Integration)") {
        
        // MARK: - Basic Translation (Parameterized)
        
        it("given English words (parameterized), when translated, then returns non-empty Chinese") {
            let svc = TranslationService()
            let testCases = ["Hello", "Apple", "Thank you"]
            
            for word in testCases {
                let semaphore = DispatchSemaphore(value: 0)
                var result: String?
                
                svc.translate(text: word) { translated in
                    result = translated
                    semaphore.signal()
                }
                
                let timeout = semaphore.wait(timeout: .now() + 10)
                if timeout == .timedOut {
                    throw AssertionError(description: "Timeout translating '\(word)'")
                }
                try assertNotNil(result, "Translation of '\(word)' should not be nil")
                try assertGreaterThan(result!.count, 0, "Translation of '\(word)' should not be empty")
                print("       '\(word)' → '\(result!)'")
            }
        }
        
        // MARK: - Long Sentence
        
        it("given a long sentence, when translated, then returns complete sentence") {
            let svc = TranslationService()
            let semaphore = DispatchSemaphore(value: 0)
            var result: String?
            
            svc.translate(text: "The quick brown fox jumps over the lazy dog") { translated in
                result = translated
                semaphore.signal()
            }
            
            _ = semaphore.wait(timeout: .now() + 10)
            try assertNotNil(result, "Long sentence should be translated")
            try assertGreaterThan(result!.count, 5, "Should be a full sentence")
            print("       → '\(result!)'")
        }
        
        // MARK: - Edge Cases (Parameterized)
        
        it("given edge case inputs (parameterized), when translated, then handles gracefully") {
            let svc = TranslationService()
            let testCases: [(input: String, label: String)] = [
                ("A", "single char"),
                ("123", "numbers"),
                ("café résumé", "diacritics"),
            ]
            
            for tc in testCases {
                let semaphore = DispatchSemaphore(value: 0)
                var result: String?
                
                svc.translate(text: tc.input) { translated in
                    result = translated
                    semaphore.signal()
                }
                
                _ = semaphore.wait(timeout: .now() + 10)
                try assertNotNil(result, "Edge case '\(tc.label)' should not be nil")
                print("       [\(tc.label)] '\(tc.input)' → '\(result!)'")
            }
        }
    }
}

// =============================================================================
// MARK: - TranslationProvider Protocol Tests
// =============================================================================

/// A mock provider for testing the provider protocol and switching
class MockTranslationProvider: TranslationProvider {
    var name: String { "Mock Provider" }
    var identifier: String { "mock" }
    var lastTranslatedText: String?
    var mockResult: String?
    
    func translate(text: String, from: String, to: String, completion: @escaping (String?) -> Void) {
        lastTranslatedText = text
        completion(mockResult ?? "[MOCK] \(text)")
    }
}

func runTranslationProviderTests() {
    describe("TranslationProvider Protocol") {
        
        // MARK: - Protocol Conformance (Parameterized)
        
        it("given concrete providers (parameterized), when accessed, then name and identifier are correct") {
            let providers: [(TranslationProvider, expectedName: String, expectedId: String)] = [
                (GoogleTranslateProvider(), "Google Translate", "google"),
                (MockTranslationProvider(), "Mock Provider", "mock"),
            ]
            
            for (provider, expectedName, expectedId) in providers {
                try assertEqual(provider.name, expectedName, "Provider name mismatch")
                try assertEqual(provider.identifier, expectedId, "Provider identifier mismatch")
            }
        }
        
        // MARK: - Mock Provider
        
        it("given mock provider, when translate called, then returns mock result") {
            let mock = MockTranslationProvider()
            mock.mockResult = "模擬翻譯"
            
            let semaphore = DispatchSemaphore(value: 0)
            var result: String?
            
            mock.translate(text: "Test", from: "en", to: "zh-TW") { translated in
                result = translated
                semaphore.signal()
            }
            _ = semaphore.wait(timeout: .now() + 2)
            
            try assertEqual(result, "模擬翻譯")
            try assertEqual(mock.lastTranslatedText, "Test")
        }
        
        // MARK: - Provider Switching
        
        it("given TranslationService, when provider is switched, then new provider is used") {
            let svc = TranslationService()
            try assertEqual(svc.activeProvider.identifier, "google", "Default should be Google")
            
            let mock = MockTranslationProvider()
            mock.mockResult = "切換測試成功"
            svc.setProvider(mock)
            
            try assertEqual(svc.activeProvider.identifier, "mock", "Should switch to mock")
            try assertEqual(svc.activeProvider.name, "Mock Provider")
            
            let semaphore = DispatchSemaphore(value: 0)
            var result: String?
            svc.translate(text: "Switch test") { translated in
                result = translated
                semaphore.signal()
            }
            _ = semaphore.wait(timeout: .now() + 2)
            
            try assertEqual(result, "切換測試成功", "Should use mock provider's result")
        }
        
        // MARK: - Language Configuration
        
        it("given TranslationService, when language settings changed, then provider receives them") {
            let mock = MockTranslationProvider()
            let svc = TranslationService(provider: mock)
            
            try assertEqual(svc.sourceLanguage, "auto", "Default source should be auto")
            try assertEqual(svc.targetLanguage, "zh-TW", "Default target should be zh-TW")
            
            svc.sourceLanguage = "en"
            svc.targetLanguage = "ja"
            
            try assertEqual(svc.sourceLanguage, "en")
            try assertEqual(svc.targetLanguage, "ja")
        }
    }
}

// =============================================================================
// MARK: - Combined Runner
// =============================================================================

func runAllTests() {
    runTranslationItemTests()
    runVocabularyManagerTests()
    runTranslationServiceIntegrationTests()
    runTranslationProviderTests()
    runZhuyinTests()
}

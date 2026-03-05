import Foundation
import Combine

func runTranslationLogicTests() {
    describe("TranslationViewModel Logic Refinement") {
        
        // MARK: - English to Traditional Chinese
        
        it("given English input, when translated, then shows Chinese translation and NO Zhuyin") {
            let mockProvider = MockTranslationProvider()
            mockProvider.mockResult = "蘋果"
            let svc = TranslationService(provider: mockProvider)
            let vm = TranslationViewModel(translationService: svc)
            
            // Should be synchronous now since we are on the main thread
            vm.translate(text: "Apple")
            
            try assertEqual(vm.currentItem?.translatedText, "蘋果")
            try assertEqual(vm.zhuyinText, "", "English translation should NOT have Zhuyin")
        }
        
        // MARK: - Traditional Chinese Input
        
        it("given Traditional Chinese input, when processed, then shows NO translation and only Zhuyin") {
            let mockProvider = MockTranslationProvider()
            let svc = TranslationService(provider: mockProvider)
            let vm = TranslationViewModel(translationService: svc)
            
            vm.translate(text: "蘋果")
            
            try assertEqual(vm.currentItem?.translatedText, "", "Chinese input should not have translation text")
            try assertEqual(vm.zhuyinText, "ㄆㄧㄥˊ ㄍㄨㄛˇ", "Chinese input should show Zhuyin")
        }
        
        // MARK: - Parameterized Tests
        
        it("given various inputs (parameterized), when processed, then logic follows language rules") {
            let testCases: [(input: String, expectedTranslate: String, expectedZhuyin: String)] = [
                ("Cat", "貓", ""),
                ("Hello", "你好", ""),
                ("草莓", "", "ㄘㄠˇ ㄇㄟˊ"),
                ("中鍵", "", "ㄓㄨㄥ ㄐㄧㄢˋ"),
            ]
            
            let mockProvider = MockTranslationProvider()
            let svc = TranslationService(provider: mockProvider)
            let vm = TranslationViewModel(translationService: svc)
            
            for tc in testCases {
                mockProvider.mockResult = tc.expectedTranslate
                vm.translate(text: tc.input)
                
                try assertEqual(vm.currentItem?.translatedText, tc.expectedTranslate, "Wrong translation for \(tc.input)")
                try assertEqual(vm.zhuyinText, tc.expectedZhuyin, "Wrong Zhuyin for \(tc.input)")
            }
        }
    }
}

import Foundation
import Combine
import AppKit

public class TranslationViewModel: ObservableObject {
    @Published public var currentItem: TranslationItem?
    @Published public var showPanel: Bool = false
    @Published public var isSaved: Bool = false
    @Published public var showCopiedFeedback: Bool = false
    @Published public var providerName: String = ""
    @Published public var zhuyinText: String = ""
    
    private let synthesizer = NSSpeechSynthesizer()
    private let vocabularyManager: VocabularyManager
    private let translationService: TranslationService
    
    public init(vocabularyManager: VocabularyManager = .shared, translationService: TranslationService = .shared) {
        self.vocabularyManager = vocabularyManager
        self.translationService = translationService
        self.providerName = translationService.activeProvider.name
    }
    
    public func translate(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        func updateState(_ block: @escaping () -> Void) {
            if Thread.isMainThread {
                block()
            } else {
                DispatchQueue.main.async(execute: block)
            }
        }
        
        // If input is Chinese, skip translation — show Zhuyin only
        if ZhuyinConverter.shared.containsChinese(trimmed) {
            let item = TranslationItem(
                originalText: trimmed,
                translatedText: "",
                isTranslating: false
            )
            updateState {
                self.currentItem = item
                self.showPanel = true
                self.isSaved = self.vocabularyManager.isSaved(original: trimmed)
                self.showCopiedFeedback = false
                self.zhuyinText = ZhuyinConverter.shared.getZhuyin(trimmed)
            }
            return
        }
        
        let newItem = TranslationItem(
            originalText: trimmed,
            translatedText: "翻譯中...",
            isTranslating: true
        )
        
        updateState {
            self.currentItem = newItem
            self.showPanel = true
            self.isSaved = self.vocabularyManager.isSaved(original: trimmed)
            self.showCopiedFeedback = false
            
            self.translationService.translate(text: trimmed) { [weak self] resultText in
                updateState {
                    if self?.currentItem?.id == newItem.id {
                        if let translated = resultText {
                            self?.currentItem?.translatedText = translated
                            // User requirement: English to TC should NOT show Zhuyin
                            self?.zhuyinText = ""
                        } else {
                            self?.currentItem?.translatedText = "翻譯失敗，請檢查網路連線或稍後再試。"
                            self?.zhuyinText = ""
                        }
                        self?.currentItem?.isTranslating = false
                    }
                }
            }
        }
    }
    
    public func hidePanel() {
        showPanel = false
        synthesizer.stopSpeaking()
    }
    
    // MARK: - Pronunciation
    public func speakOriginal() {
        guard let text = currentItem?.originalText else { return }
        synthesizer.stopSpeaking()
        
        let voices = NSSpeechSynthesizer.availableVoices
        if ZhuyinConverter.shared.containsChinese(text) {
            // v1.1.8 Chinese solution: Priority: zh-TW (Taiwan), Meijia (Taiwan), then other Chinese variants
            let zhVoice = voices.first { v in
                let r = v.rawValue.lowercased()
                return r.contains("zh-tw") || r.contains("zh_tw") || r.contains("meijia")
            } ?? voices.first { v in
                let r = v.rawValue.lowercased()
                return r.contains("zh-hk") || r.contains("zh_hk") || r.contains("zh-cn") || r.contains("zh_cn") || r.contains("zh-") || r.contains("zh_") || r.contains("tingting")
            }
            
            if let voice = zhVoice {
                synthesizer.setVoice(voice)
            }
        } else {
            // v1.1.5 English solution: Pick Samantha/Alex or match en_US underscore specifically to skip robotic en-US voices
            if let enVoice = voices.first(where: { v in
                let r = v.rawValue
                return r.contains("en_US") || r.contains("Samantha") || r.contains("Alex")
            }) {
                synthesizer.setVoice(enVoice)
            } else {
                synthesizer.setVoice(nil)
            }
        }
        
        synthesizer.startSpeaking(text)
    }
    
    // MARK: - Copy
    public func copyTranslation() {
        guard let text = currentItem?.translatedText, !text.isEmpty else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        showCopiedFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showCopiedFeedback = false
        }
    }
    
    // MARK: - Favorites
    public func toggleSaved() {
        guard let item = currentItem else { return }
        if isSaved {
            vocabularyManager.remove(original: item.originalText)
            isSaved = false
        } else {
            vocabularyManager.save(original: item.originalText, translated: item.translatedText)
            isSaved = true
        }
    }
}

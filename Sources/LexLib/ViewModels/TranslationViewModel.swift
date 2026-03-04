import Foundation
import Combine
import AppKit

public class TranslationViewModel: ObservableObject {
    @Published public var currentItem: TranslationItem?
    @Published public var showPanel: Bool = false
    @Published public var isSaved: Bool = false
    @Published public var showCopiedFeedback: Bool = false
    @Published public var providerName: String = ""
    
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
        
        let newItem = TranslationItem(
            originalText: trimmed,
            translatedText: "翻譯中...",
            isTranslating: true
        )
        
        DispatchQueue.main.async {
            self.currentItem = newItem
            self.showPanel = true
            self.isSaved = self.vocabularyManager.isSaved(original: trimmed)
            self.showCopiedFeedback = false
            
            self.translationService.translate(text: trimmed) { [weak self] resultText in
                DispatchQueue.main.async {
                    if self?.currentItem?.id == newItem.id {
                        if let translated = resultText {
                            self?.currentItem?.translatedText = translated
                        } else {
                            self?.currentItem?.translatedText = "翻譯失敗，請檢查網路連線或稍後再試。"
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

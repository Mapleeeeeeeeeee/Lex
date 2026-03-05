import Foundation

public struct TranslationItem: Identifiable, Equatable {
    public let id: UUID
    public var originalText: String
    public var translatedText: String
    public var phonetics: String?
    public var isTranslating: Bool
    
    public init(originalText: String, translatedText: String, phonetics: String? = nil, isTranslating: Bool) {
        self.id = UUID()
        self.originalText = originalText
        self.translatedText = translatedText
        self.phonetics = phonetics
        self.isTranslating = isTranslating
    }
}

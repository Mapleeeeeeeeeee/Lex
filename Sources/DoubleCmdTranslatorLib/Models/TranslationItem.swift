import Foundation

public struct TranslationItem: Identifiable, Equatable {
    public let id: UUID
    public var originalText: String
    public var translatedText: String
    public var isTranslating: Bool
    
    public init(originalText: String, translatedText: String, isTranslating: Bool) {
        self.id = UUID()
        self.originalText = originalText
        self.translatedText = translatedText
        self.isTranslating = isTranslating
    }
}

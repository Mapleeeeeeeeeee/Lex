import Foundation

public struct TranslationDefinition: Equatable {
    public var partOfSpeech: String
    public var translations: [String]
    public var sourceWord: String?
    
    public init(partOfSpeech: String, translations: [String], sourceWord: String? = nil) {
        self.partOfSpeech = partOfSpeech
        self.translations = translations
        self.sourceWord = sourceWord
    }
}

public struct TranslationItem: Identifiable, Equatable {
    public let id: UUID
    public var originalText: String
    public var translatedText: String
    public var phonetics: String?
    public var definitions: [TranslationDefinition]
    public var isTranslating: Bool
    
    public init(
        originalText: String,
        translatedText: String,
        phonetics: String? = nil,
        definitions: [TranslationDefinition] = [],
        isTranslating: Bool
    ) {
        self.id = UUID()
        self.originalText = originalText
        self.translatedText = translatedText
        self.phonetics = phonetics
        self.definitions = definitions
        self.isTranslating = isTranslating
    }
}

import Foundation

/// TranslationService is a provider manager that delegates translation
/// to the currently active TranslationProvider.
///
/// Usage:
/// ```swift
/// // Use default (Google Translate)
/// TranslationService.shared.translate(text: "Hello") { result in ... }
///
/// // Switch provider
/// TranslationService.shared.setProvider(MyCustomProvider())
/// ```
public class TranslationService {
    public static let shared = TranslationService()
    
    private var provider: TranslationProvider
    
    /// Source language code ("auto" for auto-detect)
    public var sourceLanguage: String = "auto"
    
    /// Target language code
    public var targetLanguage: String = "zh-TW"
    
    /// Initialize with a specific provider (defaults to Google Translate)
    public init(provider: TranslationProvider = GoogleTranslateProvider()) {
        self.provider = provider
    }
    
    /// Get the currently active provider
    public var activeProvider: TranslationProvider {
        return provider
    }
    
    /// Switch to a different translation provider
    public func setProvider(_ newProvider: TranslationProvider) {
        self.provider = newProvider
    }
    
    /// Translate text using the active provider
    public func translate(text: String, completion: @escaping (String?, String?) -> Void) {
        provider.translate(text: text, from: sourceLanguage, to: targetLanguage, completion: completion)
    }
}

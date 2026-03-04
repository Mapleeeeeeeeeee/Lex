import Foundation

/// Protocol that all translation backends must conform to.
/// Implement this protocol to add a new translation provider (e.g., DeepL, OpenAI, Ollama).
///
/// Example:
/// ```swift
/// class MyCustomProvider: TranslationProvider {
///     var name: String { "My Provider" }
///     var identifier: String { "custom" }
///     func translate(text: String, from: String, to: String, completion: @escaping (String?) -> Void) {
///         // Your translation logic here
///     }
/// }
/// ```
public protocol TranslationProvider {
    /// Human-readable name displayed in UI (e.g., "Google Translate")
    var name: String { get }
    
    /// Machine-readable identifier (e.g., "google", "deepl")
    var identifier: String { get }
    
    /// Translate text from one language to another.
    /// - Parameters:
    ///   - text: The text to translate
    ///   - from: Source language code ("auto" for auto-detect)
    ///   - to: Target language code (e.g., "zh-TW")
    ///   - completion: Callback with translated text or nil on failure
    func translate(text: String, from: String, to: String, completion: @escaping (String?) -> Void)
}

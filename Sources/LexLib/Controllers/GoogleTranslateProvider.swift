import Foundation

/// Google Translate provider using the free, unofficial API endpoint.
/// This is the default provider bundled with Lex.
public class GoogleTranslateProvider: TranslationProvider {
    
    public var name: String { "Google Translate" }
    public var identifier: String { "google" }
    
    private let baseURL = "https://translate.googleapis.com/translate_a/single"
    
    public init() {}
    
    public func translate(
        text: String,
        from sourceLanguage: String,
        to targetLanguage: String,
        completion: @escaping (String?, String?, [TranslationDefinition]) -> Void
    ) {
        request(text: text, from: sourceLanguage, to: targetLanguage) { [weak self] translated, phonetics, definitions in
            guard let self = self else { return }

            guard !definitions.contains(where: { Self.isVerb($0.partOfSpeech) }),
                  let lemma = Self.ingVerbLemmaCandidate(for: text) else {
                completion(translated, phonetics, definitions)
                return
            }

            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                self.request(text: lemma, from: sourceLanguage, to: targetLanguage) { _, _, lemmaDefinitions in
                    let verbDefinitions = lemmaDefinitions
                        .filter { Self.isVerb($0.partOfSpeech) }
                        .map { TranslationDefinition(partOfSpeech: $0.partOfSpeech, translations: $0.translations, sourceWord: lemma) }

                    completion(translated, phonetics, Self.mergedDefinitions(definitions + verbDefinitions))
                }
            }
        }
    }
    
    private func request(
        text: String,
        from sourceLanguage: String,
        to targetLanguage: String,
        completion: @escaping (String?, String?, [TranslationDefinition]) -> Void
    ) {
        guard let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(nil, nil, [])
            return
        }
        
        let urlString = "\(baseURL)?client=gtx&sl=\(sourceLanguage)&tl=\(targetLanguage)&dt=t&dt=rm&dt=bd&q=\(encodedText)"
        guard let url = URL(string: urlString) else {
            completion(nil, nil, [])
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let parsed = Self.parseResponse(data: data) else {
                completion(nil, nil, [])
                return
            }
            
            completion(parsed.translation, parsed.phonetics, parsed.definitions)
        }
        
        task.resume()
    }
    
    static func parseResponse(data: Data) -> (translation: String?, phonetics: String?, definitions: [TranslationDefinition])? {
        do {
            guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] else {
                return nil
            }
            
            var fullTranslation = ""
            var phonetics: String? = nil
            
            if let firstArray = jsonResponse.first as? [Any] {
                for item in firstArray {
                    if let itemArray = item as? [Any] {
                        // Elements with null translation/source slots often contain pronunciation at index 3.
                        if itemArray.count >= 4, itemArray[0] is NSNull, itemArray[1] is NSNull, let p = itemArray[3] as? String {
                            phonetics = p
                        } else if let translatedPart = itemArray.first as? String {
                            fullTranslation += translatedPart
                        }
                    }
                }
            }
            
            return (
                fullTranslation.isEmpty ? nil : fullTranslation,
                phonetics,
                parseDefinitions(from: jsonResponse)
            )
        } catch {
            print("[Google Translate] Parsing error: \(error)")
            return nil
        }
    }
    
    private static func parseDefinitions(from jsonResponse: [Any]) -> [TranslationDefinition] {
        guard jsonResponse.count > 1, let dictionaryArray = jsonResponse[1] as? [Any] else {
            return []
        }
        
        let definitions = dictionaryArray.compactMap { item -> TranslationDefinition? in
            guard let itemArray = item as? [Any],
                  itemArray.count >= 2,
                  let partOfSpeech = itemArray[0] as? String,
                  let rawTranslations = itemArray[1] as? [Any] else {
                return nil
            }
            
            let translations = rawTranslations.compactMap { $0 as? String }
            guard !translations.isEmpty else { return nil }
            
            return TranslationDefinition(
                partOfSpeech: partOfSpeech,
                translations: Array(translations.prefix(6))
            )
        }
        
        return mergedDefinitions(definitions)
    }
    
    static func isVerb(_ partOfSpeech: String) -> Bool {
        let lower = partOfSpeech.lowercased()
        return lower == "verb" || lower == "動詞"
    }

    static func ingVerbLemmaCandidate(for text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.range(of: #"^[A-Za-z]+ing$"#, options: .regularExpression) != nil,
              trimmed.count > 5 else {
            return nil
        }
        
        let stem = String(trimmed.lowercased().dropLast(3))
        guard stem.count >= 3 else { return nil }
        return stem
    }
    
    static func mergedDefinitions(_ definitions: [TranslationDefinition]) -> [TranslationDefinition] {
        var merged: [TranslationDefinition] = []
        
        for definition in definitions {
            if let index = merged.firstIndex(where: { $0.partOfSpeech == definition.partOfSpeech && $0.sourceWord == definition.sourceWord }) {
                let existing = Set(merged[index].translations)
                let additions = definition.translations.filter { !existing.contains($0) }
                merged[index].translations = Array((merged[index].translations + additions).prefix(6))
            } else {
                merged.append(definition)
            }
        }
        
        return merged
    }
}

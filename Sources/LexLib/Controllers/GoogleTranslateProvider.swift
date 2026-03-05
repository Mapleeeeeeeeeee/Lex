import Foundation

/// Google Translate provider using the free, unofficial API endpoint.
/// This is the default provider bundled with Lex.
public class GoogleTranslateProvider: TranslationProvider {
    
    public var name: String { "Google Translate" }
    public var identifier: String { "google" }
    
    private let baseURL = "https://translate.googleapis.com/translate_a/single"
    
    public init() {}
    
    public func translate(text: String, from sourceLanguage: String, to targetLanguage: String, completion: @escaping (String?, String?) -> Void) {
        guard let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(nil, nil)
            return
        }
        
        let urlString = "\(baseURL)?client=gtx&sl=\(sourceLanguage)&tl=\(targetLanguage)&dt=t&dt=rm&q=\(encodedText)"
        guard let url = URL(string: urlString) else {
            completion(nil, nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, nil)
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [Any],
                   let firstArray = jsonResponse.first as? [Any] {
                    var fullTranslation = ""
                    var phonetics: String? = nil
                    
                    for item in firstArray {
                        if let itemArray = item as? [Any] {
                            // Elements with >= 4 items and where the first two are nulls often contain the phonetic string at index 3
                            if itemArray.count >= 4, itemArray[0] is NSNull, itemArray[1] is NSNull, let p = itemArray[3] as? String {
                                phonetics = p
                            }
                            // Otherwise, if it's a standard translation pair
                            else if let translatedPart = itemArray.first as? String {
                                fullTranslation += translatedPart
                            }
                        }
                    }
                    completion(fullTranslation.isEmpty ? nil : fullTranslation, phonetics)
                } else {
                    completion(nil, nil)
                }
            } catch {
                print("[\(self.name)] Parsing error: \(error)")
                completion(nil, nil)
            }
        }
        
        task.resume()
    }
}

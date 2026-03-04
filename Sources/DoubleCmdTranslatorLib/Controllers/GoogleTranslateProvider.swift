import Foundation

/// Google Translate provider using the free, unofficial API endpoint.
/// This is the default provider bundled with DoubleCmdTranslator.
public class GoogleTranslateProvider: TranslationProvider {
    
    public var name: String { "Google Translate" }
    public var identifier: String { "google" }
    
    private let baseURL = "https://translate.googleapis.com/translate_a/single"
    
    public init() {}
    
    public func translate(text: String, from sourceLanguage: String, to targetLanguage: String, completion: @escaping (String?) -> Void) {
        guard let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(nil)
            return
        }
        
        let urlString = "\(baseURL)?client=gtx&sl=\(sourceLanguage)&tl=\(targetLanguage)&dt=t&q=\(encodedText)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [Any],
                   let firstArray = jsonResponse.first as? [Any] {
                    var fullTranslation = ""
                    for item in firstArray {
                        if let itemArray = item as? [Any], let translatedPart = itemArray.first as? String {
                            fullTranslation += translatedPart
                        }
                    }
                    completion(fullTranslation.isEmpty ? nil : fullTranslation)
                } else {
                    completion(nil)
                }
            } catch {
                print("[\(self.name)] Parsing error: \(error)")
                completion(nil)
            }
        }
        
        task.resume()
    }
}

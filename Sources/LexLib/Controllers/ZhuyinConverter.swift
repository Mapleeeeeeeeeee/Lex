import Foundation

/// Converts Chinese characters to Zhuyin (Bopomofo) phonetic annotations.
/// Uses the official Taiwan MOE 《國語辭典簡編本》 dictionary data.
/// Implements longest-match-first word lookup for accurate polyphone handling.
/// No fallback to Apple APIs - unknown characters return nil.
///
/// Data source: 教育部《國語辭典簡編本》, CC BY-ND 3.0 TW
public class ZhuyinConverter {
    
    public static let shared = ZhuyinConverter()
    
    /// Word/character -> Zhuyin string
    /// Multi-char words have syllables separated by full-width spaces (　)
    /// e.g. "銀行" -> "ㄧㄣˊ　ㄏㄤˊ"
    private var dictionary: [String: String] = [:]
    
    /// Maximum word length in the dictionary (for longest-match search bound)
    private var maxWordLength: Int = 1
    
    public init() {
        loadDictionary()
    }
    
    private func loadDictionary() {
        do {
            var data: Data?
            
            // 1. Standard bundle resource lookup (preferred for packaged app)
            if let bundleURL = Bundle.main.url(forResource: "moe_zhuyin", withExtension: "json") {
                data = try Data(contentsOf: bundleURL)
            }
            
            // 2. Manual path lookup (fallback for CLI or non-standard loading)
            if data == nil {
                let execURL = URL(fileURLWithPath: Bundle.main.executablePath ?? CommandLine.arguments[0])
                // Contents/MacOS/Lex -> deleting 2 levels -> Contents/
                let contentsURL = execURL.deletingLastPathComponent().deletingLastPathComponent()
                let resURL = contentsURL.appendingPathComponent("Resources/moe_zhuyin.json")
                
                if FileManager.default.fileExists(atPath: resURL.path) {
                    data = try Data(contentsOf: resURL)
                }
            }
            
            // 3. Testing / development fallback: look relative to source file
            if data == nil {
                let testResURL = URL(fileURLWithPath: #file)
                    .deletingLastPathComponent()
                    .deletingLastPathComponent()
                    .appendingPathComponent("Resources/moe_zhuyin.json")
                if FileManager.default.fileExists(atPath: testResURL.path) {
                    data = try Data(contentsOf: testResURL)
                }
            }
            
            // 4. Last resort: current working directory (e.g., during 'make test')
            if data == nil {
                let cwdURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                    .appendingPathComponent("Resources/moe_zhuyin.json")
                if FileManager.default.fileExists(atPath: cwdURL.path) {
                    data = try Data(contentsOf: cwdURL)
                }
            }
            
            if let jsonData = data {
                self.dictionary = try JSONDecoder().decode([String: String].self, from: jsonData)
                print("Successfully loaded Zhuyin dictionary with \(dictionary.count) entries.")
            } else {
                print("Critical error: Could not find moe_zhuyin.json in any location.")
            }
            
            // Calculate max word length for search optimization
            maxWordLength = dictionary.keys.reduce(1) { max($0, $1.count) }
        } catch {
            print("Error parsing moe_zhuyin.json: \(error)")
        }
    }
    
    /// Annotate a text string with Zhuyin readings using longest-match-first.
    /// Returns array of (character, zhuyin?) tuples.
    /// Characters not found in the MOE dictionary will have zhuyin = nil.
    public func annotate(_ text: String) -> [(character: String, zhuyin: String?)] {
        let chars = Array(text)
        var result: [(character: String, zhuyin: String?)] = []
        var i = 0
        
        while i < chars.count {
            let ch = chars[i]
            
            // Skip non-CJK characters
            guard let scalar = ch.unicodeScalars.first, isCJK(scalar) else {
                result.append((String(ch), nil))
                i += 1
                continue
            }
            
            // Try longest match first (up to maxWordLength characters)
            var matched = false
            let remaining = chars.count - i
            let tryLen = min(remaining, maxWordLength)
            
            for len in stride(from: tryLen, through: 2, by: -1) {
                let endIdx = i + len
                let word = String(chars[i..<endIdx])
                
                if let zhuyin = dictionary[word] {
                    // Split zhuyin by full-width space to get per-character readings
                    let syllables = zhuyin.split(separator: "　", omittingEmptySubsequences: false).map(String.init)
                    
                    // Map each character to its corresponding syllable
                    for (idx, c) in word.enumerated() {
                        let syl = idx < syllables.count ? syllables[idx] : nil
                        result.append((String(c), syl))
                    }
                    
                    i += len
                    matched = true
                    break
                }
            }
            
            if !matched {
                // Try single character lookup
                let charStr = String(ch)
                if let zhuyin = dictionary[charStr] {
                    // Disambiguation heuristic:
                    // If the original input text is a multi-character string (sentence/phrase),
                    // and we match a single character with multiple possible readings (" / "),
                    // we pick only the first one (most common) to avoid showing slashes in context.
                    if text.count > 1 && zhuyin.contains(" / ") {
                        let primary = zhuyin.components(separatedBy: " / ").first ?? zhuyin
                        result.append((charStr, primary))
                    } else {
                        result.append((charStr, zhuyin))
                    }
                } else {
                    // Not in MOE dictionary - return nil (no fallback)
                    result.append((charStr, nil))
                }
                i += 1
            }
        }
        
        return result
    }
    
    /// Get a combined Zhuyin string for the input text.
    public func getZhuyin(_ text: String) -> String {
        return annotate(text).compactMap { $0.zhuyin }.joined(separator: " ")
    }
    
    /// Check if the text contains any CJK characters.
    public func containsChinese(_ text: String) -> Bool {
        for scalar in text.unicodeScalars { if isCJK(scalar) { return true } }
        return false
    }
    
    private func isCJK(_ scalar: Unicode.Scalar) -> Bool {
        let v = scalar.value
        return (v >= 0x4E00 && v <= 0x9FFF) || (v >= 0x3400 && v <= 0x4DBF) || (v >= 0xF900 && v <= 0xFAFF)
    }
}

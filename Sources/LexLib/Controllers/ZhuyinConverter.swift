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
            // Try app bundle path first (make build)
            let execURL = URL(fileURLWithPath: Bundle.main.executablePath ?? CommandLine.arguments[0])
            let appURL = execURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            let resURL = appURL.appendingPathComponent("Resources/moe_zhuyin.json")
            
            if FileManager.default.fileExists(atPath: resURL.path) {
                let data = try Data(contentsOf: resURL)
                self.dictionary = try JSONDecoder().decode([String: String].self, from: data)
            } else {
                // Testing / development fallback: look relative to source
                let testResURL = URL(fileURLWithPath: #file)
                    .deletingLastPathComponent()
                    .deletingLastPathComponent()
                    .appendingPathComponent("Resources/moe_zhuyin.json")
                if FileManager.default.fileExists(atPath: testResURL.path) {
                    let data = try Data(contentsOf: testResURL)
                    self.dictionary = try JSONDecoder().decode([String: String].self, from: data)
                } else {
                    // Last resort: current working directory (make test copies Resources/)
                    let cwdURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                        .appendingPathComponent("Resources/moe_zhuyin.json")
                    if FileManager.default.fileExists(atPath: cwdURL.path) {
                        let data = try Data(contentsOf: cwdURL)
                        self.dictionary = try JSONDecoder().decode([String: String].self, from: data)
                    }
                }
            }
            
            // Calculate max word length for search optimization
            maxWordLength = dictionary.keys.reduce(1) { max($0, $1.count) }
        } catch {
            print("Error loading moe_zhuyin.json: \(error)")
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
                    result.append((charStr, zhuyin))
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

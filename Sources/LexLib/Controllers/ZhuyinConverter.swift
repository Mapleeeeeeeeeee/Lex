import Foundation

/// Converts Chinese characters to Zhuyin (Bopomofo) phonetic annotations.
/// Uses a JSON dictionary generated from kfcd/hyzd data + pinyin-pro for precise character readings,
/// including handling for heteronyms. Uses CFStringTokenizer as fallback.
public class ZhuyinConverter {
    
    public static let shared = ZhuyinConverter()
    
    // Character -> [Zhuyin] (Multiple readings for heteronyms)
    private var dictionary: [String: [String]] = [:]
    
    public init() {
        loadDictionary()
    }
    
    private func loadDictionary() {
        // Find zhuyin_dict.json relative to the executable path (for make build)
        // In local makefile build, the executable is inside Lex.app/Contents/MacOS/
        // We'll bundle the Resources into Lex.app/Contents/Resources/
        do {
            let execURL = URL(fileURLWithPath: Bundle.main.executablePath ?? CommandLine.arguments[0])
            let appURL = execURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            let resURL = appURL.appendingPathComponent("Resources/zhuyin_dict.json")
            
            if FileManager.default.fileExists(atPath: resURL.path) {
                let data = try Data(contentsOf: resURL)
                self.dictionary = try JSONDecoder().decode([String: [String]].self, from: data)
            } else {
                // Testing fallback
                let testResURL = URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Resources/zhuyin_dict.json")
                if FileManager.default.fileExists(atPath: testResURL.path) {
                    let data = try Data(contentsOf: testResURL)
                    self.dictionary = try JSONDecoder().decode([String: [String]].self, from: data)
                }
            }
        } catch {
            print("Error parsing zhuyin_dict.json: \(error)")
        }
    }
    
    public func annotate(_ text: String) -> [(character: String, zhuyin: String?)] {
        var result: [(character: String, zhuyin: String?)] = []
        
        let cfText = text as CFString
        let range = CFRangeMake(0, CFStringGetLength(cfText))
        let tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, cfText, range, kCFStringTokenizerUnitWord, CFLocaleCopyCurrent())
        
        var tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        var lastEnd = 0
        
        while tokenType != [] {
            let tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer)
            let start = tokenRange.location
            let length = tokenRange.length
            
            if start > lastEnd {
                let gapStart = text.index(text.startIndex, offsetBy: lastEnd)
                let gapEnd = text.index(text.startIndex, offsetBy: start)
                for ch in text[gapStart..<gapEnd] { result.append((String(ch), nil)) }
            }
            
            let tokenStart = text.index(text.startIndex, offsetBy: start)
            let tokenEnd = text.index(text.startIndex, offsetBy: start + length)
            let tokenText = String(text[tokenStart..<tokenEnd])
            
            for ch in tokenText {
                let charStr = String(ch)
                if isCJK(ch.unicodeScalars.first!) {
                    if let readings = dictionary[charStr], let firstReading = readings.first {
                        result.append((charStr, firstReading))
                    } else {
                        let cfChar = charStr as CFString
                        let charTokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, cfChar, CFRangeMake(0, CFStringGetLength(cfChar)), kCFStringTokenizerUnitWord, CFLocaleCopyCurrent())
                        let _ = CFStringTokenizerAdvanceToNextToken(charTokenizer)
                        if let latinRef = CFStringTokenizerCopyCurrentTokenAttribute(charTokenizer, kCFStringTokenizerAttributeLatinTranscription) {
                            let latin = latinRef as! CFString as String
                            result.append((charStr, latinToZhuyin(latin)))
                        } else {
                            result.append((charStr, nil))
                        }
                    }
                } else {
                    result.append((charStr, nil))
                }
            }
            
            lastEnd = start + length
            tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        }
        
        if lastEnd < text.count {
            let remaining = text.index(text.startIndex, offsetBy: lastEnd)
            for ch in text[remaining...] { result.append((String(ch), nil)) }
        }
        
        return result
    }
    
    public func getZhuyin(_ text: String) -> String {
        return annotate(text).compactMap { $0.zhuyin }.joined(separator: " ")
    }
    
    public func containsChinese(_ text: String) -> Bool {
        for scalar in text.unicodeScalars { if isCJK(scalar) { return true } }
        return false
    }
    
    private func isCJK(_ scalar: Unicode.Scalar) -> Bool {
        let v = scalar.value
        return (v >= 0x4E00 && v <= 0x9FFF) || (v >= 0x3400 && v <= 0x4DBF) || (v >= 0xF900 && v <= 0xFAFF)
    }
    
    private func latinToZhuyin(_ latin: String) -> String {
        let mutableStr = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, latin as CFString)!
        CFStringTransform(mutableStr, nil, "Latin-Bopomofo" as CFString, false)
        return mutableStr as String
    }
}

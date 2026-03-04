import Foundation

public struct VocabularyEntry: Codable, Identifiable, Equatable {
    public let id: UUID
    public let originalText: String
    public let translatedText: String
    public let savedAt: Date
    
    public init(originalText: String, translatedText: String) {
        self.id = UUID()
        self.originalText = originalText
        self.translatedText = translatedText
        self.savedAt = Date()
    }
}

public class VocabularyManager {
    public static let shared = VocabularyManager()
    
    private var entries: [VocabularyEntry] = []
    private let fileURL: URL
    
    public convenience init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("DoubleCmdTranslator")
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        let url = appDir.appendingPathComponent("vocabulary.json")
        self.init(fileURL: url)
    }
    
    /// Designated initializer — accepts a custom fileURL for testing
    public init(fileURL: URL) {
        self.fileURL = fileURL
        load()
    }
    
    public func save(original: String, translated: String) {
        if entries.contains(where: { $0.originalText == original }) { return }
        let entry = VocabularyEntry(originalText: original, translatedText: translated)
        entries.insert(entry, at: 0)
        persist()
    }
    
    public func isSaved(original: String) -> Bool {
        return entries.contains(where: { $0.originalText == original })
    }
    
    public func remove(original: String) {
        entries.removeAll(where: { $0.originalText == original })
        persist()
    }
    
    public func getAll() -> [VocabularyEntry] {
        return entries
    }
    
    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        entries = (try? JSONDecoder().decode([VocabularyEntry].self, from: data)) ?? []
    }
    
    private func persist() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomicWrite)
    }
}

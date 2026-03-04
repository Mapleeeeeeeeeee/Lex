import SwiftUI

/// ViewModel for the vocabulary list window
public class VocabularyListViewModel: ObservableObject {
    @Published public var entries: [VocabularyEntry] = []
    
    private let vocabularyManager: VocabularyManager
    
    public init(vocabularyManager: VocabularyManager = .shared) {
        self.vocabularyManager = vocabularyManager
        refresh()
    }
    
    public func refresh() {
        entries = vocabularyManager.getAll()
    }
    
    public func remove(at offsets: IndexSet) {
        for index in offsets {
            let entry = entries[index]
            vocabularyManager.remove(original: entry.originalText)
        }
        refresh()
    }
    
    public func removeEntry(_ entry: VocabularyEntry) {
        vocabularyManager.remove(original: entry.originalText)
        refresh()
    }
    
    public func copyEntry(_ entry: VocabularyEntry) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("\(entry.originalText) → \(entry.translatedText)", forType: .string)
    }
}

/// SwiftUI View for browsing saved vocabulary
public struct VocabularyListView: View {
    @ObservedObject var viewModel: VocabularyListViewModel
    
    public init(viewModel: VocabularyListViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.accentColor)
                Text("收藏詞彙")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Spacer()
                Text("\(viewModel.entries.count) 個詞彙")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
            
            if viewModel.entries.isEmpty {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "text.book.closed")
                        .font(.system(size: 36, weight: .light))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("尚未收藏任何詞彙")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    Text("翻譯時點擊書籤按鈕即可收藏")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20)
            } else {
                // Vocabulary list
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach(viewModel.entries) { entry in
                            VocabularyRow(
                                entry: entry,
                                onCopy: { viewModel.copyEntry(entry) },
                                onDelete: { viewModel.removeEntry(entry) }
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .frame(width: 420, height: 400)
        .background(
            VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
        )
        .onAppear {
            viewModel.refresh()
        }
    }
}

/// Individual row in the vocabulary list
struct VocabularyRow: View {
    let entry: VocabularyEntry
    let onCopy: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.originalText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(entry.translatedText)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if isHovered {
                HStack(spacing: 4) {
                    Button(action: onCopy) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 10))
                            .frame(width: 22, height: 22)
                    }
                    .buttonStyle(.plain)
                    .help("複製")
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 10))
                            .foregroundColor(.red.opacity(0.7))
                            .frame(width: 22, height: 22)
                    }
                    .buttonStyle(.plain)
                    .help("刪除")
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isHovered ? Color.primary.opacity(0.05) : Color.clear)
        .cornerRadius(4)
        .onHover { hovering in isHovered = hovering }
    }
}

import SwiftUI

public struct FloatingPanelView: View {
    @ObservedObject var viewModel: TranslationViewModel
    
    public init(viewModel: TranslationViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if let item = viewModel.currentItem {
                // Translation result (primary focus)
                if !item.translatedText.isEmpty {
                    HStack(alignment: .top) {
                        HStack(alignment: .top, spacing: 6) {
                            if item.isTranslating {
                                ProgressView().scaleEffect(0.6).frame(width: 14, height: 14).padding(.top, 2)
                            }
                            Text(item.translatedText)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                                .lineLimit(4).multilineTextAlignment(.leading)
                                .textSelection(.enabled)
                        }
                        Spacer(minLength: 4)
                        actionToolbar()
                    }
                    .padding(.horizontal, 14).padding(.top, 12).padding(.bottom, 4)

                    // Original text + phonetics (secondary context)
                    HStack(spacing: 4) {
                        Text(item.originalText)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .layoutPriority(1)
                            .textSelection(.enabled)
                        if let phonetics = item.phonetics, !phonetics.isEmpty {
                            Text("/\(phonetics)/")
                                .font(.system(size: 11, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary.opacity(0.6))
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 14).padding(.bottom, 8)
                } else {
                    HStack(alignment: .top) {
                        Text(item.originalText)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(4)
                            .textSelection(.enabled)
                        Spacer(minLength: 4)
                        actionToolbar()
                    }
                    .padding(.horizontal, 14).padding(.top, 12).padding(.bottom, 8)
                }

                // Part-of-speech definitions
                if !item.definitions.isEmpty {
                    Divider().padding(.horizontal, 12).opacity(0.5)

                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(item.definitions.enumerated()), id: \.offset) { _, definition in
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text(partOfSpeechAbbr(definition.partOfSpeech, sourceWord: definition.sourceWord))
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundColor(.blue.opacity(0.7))
                                    .frame(minWidth: 24, alignment: .leading)

                                Text(definition.translations.joined(separator: "、"))
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.primary.opacity(0.85))
                                    .lineLimit(2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .textSelection(.enabled)
                            }
                        }
                    }
                    .padding(.horizontal, 14).padding(.top, 8).padding(.bottom, 6)
                }

                // Zhuyin annotation (only for Chinese text)
                if !viewModel.zhuyinText.isEmpty {
                    Divider().padding(.horizontal, 12).opacity(0.5)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 5) {
                            ForEach(Array(viewModel.zhuyinText.components(separatedBy: " ").filter { !$0.isEmpty }.enumerated()), id: \.offset) { _, syllable in
                                Text(syllable)
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.pink.opacity(0.08))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(Color.pink.opacity(0.1), lineWidth: 0.5)
                                            )
                                    )
                                    .foregroundColor(Color.pink.opacity(0.8))
                            }
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 8)
                }

                // Footer
                if !item.translatedText.isEmpty {
                    Text("via \(viewModel.providerName)")
                        .font(.system(size: 9, weight: .regular))
                        .foregroundColor(.secondary.opacity(0.4))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 14).padding(.bottom, 8)
                } else {
                    Spacer().frame(height: 4)
                }

                if viewModel.showCopiedFeedback {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill").font(.system(size: 10))
                        Text("已複製").font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(.green)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color.green.opacity(0.1)).cornerRadius(6)
                    .padding(.bottom, 8)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            } else {
                Text("等待翻譯...").foregroundColor(.secondary).font(.system(size: 13)).padding(16)
            }
        }
        .frame(width: 340, alignment: .top)
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(LinearGradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 8)
        .animation(.easeInOut(duration: 0.2), value: viewModel.showCopiedFeedback)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isSaved)
    }
    
    private func partOfSpeechAbbr(_ partOfSpeech: String, sourceWord: String?) -> String {
        let abbr: String
        switch partOfSpeech.lowercased() {
        case "noun", "名詞":       abbr = "名"
        case "verb", "動詞":       abbr = "動"
        case "adjective", "形容詞": abbr = "形"
        case "adverb", "副詞":     abbr = "副"
        case "pronoun", "代名詞":   abbr = "代"
        case "preposition", "介系詞": abbr = "介"
        case "conjunction", "連接詞": abbr = "連"
        case "interjection", "感嘆詞": abbr = "嘆"
        default:                    abbr = String(partOfSpeech.prefix(1))
        }

        if let sourceWord = sourceWord, !sourceWord.isEmpty {
            return "\(abbr). \(sourceWord)"
        }
        return abbr
    }

    private func actionToolbar() -> some View {
        HStack(spacing: 6) {
            ToolbarButton(icon: "speaker.wave.2.fill", tooltip: "朗讀",
                          action: { viewModel.speakOriginal() })
            ToolbarButton(icon: viewModel.showCopiedFeedback ? "checkmark" : "doc.on.doc",
                          tooltip: "複製", action: { viewModel.copyTranslation() })
            ToolbarButton(icon: viewModel.isSaved ? "bookmark.fill" : "bookmark",
                          tooltip: viewModel.isSaved ? "取消收藏" : "加入收藏",
                          isActive: viewModel.isSaved, action: { viewModel.toggleSaved() })
        }
    }
}

struct ToolbarButton: View {
    let icon: String
    let tooltip: String
    var isActive: Bool = false
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isActive ? .blue : (isHovered ? .primary : .secondary))
                .frame(width: 24, height: 24)
                .background(RoundedRectangle(cornerRadius: 6).fill(isHovered ? Color.primary.opacity(0.1) : Color.clear))
        }
        .buttonStyle(.plain)
        .onHover { hovering in isHovered = hovering }
        .help(tooltip)
    }
}

public struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    public init(material: NSVisualEffectView.Material, blendingMode: NSVisualEffectView.BlendingMode) {
        self.material = material
        self.blendingMode = blendingMode
    }
    
    public func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.wantsLayer = true
        return view
    }
    
    public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

import SwiftUI

public struct FloatingPanelView: View {
    @ObservedObject var viewModel: TranslationViewModel
    
    public init(viewModel: TranslationViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if let item = viewModel.currentItem {
                HStack {
                    Text("翻譯")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    HStack(spacing: 8) {
                        ToolbarButton(icon: "speaker.wave.2.fill", tooltip: "朗讀原文",
                                      action: { viewModel.speakOriginal() })
                        ToolbarButton(icon: viewModel.showCopiedFeedback ? "checkmark" : "doc.on.doc",
                                      tooltip: "複製翻譯", action: { viewModel.copyTranslation() })
                        ToolbarButton(icon: viewModel.isSaved ? "bookmark.fill" : "bookmark",
                                      tooltip: viewModel.isSaved ? "取消收藏" : "加入收藏",
                                      isActive: viewModel.isSaved, action: { viewModel.toggleSaved() })
                    }
                }
                .padding(.horizontal, 14).padding(.top, 10).padding(.bottom, 6)
                
                Divider().padding(.horizontal, 10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("ORIGINAL")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(Color.blue.opacity(0.6)).tracking(1.0)
                    Text(item.originalText)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.primary.opacity(0.8))
                        .lineLimit(4).multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        
                    if let phonetics = item.phonetics, !phonetics.isEmpty {
                        Text("[\(phonetics)]")
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 14).padding(.top, 10).padding(.bottom, 8)
                
                // Show translation section only if there's a translation (not Chinese-only mode)
                if !item.translatedText.isEmpty {
                    Rectangle()
                        .fill(LinearGradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(height: 1).padding(.horizontal, 14)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("翻譯結果")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundColor(Color.purple.opacity(0.6)).tracking(1.0)
                        HStack(alignment: .top, spacing: 6) {
                            if item.isTranslating {
                                ProgressView().scaleEffect(0.6).frame(width: 14, height: 14)
                            }
                            Text(item.translatedText)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                                .lineLimit(6).multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                        }
                    }
                    .padding(.horizontal, 14).padding(.top, 8).padding(.bottom, 6)
                }
                
                // Zhuyin annotation (only for Chinese text)
                if !viewModel.zhuyinText.isEmpty {
                    if !item.translatedText.isEmpty {
                        Rectangle()
                            .fill(LinearGradient(colors: [Color.purple.opacity(0.2), Color.pink.opacity(0.2)],
                                                 startPoint: .leading, endPoint: .trailing))
                            .frame(height: 1).padding(.horizontal, 14)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("注音")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundColor(Color.pink.opacity(0.6)).tracking(1.0)
                        
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
                    }
                    .padding(.horizontal, 14).padding(.top, item.translatedText.isEmpty ? 8 : 6).padding(.bottom, 8)
                    .transition(.opacity)
                }
                
                // Provider attribution (only when translation API was used)
                if !item.translatedText.isEmpty {
                    Text("via \(viewModel.providerName)")
                        .font(.system(size: 9, weight: .regular))
                        .foregroundColor(.secondary.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 14).padding(.bottom, 10)
                } else {
                    Spacer().frame(height: 6)
                }
                
                if viewModel.showCopiedFeedback {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill").font(.system(size: 10))
                        Text("已複製到剪貼簿").font(.system(size: 10, weight: .medium))
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

import SwiftUI

public struct AboutView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage(systemSymbolName: "book.fill", accessibilityDescription: nil)!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 96, height: 96)
                .cornerRadius(22)
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 4) {
                Text("Lex")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                
                Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "laptopcomputer")
                        Text("開發者 (Developer)")
                    }
                    .font(.headline)
                    Text("Maple Kuo")
                        .font(.body)
                    
                    HStack(spacing: 16) {
                        Link("Facebook", destination: URL(string: "https://www.facebook.com/profile.php?id=61585105004197")!)
                        Link("LinkedIn", destination: URL(string: "https://www.linkedin.com/in/maplekuo")!)
                        Link("GitHub", destination: URL(string: "https://github.com/Mapleeeeeeeeeee")!)
                    }
                    .font(.callout)
                }
                
                Divider()
                    .padding(.horizontal, 40)
                
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "books.vertical.fill")
                        Text("注音資料來源")
                    }
                    .font(.headline)
                    Link("教育部《國語辭典簡編本》", destination: URL(string: "https://dict.concised.moe.edu.tw/")!)
                        .font(.body)
                    
                    HStack(spacing: 4) {
                        Text("授權：")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Link("CC BY-ND 3.0 TW", destination: URL(string: "https://creativecommons.org/licenses/by-nd/3.0/tw/")!)
                            .font(.caption)
                    }
                }
            }
            .padding(.top, 8)
            
            VStack(spacing: 4) {
                Text("Made with ❤️ in Taiwan")
                Link("Licensed under Apache License 2.0", destination: URL(string: "https://www.apache.org/licenses/LICENSE-2.0")!)
            }
            .font(.system(size: 9))
            .foregroundColor(Color.secondary.opacity(0.5))
            .padding(.top, 16)
        }
        .padding(40)
        .frame(width: 360)
        .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow))
    }
}

import SwiftUI
import Combine
import ServiceManagement

@main
struct LexApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var panel: NSPanel!
    var viewModel = TranslationViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var clickMonitor: Any?
    private var keyMonitor: Any?
    
    // Menu Bar
    var statusItem: NSStatusItem!
    var vocabWindow: NSWindow?
    var vocabListVM = VocabularyListViewModel()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        // Setup AppController
        AppController.shared.viewModel = viewModel
        AppController.shared.startListening()
        
        // Setup translation floating panel
        setupTranslationPanel()
        
        // Setup menu bar
        setupMenuBar()
    }
    
    // MARK: - Translation Panel
    
    private func setupTranslationPanel() {
        let panelView = FloatingPanelView(viewModel: viewModel)
        
        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 340, height: 200),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.level = .floating
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.becomesKeyOnlyIfNeeded = true
        panel.contentView = NSHostingView(rootView: panelView)
        panel.center()
        
        viewModel.$showPanel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] show in
                guard let self = self else { return }
                if show {
                    self.showPanelNearMouse()
                    self.startDismissMonitors()
                } else {
                    self.panel.orderOut(nil)
                    self.stopDismissMonitors()
                }
            }
            .store(in: &cancellables)
            
        panel.orderOut(nil)
    }
    
    // MARK: - Menu Bar
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "character.book.closed.fill", accessibilityDescription: "翻譯")
            button.image?.size = NSSize(width: 16, height: 16)
        }
        
        let menu = NSMenu()
        
        let providerItem = NSMenuItem(title: TranslationService.shared.activeProvider.name, action: nil, keyEquivalent: "")
        providerItem.image = NSImage(systemSymbolName: "globe", accessibilityDescription: nil)
        providerItem.isEnabled = false
        menu.addItem(providerItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let vocabItem = NSMenuItem(title: "收藏詞彙", action: #selector(openVocabularyWindow), keyEquivalent: "l")
        vocabItem.image = NSImage(systemSymbolName: "bookmark", accessibilityDescription: nil)
        vocabItem.target = self
        menu.addItem(vocabItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let launchAtLoginItem = NSMenuItem(title: "開機自動啟動", action: #selector(toggleLaunchAtLogin(_:)), keyEquivalent: "")
        launchAtLoginItem.target = self
        launchAtLoginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
        menu.addItem(launchAtLoginItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let aboutItem = NSMenuItem(title: "關於 Lex", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.image = NSImage(systemSymbolName: "info.circle", accessibilityDescription: nil)
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        let quitItem = NSMenuItem(title: "結束", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.image = NSImage(systemSymbolName: "power", accessibilityDescription: nil)
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
    @objc private func openVocabularyWindow() {
        if let existing = vocabWindow, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        vocabListVM.refresh()
        let listView = VocabularyListView(viewModel: vocabListVM)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "收藏詞彙"
        window.contentView = NSHostingView(rootView: listView)
        window.center()
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        
        NSApp.activate(ignoringOtherApps: true)
        
        vocabWindow = window
    }
    
    @objc private func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
                sender.state = .off
            } else {
                try SMAppService.mainApp.register()
                sender.state = .on
            }
        } catch {
            print("Failed to toggle launch at login \(error)")
        }
    }
    
    @objc private func showAbout() {
        let creditsHtml = """
        <div style="text-align: center; font-family: -apple-system, sans-serif;">
            <p><b>💻 開發者 (Developer)</b><br>
            Maple Kuo</p>
            <p>
                <a href="https://www.facebook.com/profile.php?id=61585105004197">Facebook</a> | 
                <a href="https://www.linkedin.com/in/maplekuo">LinkedIn</a> | 
                <a href="https://github.com/Mapleeeeeeeeeee">GitHub</a>
            </p>
            <br>
            <p><b>📚 注音資料來源 (Data Source)</b><br>
            <a href="https://dict.concised.moe.edu.tw/">教育部《國語辭典簡編本》</a><br>
            授權：<a href="https://creativecommons.org/licenses/by-nd/3.0/tw/">CC BY-ND 3.0 TW</a></p>
        </div>
        """
        
        let data = creditsHtml.data(using: .utf8)!
        let attrStr = try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        )
        
        let options: [NSApplication.AboutPanelOptionKey: Any] = [
            .credits: attrStr ?? NSAttributedString(string: "Made with ❤️"),
            .applicationName: "Lex",
            .applicationVersion: "v1.0.0"
        ]
        
        NSApp.activate(ignoringOtherApps: true)
        NSApplication.shared.orderFrontStandardAboutPanel(options: options)
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
    
    // MARK: - Panel Positioning
    
    private func showPanelNearMouse() {
        let mouseLocation = NSEvent.mouseLocation
        guard let screen = NSScreen.screens.first(where: { $0.frame.contains(mouseLocation) }) ?? NSScreen.main else { return }
        
        var x = mouseLocation.x - panel.frame.width / 2
        var y = mouseLocation.y + 20
        
        x = max(screen.visibleFrame.minX + 10, min(x, screen.visibleFrame.maxX - panel.frame.width - 10))
        y = max(screen.visibleFrame.minY + 10, min(y, screen.visibleFrame.maxY - panel.frame.height - 10))
        
        panel.setFrameOrigin(NSPoint(x: x, y: y))
        panel.orderFrontRegardless()
    }
    
    // MARK: - Dismiss Monitors
    
    private func startDismissMonitors() {
        clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.viewModel.hidePanel()
        }
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 {
                self?.viewModel.hidePanel()
                return nil
            }
            return event
        }
    }
    
    private func stopDismissMonitors() {
        if let monitor = clickMonitor { NSEvent.removeMonitor(monitor); clickMonitor = nil }
        if let monitor = keyMonitor { NSEvent.removeMonitor(monitor); keyMonitor = nil }
    }
}

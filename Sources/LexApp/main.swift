import SwiftUI
import Combine
import ServiceManagement
import Sparkle

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
    var aboutWindow: NSWindow?
    var updaterController: SPUStandardUpdaterController!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        // Setup AppController
        AppController.shared.viewModel = viewModel
        
        // Setup Auto-Updater
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        
        // Initial accessibility check
        if !AXIsProcessTrusted() {
            let alert = NSAlert()
            alert.messageText = "需要輔助使用權限"
            alert.informativeText = "Lex 需要「輔助使用」權限才能偵測您的 Command 鍵雙擊動作並取得選取文字。\n\n請在系統設定中授予 Lex 權限。"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "前往設定")
            alert.addButton(withTitle: "稍後再說")
            
            if alert.runModal() == .alertFirstButtonReturn {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
        
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
        
        let updateItem = NSMenuItem(title: "檢查更新...", action: #selector(checkForUpdates), keyEquivalent: "")
        updateItem.image = NSImage(systemSymbolName: "arrow.triangle.2.circlepath", accessibilityDescription: nil)
        updateItem.target = self
        menu.addItem(updateItem)
        
        let quitItem = NSMenuItem(title: "結束", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.image = NSImage(systemSymbolName: "power", accessibilityDescription: nil)
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
    @objc private func checkForUpdates() {
        updaterController.checkForUpdates(nil)
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
        if let existing = aboutWindow, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let view = AboutView()
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 440),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: view)
        window.center()
        window.makeKeyAndOrderFront(nil)
        
        NSApp.activate(ignoringOtherApps: true)
        
        aboutWindow = window
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

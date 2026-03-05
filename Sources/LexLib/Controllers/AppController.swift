import Cocoa
import Combine

public class AppController {
    public static let shared = AppController()
    
    public var viewModel: TranslationViewModel?
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    private var lastCommandPressTime: TimeInterval = 0
    private let doublePressInterval: TimeInterval = 0.4
    
    public init() {}
    
    public func startListening() {
        // Check for accessibility permissions
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if !accessEnabled {
            print("WARNING: Accessibility permissions are not enabled. The app cannot listen for global hotkeys.")
            // The call above with prompt: true already triggers the system security dialog.
            // But we can also show our own alert if needed.
            return
        }
        
        let eventMask = (1 << CGEventType.flagsChanged.rawValue)
        
        let callback: CGEventTapCallBack = { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
            guard type == .flagsChanged else { return Unmanaged.passRetained(event) }
            let controller = Unmanaged<AppController>.fromOpaque(refcon!).takeUnretainedValue()
            controller.handleFlagsChanged(event: event)
            return Unmanaged.passRetained(event)
        }
        
        let ptr = Unmanaged.passUnretained(self).toOpaque()
        
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: callback,
            userInfo: ptr
        ) else {
            print("Failed to create event tap! Accessibility permissions might be missing.")
            return
        }
        
        self.eventTap = tap
        let rlSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        self.runLoopSource = rlSource
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), rlSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }
    
    private func handleFlagsChanged(event: CGEvent) {
        let flags = event.flags
        let isCommandPressed = flags.contains(.maskCommand)
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        
        if isCommandPressed && (keyCode == 54 || keyCode == 55) {
            let currentTime = Date().timeIntervalSince1970
            if currentTime - lastCommandPressTime <= doublePressInterval {
                triggerTranslation()
                lastCommandPressTime = 0
            } else {
                lastCommandPressTime = currentTime
            }
        }
    }
    
    private func triggerTranslation() {
        ClipboardManager.shared.captureSelectedText { [weak self] extractedText in
            guard let text = extractedText, !text.isEmpty else { return }
            self?.viewModel?.translate(text: text)
        }
    }
}

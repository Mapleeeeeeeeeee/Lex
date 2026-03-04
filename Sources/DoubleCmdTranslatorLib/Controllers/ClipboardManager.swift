import Cocoa

public class ClipboardManager {
    public static let shared = ClipboardManager()
    private let pasteboard = NSPasteboard.general
    
    public init() {}
    
    public func captureSelectedText(completion: @escaping (String?) -> Void) {
        let savedItems = pasteboard.pasteboardItems?.compactMap { item -> NSPasteboardItem? in
            let newItem = NSPasteboardItem()
            for type in item.types {
                if let data = item.data(forType: type) {
                    newItem.setData(data, forType: type)
                }
            }
            return newItem
        }
        
        pasteboard.clearContents()
        simulateCopyCommand()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let copiedText = self.pasteboard.string(forType: .string)
            
            self.pasteboard.clearContents()
            if let items = savedItems, !items.isEmpty {
                self.pasteboard.writeObjects(items)
            }
            
            completion(copiedText)
        }
    }
    
    private func simulateCopyCommand() {
        let commandKey = CGKeyCode(55)
        let cKey = CGKeyCode(8)
        
        let source = CGEventSource(stateID: .hidSystemState)
        
        let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: commandKey, keyDown: true)
        let cDown = CGEvent(keyboardEventSource: source, virtualKey: cKey, keyDown: true)
        let cUp = CGEvent(keyboardEventSource: source, virtualKey: cKey, keyDown: false)
        let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: commandKey, keyDown: false)
        
        cDown?.flags = .maskCommand
        cUp?.flags = .maskCommand
        
        cmdDown?.post(tap: .cghidEventTap)
        cDown?.post(tap: .cghidEventTap)
        cUp?.post(tap: .cghidEventTap)
        cmdUp?.post(tap: .cghidEventTap)
    }
}

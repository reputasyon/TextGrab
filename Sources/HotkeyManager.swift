import Carbon
import AppKit

class HotkeyManager {
    static let shared = HotkeyManager()
    private var hotKeyRef: EventHotKeyRef?
    private var ssHotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    fileprivate static var handlers: [UInt32: () -> Void] = [:]

    private func ensureEventHandler() {
        guard eventHandlerRef == nil else { return }

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            hotKeyCallback,
            1,
            &eventType,
            nil,
            &eventHandlerRef
        )
    }

    func register(keyCode: UInt32, modifiers: UInt32, handler: @escaping () -> Void) {
        unregister()
        ensureEventHandler()

        HotkeyManager.handlers[1] = handler

        let hotKeyID = EventHotKeyID(
            signature: OSType(0x54585447), // "TXTG"
            id: 1
        )

        RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    func registerScreenshot(keyCode: UInt32, modifiers: UInt32, handler: @escaping () -> Void) {
        unregisterScreenshot()
        ensureEventHandler()

        HotkeyManager.handlers[2] = handler

        let hotKeyID = EventHotKeyID(
            signature: OSType(0x54585447), // "TXTG"
            id: 2
        )

        RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &ssHotKeyRef
        )
    }

    func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
    }

    func unregisterScreenshot() {
        if let ref = ssHotKeyRef {
            UnregisterEventHotKey(ref)
            ssHotKeyRef = nil
        }
    }

    func unregisterAll() {
        unregister()
        unregisterScreenshot()
    }
}

private func hotKeyCallback(
    nextHandler: EventHandlerCallRef?,
    event: EventRef?,
    userData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let event else { return OSStatus(eventNotHandledErr) }

    var hotKeyID = EventHotKeyID()
    GetEventParameter(
        event,
        EventParamName(kEventParamDirectObject),
        EventParamType(typeEventHotKeyID),
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &hotKeyID
    )

    HotkeyManager.handlers[hotKeyID.id]?()
    return noErr
}

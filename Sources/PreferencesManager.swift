import Carbon
import AppKit

final class PreferencesManager {
    static let shared = PreferencesManager()

    private enum Keys {
        static let keyCode = "shortcut_keyCode"
        static let modifiers = "shortcut_modifiers"
        static let ssKeyCode = "screenshot_keyCode"
        static let ssModifiers = "screenshot_modifiers"
    }

    // Default OCR: Control + Option + T
    static let defaultKeyCode: UInt32 = 17       // kVK_ANSI_T
    static let defaultModifiers: UInt32 = 0x1000 | 0x0800  // controlKey | optionKey

    // Default Screenshot: Control + Option + S
    static let defaultSSKeyCode: UInt32 = 1      // kVK_ANSI_S
    static let defaultSSModifiers: UInt32 = 0x1000 | 0x0800  // controlKey | optionKey

    private let defaults = UserDefaults.standard

    var keyCode: UInt32 {
        get {
            let stored = defaults.integer(forKey: Keys.keyCode)
            return stored == 0 && !defaults.bool(forKey: "shortcut_hasBeenSet")
                ? Self.defaultKeyCode
                : UInt32(stored)
        }
        set {
            defaults.set(Int(newValue), forKey: Keys.keyCode)
            defaults.set(true, forKey: "shortcut_hasBeenSet")
        }
    }

    var modifiers: UInt32 {
        get {
            let stored = defaults.integer(forKey: Keys.modifiers)
            return stored == 0 && !defaults.bool(forKey: "shortcut_hasBeenSet")
                ? Self.defaultModifiers
                : UInt32(stored)
        }
        set {
            defaults.set(Int(newValue), forKey: Keys.modifiers)
            defaults.set(true, forKey: "shortcut_hasBeenSet")
        }
    }

    // MARK: - Screenshot Shortcut

    var ssKeyCode: UInt32 {
        get {
            let stored = defaults.integer(forKey: Keys.ssKeyCode)
            return stored == 0 && !defaults.bool(forKey: "screenshot_hasBeenSet")
                ? Self.defaultSSKeyCode
                : UInt32(stored)
        }
        set {
            defaults.set(Int(newValue), forKey: Keys.ssKeyCode)
            defaults.set(true, forKey: "screenshot_hasBeenSet")
        }
    }

    var ssModifiers: UInt32 {
        get {
            let stored = defaults.integer(forKey: Keys.ssModifiers)
            return stored == 0 && !defaults.bool(forKey: "screenshot_hasBeenSet")
                ? Self.defaultSSModifiers
                : UInt32(stored)
        }
        set {
            defaults.set(Int(newValue), forKey: Keys.ssModifiers)
            defaults.set(true, forKey: "screenshot_hasBeenSet")
        }
    }

    var ssDisplayString: String {
        Self.displayString(keyCode: ssKeyCode, modifiers: ssModifiers)
    }

    var isSSDefault: Bool {
        ssKeyCode == Self.defaultSSKeyCode && ssModifiers == Self.defaultSSModifiers
    }

    // MARK: - Reset

    func resetToDefaults() {
        defaults.removeObject(forKey: Keys.keyCode)
        defaults.removeObject(forKey: Keys.modifiers)
        defaults.removeObject(forKey: "shortcut_hasBeenSet")
    }

    func resetSSToDefaults() {
        defaults.removeObject(forKey: Keys.ssKeyCode)
        defaults.removeObject(forKey: Keys.ssModifiers)
        defaults.removeObject(forKey: "screenshot_hasBeenSet")
    }

    var isDefault: Bool {
        keyCode == Self.defaultKeyCode && modifiers == Self.defaultModifiers
    }

    // MARK: - Human-Readable Shortcut String

    var shortcutDisplayString: String {
        return Self.displayString(keyCode: keyCode, modifiers: modifiers)
    }

    static func displayString(keyCode: UInt32, modifiers: UInt32) -> String {
        var parts = ""

        // Carbon modifier flags
        if modifiers & UInt32(controlKey) != 0 { parts += "\u{2303}" }    // ⌃
        if modifiers & UInt32(optionKey) != 0  { parts += "\u{2325}" }    // ⌥
        if modifiers & UInt32(shiftKey) != 0   { parts += "\u{21E7}" }    // ⇧
        if modifiers & UInt32(cmdKey) != 0     { parts += "\u{2318}" }    // ⌘

        parts += Self.keyCodeToString(keyCode)

        return parts
    }

    // Convert Carbon key codes to readable string
    static func keyCodeToString(_ keyCode: UInt32) -> String {
        let mapping: [UInt32: String] = [
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
            8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
            16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6",
            23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0",
            30: "]", 31: "O", 32: "U", 33: "[", 34: "I", 35: "P",
            37: "L", 38: "J", 39: "'", 40: "K", 41: ";", 42: "\\",
            43: ",", 44: "/", 45: "N", 46: "M", 47: ".",
            49: "Space", 50: "`",
            36: "\u{21A9}", // Return ↩
            48: "\u{21E5}", // Tab ⇥
            51: "\u{232B}", // Delete ⌫
            53: "\u{238B}", // Escape ⎋
            76: "\u{2324}", // Enter ⌤
            96: "F5", 97: "F6", 98: "F7", 99: "F3", 100: "F8",
            101: "F9", 109: "F10", 103: "F11", 111: "F12",
            105: "F13", 107: "F14", 113: "F15",
            118: "F4", 120: "F2", 122: "F1",
            123: "\u{2190}", // Left ←
            124: "\u{2192}", // Right →
            125: "\u{2193}", // Down ↓
            126: "\u{2191}", // Up ↑
        ]
        return mapping[keyCode] ?? "Key\(keyCode)"
    }

    // Convert NSEvent modifier flags to Carbon modifier flags
    static func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        var carbon: UInt32 = 0
        if flags.contains(.control) { carbon |= UInt32(controlKey) }
        if flags.contains(.option)  { carbon |= UInt32(optionKey) }
        if flags.contains(.shift)   { carbon |= UInt32(shiftKey) }
        if flags.contains(.command) { carbon |= UInt32(cmdKey) }
        return carbon
    }
}

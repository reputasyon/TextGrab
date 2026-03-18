import Foundation

enum L {
    private static let isTurkish: Bool = {
        Locale.current.language.languageCode?.identifier == "tr"
    }()

    // Menu Bar
    static let captureText = isTurkish ? "Ekrandan Metin Yakala" : "Capture Text from Screen"
    static let captureScreenshot = isTurkish ? "Ekran Görüntüsü Kopyala" : "Copy Screenshot"
    static let settings = isTurkish ? "Ayarlar..." : "Settings..."
    static let starOnGitHub = isTurkish ? "GitHub'da Star Ver" : "Star on GitHub"
    static let quit = isTurkish ? "Çıkış" : "Quit"

    // Welcome
    static let welcomeTitle = isTurkish ? "TextGrab Hazır!" : "TextGrab is Ready!"
    static let welcomeSubtitle = isTurkish ? "Menu bar'a eklendi" : "Added to menu bar"
    static let welcomeStep1 = isTurkish ? "tuşlarına bas" : "to activate"
    static let welcomeStep2 = isTurkish ? "Ekranda bölge seç" : "Select a region on screen"
    static let welcomeStep3 = isTurkish ? "Metin panoya kopyalanır" : "Text is copied to clipboard"
    static let gotIt = isTurkish ? "Anladım" : "Got it"

    // Settings
    static let settingsTitle = isTurkish ? "TextGrab Ayarlar" : "TextGrab Settings"
    static let keyboardShortcut = isTurkish ? "Klavye Kısayolu" : "Keyboard Shortcut"
    static let shortcutDesc = isTurkish
        ? "Ekrandan metin yakalama kısayolunu ayarlayın."
        : "Set the shortcut for capturing text from screen."
    static let shortcutLabel = isTurkish ? "Kısayol:" : "Shortcut:"
    static let recording = isTurkish ? "Bir tuş kombinasyonu girin..." : "Press a key combination..."
    static let recordingHint = isTurkish
        ? "Kaydetmek istediğiniz tuş kombinasyonuna basın. ESC ile iptal edin."
        : "Press the key combination you want. ESC to cancel."
    static let cancel = isTurkish ? "İptal" : "Cancel"
    static let resetToDefault = isTurkish ? "Varsayılana Sıfırla" : "Reset to Default"
    static let close = isTurkish ? "Kapat" : "Close"

    // Toast
    static let copied = isTurkish ? "Kopyalandı!" : "Copied!"
    static func copiedCount(_ count: Int) -> String {
        isTurkish ? "Kopyalandı! (\(count) karakter)" : "Copied! (\(count) characters)"
    }
    static let screenshotCopied = isTurkish ? "Ekran görüntüsü kopyalandı!" : "Screenshot copied!"
    static let noTextFound = isTurkish ? "Metin bulunamadı" : "No text found"
    static let captureError = isTurkish ? "Ekran yakalanamadı" : "Screen capture failed"
    static let ocrError = isTurkish ? "OCR hatası" : "OCR error"

    // Settings - Screenshot
    static let screenshotShortcut = isTurkish ? "Ekran Görüntüsü Kısayolu" : "Screenshot Shortcut"
    static let screenshotShortcutDesc = isTurkish
        ? "Ekran görüntüsünü panoya kopyalama kısayolu."
        : "Shortcut for copying screenshot to clipboard."

    // Branding
    static let madeBy = "Made by"
}

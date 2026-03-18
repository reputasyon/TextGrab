import ServiceManagement

enum LaunchAtLogin {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func toggle() {
        if isEnabled {
            try? SMAppService.mainApp.unregister()
        } else {
            try? SMAppService.mainApp.register()
        }
    }

    static func enable() {
        if !isEnabled {
            try? SMAppService.mainApp.register()
        }
    }

    static func disable() {
        if isEnabled {
            try? SMAppService.mainApp.unregister()
        }
    }
}

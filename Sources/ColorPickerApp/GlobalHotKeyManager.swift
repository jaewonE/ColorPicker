import Carbon.HIToolbox
import Foundation

/// Registers the requested shortcuts without requiring Accessibility access.
final class GlobalHotKeyManager {
    private enum Identifier: UInt32 {
        case toggleCoordinateLock = 1
        case saveCurrentColor = 2
    }

    private var eventHandler: EventHandlerRef?
    private var hotKeyRefs: [EventHotKeyRef] = []

    func install() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        let handlerStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData in
                guard let event, let userData else { return OSStatus(eventNotHandledErr) }
                var hotKeyID = EventHotKeyID()
                let parameterStatus = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                guard parameterStatus == noErr else { return parameterStatus }
                let manager = Unmanaged<GlobalHotKeyManager>.fromOpaque(userData).takeUnretainedValue()
                manager.handle(hotKeyID.id)
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )
        guard handlerStatus == noErr else {
            NSLog("ColorPicker could not install its global hot-key handler: %d", handlerStatus)
            return
        }

        register(keyCode: UInt32(kVK_ANSI_F), identifier: .toggleCoordinateLock)
        register(keyCode: UInt32(kVK_ANSI_S), identifier: .saveCurrentColor)
    }

    deinit {
        hotKeyRefs.forEach { _ = UnregisterEventHotKey($0) }
        if let eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }

    private func register(keyCode: UInt32, identifier: Identifier) {
        var hotKey: EventHotKeyRef?
        let result = RegisterEventHotKey(
            keyCode,
            UInt32(cmdKey | shiftKey),
            EventHotKeyID(signature: OSType(0x434C_5250), id: identifier.rawValue),
            GetApplicationEventTarget(),
            0,
            &hotKey
        )
        if result == noErr, let hotKey {
            hotKeyRefs.append(hotKey)
        } else {
            NSLog("ColorPicker could not register global hot key %u: %d", keyCode, result)
        }
    }

    private func handle(_ rawIdentifier: UInt32) {
        guard let identifier = Identifier(rawValue: rawIdentifier) else { return }
        let notification: Notification.Name = switch identifier {
        case .toggleCoordinateLock: .toggleCoordinateLock
        case .saveCurrentColor: .saveCurrentColor
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: notification, object: nil)
        }
    }
}

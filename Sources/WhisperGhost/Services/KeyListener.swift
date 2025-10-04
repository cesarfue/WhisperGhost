import Cocoa

enum KeyCodes: CGKeyCode {
    case Fn = 63
    case RCmd = 54
    case RAlt = 61
    case F5 = 96
}

class KeyListener {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var onStart: (() -> Void)?
    private var onStop: (() -> Void)?
    private var keyCodeToMonitor: CGKeyCode
    private var isPressed = false

    init(onStart: @escaping () -> Void, onStop: @escaping () -> Void) {
        self.onStart = onStart
        self.onStop = onStop
        self.keyCodeToMonitor = KeyCodes.RAlt.rawValue  // change key here
    }

    func startListening() {
        guard eventTap == nil else { return }

        // Listen for both modifier changes and key presses
        let mask =
            (1 << CGEventType.keyDown.rawValue)
            | (1 << CGEventType.keyUp.rawValue)
            | (1 << CGEventType.flagsChanged.rawValue)

        let refcon = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        let callback: CGEventTapCallBack = { _, type, event, refcon in
            guard let refcon = refcon else { return Unmanaged.passUnretained(event) }
            let listener = Unmanaged<KeyListener>.fromOpaque(refcon).takeUnretainedValue()

            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

            // Ignore unrelated keys
            guard keyCode == listener.keyCodeToMonitor else {
                return Unmanaged.passUnretained(event)
            }

            // Detect pressed state depending on key type
            var pressed = false

            switch listener.keyCodeToMonitor {
            case KeyCodes.Fn.rawValue:
                pressed = event.flags.contains(.maskSecondaryFn)
            case KeyCodes.RCmd.rawValue:
                pressed = event.flags.contains(.maskCommand)
            case KeyCodes.RAlt.rawValue:
                pressed = event.flags.contains(.maskAlternate)
            default:
                // For non-modifier keys (F5, letters, etc.)
                pressed = (type == .keyDown)
            }

            if pressed && !listener.isPressed {
                listener.isPressed = true
                listener.onStart?()
            } else if !pressed && listener.isPressed {
                listener.isPressed = false
                listener.onStop?()
            }

            return Unmanaged.passUnretained(event)
        }

        // Create global event tap
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: callback,
            userInfo: refcon
        )

        guard let eventTap = eventTap else {
            print("❌ Failed to create global key event tap")
            return
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        print("✅ Listening for keyCode:", keyCodeToMonitor)
    }

    func stopListening() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            if let runLoopSource = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            }
            self.eventTap = nil
            self.runLoopSource = nil
        }
    }

    deinit {
        stopListening()
    }
}

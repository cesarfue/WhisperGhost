import Cocoa

class KeyListener {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var onStart: (() -> Void)?
    private var onStop: (() -> Void)?
    private var keyCodeToMonitor: CGKeyCode
    private var isPressed = false  // track Fn key state

    init(onStart: @escaping () -> Void, onStop: @escaping () -> Void, key: CGKeyCode = 63) {
        self.onStart = onStart
        self.onStop = onStop
        self.keyCodeToMonitor = key
    }

    func startListening() {
        guard eventTap == nil else { return }

        let mask = CGEventMask(1 << CGEventType.flagsChanged.rawValue)
        let refcon = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        let callback: CGEventTapCallBack = { _, type, event, refcon in
            guard type == .flagsChanged else { return Unmanaged.passUnretained(event) }

            let listener = Unmanaged<KeyListener>.fromOpaque(refcon!).takeUnretainedValue()
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

            guard keyCode == listener.keyCodeToMonitor else {
                return Unmanaged.passUnretained(event)
            }

            let pressed = event.flags.contains(.maskSecondaryFn)  // detect Fn key down
            if pressed && !listener.isPressed {
                listener.isPressed = true
                listener.onStart?()
            } else if !pressed && listener.isPressed {
                listener.isPressed = false
                listener.onStop?()
            }

            return Unmanaged.passUnretained(event)
        }

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: refcon
        )

        guard let eventTap = eventTap else {
            print("Failed to create global key event tap")
            return
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
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

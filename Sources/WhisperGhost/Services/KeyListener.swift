import AppKit

class KeyListener {
    private var keyDownMonitor: Any?
    private var onStart: (() -> Void)?
    private var onStop: (() -> Void)?
    private var key: Int

    init(onStart: @escaping () -> Void, onStop: @escaping () -> Void) {
        self.onStart = onStart
        self.onStop = onStop
        self.key = 63
    }

    func startListening() {
        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {
            [weak self] event in
            guard let self = self else { return event }

            if event.keyCode == self.key {
                if event.modifierFlags.contains(.function) {
                    self.onStart?()
                } else {
                    self.onStop?()
                }
            }

            return event
        }
    }

    func stopListening() {
        if let monitor = keyDownMonitor {
            NSEvent.removeMonitor(monitor)
            keyDownMonitor = nil
        }
    }

    deinit {
        stopListening()
    }
}

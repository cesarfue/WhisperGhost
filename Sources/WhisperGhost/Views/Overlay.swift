import AppKit
import SwiftUI

class OverlayWindow: NSWindow {
    init() {
        let size: CGFloat = 20
        super.init(
            contentRect: NSRect(x: 50, y: 50, width: size, height: size),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .floating
        self.ignoresMouseEvents = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.contentView = NSHostingView(rootView: OverlayView())
    }
}

struct OverlayView: View {
    var body: some View {
        Circle()
            .fill(Color.black)
            .frame(width: 20, height: 20)
            .shadow(radius: 2)
    }
}

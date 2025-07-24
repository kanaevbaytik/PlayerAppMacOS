import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 Приложение запустилось")

        let screenSize = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        let windowRect = NSMakeRect(0, 0, 800, 600)

        window = NSWindow(
            contentRect: windowRect,
            styleMask: [.titled, .resizable, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Audio Player"
        let splitVC = NSSplitViewController()

        let leftVC = TrackListViewController()
        let rightVC = PlayerViewController()
        
        leftVC.delegate = rightVC

        let leftItem = NSSplitViewItem(viewController: leftVC)
        leftItem.minimumThickness = 200

        let rightItem = NSSplitViewItem(viewController: rightVC)
        rightItem.minimumThickness = 200

        splitVC.addSplitViewItem(leftItem)
        splitVC.addSplitViewItem(rightItem)

        splitVC.view.frame = window.contentView?.bounds ?? .zero
        window.contentViewController = splitVC

        window.makeKeyAndOrderFront(nil)
    }
}

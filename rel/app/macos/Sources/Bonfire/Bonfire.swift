import AppKit
import ElixirKit

@main
public struct Bonfire {
    public static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var logPath: String!
    private var launchedByOpenURL = false
    private var initialURLs: [URL] = []
    private var url: String?
    private var bootScriptURL: URL!
    // let logger: ElixirKit.Logger

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        logPath = "\(NSHomeDirectory())/Library/Logs/BonfireWebApp.log"
        bootScriptURL = NSURL.fileURL(withPath: "\(NSHomeDirectory())/.bonfire_webapp_env.sh")

        ElixirKit.API.start(
            name: "bonfire",
            logPath: logPath,
            readyHandler: {
                if (self.initialURLs == []) {
                    ElixirKit.API.publish("open", "")
                }
                else {
                    for url in self.initialURLs {
                        ElixirKit.API.publish("open", url.absoluteString)
                    }
                }
            },
            terminationHandler: { process in
                if process.terminationStatus != 0 {
                    DispatchQueue.main.sync {
                        let alert = NSAlert()
                        alert.alertStyle = .critical
                        alert.messageText = "Bonfire exited with error status \(process.terminationStatus)"
                        alert.addButton(withTitle: "Dismiss")
                        alert.addButton(withTitle: "View Logs")

                        switch alert.runModal() {
                        case .alertSecondButtonReturn:
                            self.viewLogs()
                        default:
                            ()
                        }
                    }
                }

                NSApp.terminate(nil)
            }
        )

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let button = statusItem.button!
        // let icon = NSApplication.shared.applicationIconImage! // use the app icon
        let icon = NSImage(named: "Icon")! // use custom icon
        let resizedIcon = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { (dstRect) -> Bool in
            icon.draw(in: dstRect)
            return true
        }
        button.image = resizedIcon
        let menu = NSMenu()

        let copyURLItem = NSMenuItem(title: "Copy URL", action: nil, keyEquivalent: "c")

        menu.items = [
            NSMenuItem(title: "Dashboard", action: #selector(open), keyEquivalent: "o"),
            NSMenuItem(title: "Write", action: #selector(openNew), keyEquivalent: "n"),
            NSMenuItem(title: "My Profile", action: #selector(openMe), keyEquivalent: "n"),
            NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ","),
            .separator(),
            copyURLItem,
            NSMenuItem(title: "View Logs", action: #selector(viewLogs), keyEquivalent: "l"),
            NSMenuItem(title: "Open boot script", action: #selector(openBootScript), keyEquivalent: ""),
            .separator(),
            NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        ]
        statusItem.menu = menu

        ElixirKit.API.addObserver(queue: .main) { (name, data) in
            switch name {
            case "url":
                copyURLItem.action = #selector(self.copyURL)
                self.url = data
            default:
                fatalError("unknown event \(name)")
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        ElixirKit.API.stop()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        ElixirKit.API.publish("open", "")
        return true
    }

    func application(_ app: NSApplication, open urls: [URL]) {
        if !ElixirKit.API.isRunning {
            initialURLs = urls
            return
        }

        for url in urls {
            ElixirKit.API.publish("open", url.absoluteString)
        }
    }

    @objc
    func open() {
        ElixirKit.API.publish("open", "")
    }

    @objc
    func openNew() {
        ElixirKit.API.publish("open", "/write")
    }

    @objc
    func openMe() {
        ElixirKit.API.publish("open", "/user")
    }

    @objc
    func openSettings() {
        ElixirKit.API.publish("open", "/settings")
    }

    @objc
    func copyURL() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setData(url!.data(using: .utf8), forType: NSPasteboard.PasteboardType.URL)
    }

    @objc
    func viewLogs() {
        NSWorkspace.shared.open(NSURL.fileURL(withPath: logPath))
    }

    @objc
    func openBootScript() {
        let fm = FileManager.default

        if !fm.fileExists(atPath: bootScriptURL.path) {

            // TODO: how do we want to set/load env variables for app users?
            // let currentFile = URL(string: #filePath)
            // let envPath = URL(string: "../../../../../.env", relativeTo: currentFile)! 
            // let env = """
            // read_env(filePath) {
            //     local filePath="${1:-.env}"

            //     if [ ! -f "$filePath" ]; then
            //         echo "missing ${filePath}"
            //         exit 1
            //     fi

            //     echo "Reading $filePath"
            //     while read -r LINE; do
            //         # Remove leading and trailing whitespaces, and carriage return
            //         CLEANED_LINE=$(echo "$LINE" | awk '{$1=$1};1' | tr -d '\r')

            //         if [[ $CLEANED_LINE != '#'* ]] && [[ $CLEANED_LINE == *'='* ]]; then
            //         export "$CLEANED_LINE"
            //         fi
            //     done < "$filePath"
            //     }

            // read_env(\(envPath.absoluteString))
            // """

            let data = """
            # This file is used to configure Bonfire before booting.
            # If you change this file, you must restart Bonfire for your changes to take place.

            # # Allow Bonfire to connect to remote machines over IPv6
            # export BONFIRE_DISTRIBUTION=name
            # export ERL_AFLAGS="-proto_dist inet6_tcp"

            # # Add Homebrew to PATH
            # export PATH=/opt/homebrew/bin:$PATH
            """.data(using: .utf8)

            print("Create boot script: \(data)")

            fm.createFile(atPath: bootScriptURL.path, contents: data)
        }

        NSWorkspace.shared.open(bootScriptURL)
    }
}

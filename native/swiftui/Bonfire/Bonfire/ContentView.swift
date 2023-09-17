import SwiftUI
import LiveViewNative

struct ContentView: View {
    @StateObject private var coordinator = LiveSessionCoordinator(
        {
            let prodURL = Bundle.main.object(forInfoDictionaryKey: "Phoenix Production URL") as? String

            #if DEBUG
            return URL(string: "http://localhost:4000")!
            #else
            return URL(string: URL || "https://example.com")!
            #endif
        }(),
        config: LiveSessionConfiguration(navigationMode: .replaceOnly)
    )
    
    var body: some View {
        LiveView(session: coordinator)
    }
}

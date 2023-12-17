import SwiftUI
import LiveViewNative

struct ContentView: View {
    var body: some View {
        LiveView(.automatic(development: .localhost(port: 4000, path: "/"), production: .custom(URL(string: "https://campground.bonfire.cafe/")!)))
    }
}

import SwiftUI
import LiveViewNative

struct ContentView: View {
    var body: some View {
//        LiveView(.automatic(URL(string: "https://campground.bonfire.cafe/")!))
        LiveView(.automatic(development: .custom(URL(string: "http://localhost:4000/")!), production: .custom(URL(string: "https://campground.bonfire.cafe/")!)))
    }
}

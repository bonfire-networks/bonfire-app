//
//  ContentView.swift
//  Bonfire
//

import SwiftUI
import LiveViewNative
import LiveViewNativeLiveForm

struct ContentView: View {
    var body: some View {
        // #LiveView(.automatic(development: .custom(URL(string: "http://localhost:4000/")!), production: .custom(URL(string: "https://campground.bonfire.cafe/")!)))
        #LiveView(
            .automatic(
                development: .localhost(port: 4000, path: "/"),
                production: URL(string: "https://campground.bonfire.cafe")!
            ),
            addons: [
               .liveForm
            ]
        ) {
            ConnectingView()
        } disconnected: {
            DisconnectedView()
        } reconnecting: { content, isReconnecting in
            ReconnectingView(isReconnecting: isReconnecting) {
                content
            }
        } error: { error in
            ErrorView(error: error)
        }
    }
}

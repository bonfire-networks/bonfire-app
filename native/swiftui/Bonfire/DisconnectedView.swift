//
//  DisconnectedView.swift
//  DisconnectedView
//

import SwiftUI

struct DisconnectedView: View {
    var body: some View {
        if #available(iOS 17, macOS 14, tvOS 17, watchOS 10, *) {
            ContentUnavailableView {
                Label("No Connection", systemImage: "network.slash")
            } description: {
                Text("The app will reconnect when network connection is regained.")
            }
        } else {
            VStack {
                Label("No Connection", systemImage: "network.slash")
                    .font(.headline)
                Text("The app will reconnect when network connection is regained.")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    DisconnectedView()
}

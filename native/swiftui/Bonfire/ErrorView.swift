//
//  ErrorView.swift
//  ErrorView
//

import SwiftUI
import LiveViewNative

struct ErrorView: View {
    let error: Error
    
    @Environment(\.reconnectLiveView) private var reconnectLiveView

    var body: some View {
        LiveErrorView(error: error) {
            if #available(iOS 17, macOS 14, tvOS 17, watchOS 10, *) {
                ContentUnavailableView {
                    Label("Connection Failed", systemImage: "network.slash")
                } description: {
                    description
                } actions: {
                    actions
                }
            } else {
                VStack {
                    Label("Connection Failed", systemImage: "network.slash")
                        .font(.headline)
                    description
                        .foregroundStyle(.secondary)
                    actions
                }
            }
        }
    }
    
    @ViewBuilder
    var description: some View {
        #if DEBUG
        ScrollView {
            Text(error.localizedDescription)
                .font(.caption.monospaced())
                .multilineTextAlignment(.leading)
        }
        #else
        Text("The app will reconnect when network connection is regained.")
        #endif
    }
    
    @ViewBuilder
    var actions: some View {
        Button {
            #if os(iOS)
            UIPasteboard.general.string = error.localizedDescription
            #elseif os(macOS)
            NSPasteboard.general.setString(error.localizedDescription, forType: .string)
            #endif
        } label: {
            Label("Copy Error", systemImage: "doc.on.doc")
        }
        #if os(watchOS)
        SwiftUI.Button {
            Task {
                await reconnectLiveView(.restart)
            }
        } label: {
            SwiftUI.Label("Restart", systemImage: "arrow.circlepath")
        }
        .padding()
        #else
        Menu {
            Button {
                Task {
                    await reconnectLiveView(.automatic)
                }
            } label: {
                Label("Reconnect this page", systemImage: "arrow.2.circlepath")
            }
            Button {
                Task {
                    await reconnectLiveView(.restart)
                }
            } label: {
                Label("Restart from root", systemImage: "arrow.circlepath")
            }
        } label: {
            Label("Reconnect", systemImage: "arrow.2.circlepath")
        }
        .padding()
        #endif
    }
}

#Preview {
   ErrorView(error: LiveConnectionError.initialParseError(missingOrInvalid: .csrfToken))
}

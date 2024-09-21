//
//  ReconnectingView.swift
//  ReconnectingView
//

import SwiftUI

struct ReconnectingView<Content: View>: View {
    let isReconnecting: Bool
    @ViewBuilder let content: Content
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .top) {
                if isReconnecting {
                    VStack {
                        Label("No Connection", systemImage: "wifi.slash")
                            .bold()
                        Text("Reconnecting")
                            .foregroundStyle(.secondary)
                    }
                    .font(.caption)
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    #if os(watchOS)
                    .background(.background)
                    #else
                    .background(.regularMaterial)
                    #endif
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.default, value: isReconnecting)
    }
}

#Preview {
    struct PreviewView: View {
        @State private var isReconnecting = true
        
        var body: some View {
            ReconnectingView(isReconnecting: isReconnecting) {
                Toggle("Reconnecting", isOn: $isReconnecting)
            }
        }
    }
    return PreviewView()
}

# This file is responsible for configuring LiveView Native.
# It is auto-generated when running `mix lvn.install`.
import Config

# Use LiveView Native to add support for native platforms
config :live_view_native,
  plugins: [
    LiveViewNative.SwiftUI
    # LiveViewNative.Jetpack
  ]

# LiveView Native Stylesheet support
config :live_view_native_stylesheet,
  parsers: [
    swiftui: LiveViewNative.SwiftUI.RulesParser
  ]

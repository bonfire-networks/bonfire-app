# This file is responsible for configuring LiveView Native.
# It is auto-generated when running `mix lvn.install`.
import Config

config :phoenix, :template_engines, neex: LiveViewNative.Engine
config :phoenix_template, :format_encoders, swiftui: Phoenix.HTML.Engine
# jetpack: Phoenix.HTML.Engine

# Use LiveView Native to add support for native platforms
config :live_view_native,
  modularity: if(System.get_env("WITH_LV_NATIVE") not in ["1", "true"], do: :disabled),
  plugins: [
    LiveViewNative.SwiftUI
    # LiveViewNative.Jetpack
  ]

# LiveView Native Stylesheet support
config :live_view_native_stylesheet,
  parsers: [
    swiftui: LiveViewNative.SwiftUI.RulesParser
  ]

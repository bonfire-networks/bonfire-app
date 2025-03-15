import Config

#### Flavour-specific compile-time configuration goes here, everything else should be in `Ember.RuntimeConfig`

config :bonfire, :ui,
  # Register the ember custom themes
  themes: [
    "ember-dark"
  ],
  themes_light: [
    "ember"
  ]

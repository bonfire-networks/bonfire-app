use Mix.Config

repo_module = Bonfire.Repo

config :bonfire_publisher_thesis,
  web_module: Bonfire.Web,
  repo_module: repo_module

# Thesis Main Config
config :thesis,
  store: Thesis.EctoStore,
  authorization: Bonfire.PublisherThesis.ThesisAuth,
  uploader: Thesis.RepoUploader

# Thesis Store Config
config :thesis, Thesis.EctoStore, repo: repo_module

# Thesis Notifications Config
# config :thesis, :notifications,
#   add_page: [],
#   page_settings: [],
#   import_export_restore: []

# Thesis Dynamic Pages Config
# config :thesis, :dynamic_pages,
#   view: Bonfire.PublisherThesisWeb.PageView,
#   templates: ["index.html", "otherview.html"],
#   not_found_view: Bonfire.PublisherThesisWeb.ErrorView,
#   not_found_template: "404.html"

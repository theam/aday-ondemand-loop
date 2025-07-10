# Connectors

Connectors implement repository specific behaviour. A connector typically contains:

- `actions/` – service objects used by controllers when displaying repository pages.
- `download_connector_processor.rb` – downloads files for the connector.
- `upload_connector_processor.rb` – handles uploading individual files.
- `upload_bundle_connector_processor.rb` – creates and manages upload bundles.
- `display_repo_controller_resolver.rb` – resolves a repository URL into a controller/action inside Loop.

Dataverse and Zenodo connectors are included as examples. All connector classes are dynamically loaded using `ConnectorClassDispatcher` so adding a new connector only requires following the same naming conventions.

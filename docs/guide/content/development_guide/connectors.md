# Connectors

Connectors are a key extension point of Loop. They abstract repository specific
behaviour so that the core application can support multiple remote repositories
without changing its own code. Dataverse and Zenodo are already implemented with
Dataverse acting as the reference implementation.

Every connector must provide logic for:

* URL identification and parsing
* dataset browsing
* listing files within a dataset
* downloading individual files
* selecting datasets for upload
* uploading files to a dataset

A connector typically contains:

- `actions/` – service objects used by controllers when displaying repository pages.
- `download_connector_processor.rb` – downloads files for the connector.
- `upload_connector_processor.rb` – handles uploading individual files.
- `upload_bundle_connector_processor.rb` – creates and manages upload bundles.
- `display_repo_controller_resolver.rb` – resolves a repository URL into a controller/action inside Loop.

Dataverse and Zenodo connectors are included as examples. All connector classes are dynamically loaded using `ConnectorClassDispatcher` so adding a new connector only requires following the same naming conventions.

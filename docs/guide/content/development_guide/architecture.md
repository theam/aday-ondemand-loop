# General Architecture

OnDemand Loop is a Ruby on Rails application that runs as an Open OnDemand passenger app. Instead of a traditional database it stores project and file metadata in YAML files on disk. A small set of models like `Project`, `DownloadFile`, and `UploadBundle` inherit from `ApplicationDiskRecord` which provides YAML based persistence.

Transfers are processed by background services started by `DetachedProcessManager`. Each service loops over pending download or upload requests and spawns connector specific processors. Status updates are recorded back to the YAML metadata so the web UI can poll and display progress.

The web interface communicates with these services via simple command endpoints exposed through the `CommandRegistry`. This design keeps the runtime lightweight while avoiding the need for a separate job queue.

Connectors encapsulate repository specific logic and are loaded dynamically through `ConnectorClassDispatcher`. They provide processors for downloads, uploads and metadata extraction as well as controllers used to display repository content.

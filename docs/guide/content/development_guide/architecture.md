# Architecture and Code Structure

OnDemand Loop is a Ruby on Rails application that runs as an Open OnDemand
passenger app.  The project follows standard Rails conventions as long as they do
not interfere with simplicity or functionality.  Instead of a traditional
database it stores project and file metadata in YAML files on disk.  A small set
of models like `Project`, `DownloadFile`, and `UploadBundle` inherit from
`ApplicationDiskRecord` which provides YAML based persistence.

Transfers are processed by background services started by
`DetachedProcessManager`.  Each service loops over pending download or upload
requests and spawns connector specific processors.  Status updates are recorded
back to the YAML metadata so the web UI can poll and display progress.

The web interface communicates with these services via simple command endpoints
exposed through the `CommandRegistry`.  This design keeps the runtime
lightweight while avoiding the need for a separate job queue.

Connectors encapsulate repository specific logic and are loaded dynamically
through `ConnectorClassDispatcher`. They make Loop extensible by providing
custom processors and controllers for each repository. The reference
implementation is the Dataverse connector, with Zenodo as an additional
example. See the [Connectors](connectors.md) section for the exact features a
connector must implement.

## Project Layout

The root of the repository contains several top‑level folders:

| Folder | Purpose |
|--------|---------|
| `application/` | The Rails application with standard `app/`, `config/`, `lib/` etc. |
| `docker/` | Dockerfiles used to build the development images. |
| `docs/` | MkDocs documentation including this guide. Badges live under `docs/badges`. |
| `scripts/` | Helper scripts invoked by the `Makefile`. |
| `config/` | Additional configuration shared across the repo. |

Inside `application/app` important subfolders include:

| Path | Purpose |
|------|---------|
| `controllers/` | Rails controllers plus connector specific subfolders. |
| `models/` | Disk based models such as `Project`, `DownloadFile` and `UploadBundle`. |
| `connectors/` | Connector classes loaded via `ConnectorClassDispatcher`. |
| `services/` | Business logic for downloads, uploads and repository APIs. |
| `process/` | Lightweight background execution framework used by the services. |
| `javascript/` and `assets/` | Front‑end JavaScript and stylesheets. |

Configuration files live under `config/`.  The file
`configuration_singleton.rb` defines all adjustable settings which can be
overridden via YAML or environment variables (see the Admin Guide for
details).

### Scripts

The `scripts/` folder contains small helper scripts used by the Makefile:

| Script | Purpose |
|--------|---------|
| `loop_build.sh` | Precompiles Rails assets inside the builder image. |
| `loop_test.sh` | Runs the full test suite and generates coverage data. |
| `loop_release_notes.sh` | Creates release notes from Git history. |
| `loop_version.sh` | Bumps the version file for releases. |
| `loop_coverage_badge.sh` | Updates the coverage badges in `docs/badges`. |
| `guide.sh` | Builds or serves this documentation via MkDocs. |
| `install_fontawesome_css.sh` | Downloads Font Awesome files used by the UI. |

## Development Environment

Loop is designed to run entirely in Docker containers.  The provided `Makefile`
builds the images, starts the containers and executes tests.  No additional
tools need to be installed locally other than Docker, Docker Compose and `make`.

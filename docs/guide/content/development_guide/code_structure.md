# Code Structure

The Rails application lives in the `application` directory. Important folders include:

| Path | Purpose |
|------|---------|
| `app/controllers` | Standard Rails controllers plus subfolders for each connector. |
| `app/models` | Disk based models such as `Project`, `DownloadFile` and `UploadBundle`. |
| `app/connectors` | Connector specific classes loaded via `ConnectorClassDispatcher`. |
| `app/services` | Business logic for downloads, uploads, and repository APIs. |
| `app/process` | Lightweight background execution framework used by the services. |
| `app/javascript` and `app/assets` | Front‑end JavaScript and stylesheets. |

Configuration files live under `config/`. The file `configuration_singleton.rb` defines all adjustable settings which can be overridden via YAML or environment variables (see the Admin Guide for details).

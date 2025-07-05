# Development Guide

This guide outlines the recommended way to set up a local environment and how to wire Dataverse to OnDemand Loop using the External Tools feature.

## Prerequisites
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- `make`

## Run OnDemand Loop locally
The repository includes a Docker based environment. Build the application and start the containers with:

```bash
make loop_build
make loop_up
```

The app will be available at [https://localhost:33000/pun/sys/loop](https://localhost:33000/pun/sys/loop).

## Run Dataverse locally
Follow the instructions to run a demo Dataverse instance using Docker Compose:

https://guides.dataverse.org/en/latest/container/running/demo.html

## Install OnDemand Loop as a Dataverse External Tool
With Dataverse running at `http://localhost:8080` and the Loop app running at `https://localhost:33000`, register the dataset tool:

```bash
curl --location 'http://localhost:8080/api/admin/externalTools' \
--header 'Content-Type: application/json' \
--data '{
  "displayName": "Explore in OOD",
  "description": "An external tool to Explore and Download dataset files in OOD",
  "toolName": "ondemand_loop_dataset_tool",
  "scope": "dataset",
  "types": [
    "explore"
  ],
  "toolUrl": "https://localhost:33000/pun/sys/loop/integrations/dataverse/external_tool/dataset",
  "httpMethod": "GET",
  "toolParameters": {
    "queryParameters": [
      {"dataverse_url": "{siteUrl}"},
      {"dataset_id": "{datasetPid}"},
      {"version": "{datasetVersion}"},
      {"locale": "{localeCode}"}
    ]
  }
}'
```

Update the Dataverse URL and the `toolUrl` when deploying in production.

### How the endpoint works
`/integrations/dataverse/external_tool/dataset` parses the parameters listed above. If the Dataverse URL includes a non‐default scheme or port they are preserved and forwarded when redirecting to the dataset view page.

### Technical Notes
- `dataverse_url` and `dataset_id` are required.
- `version` and `locale` are optional and default to the latest published version and the Dataverse installation language.


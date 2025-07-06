# Installation Guide

## Launch OnDemand Loop from Dataverse

Dataverse supports **External Tools**, which enable integrations with external web applications. This section explains how to integrate **Dataverse with OnDemand Loop**, so that users can launch Loop directly from a dataset page. This allows researchers to initiate file transfers from Dataverse into an HPC cluster via the OnDemand Loop interface.

> Note: This complements the existing Loop-side integration, where users can browse Dataverses from within the Loop app. Here, the workflow begins in Dataverse and hands off to Loop.

With Dataverse running at `http://localhost:8080` and the Loop app accessible at `https://localhost:33000`, register the external tool with the following command:

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

For production deployments, be sure to update the Dataverse server URL and use the correct path to the OnDemand Loop Passenger app in the `toolUrl`.

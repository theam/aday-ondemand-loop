# Creating a Connector

1. Copy one of the existing connectors (`app/connectors/dataverse` or `app/connectors/zenodo`) as a starting point and update module names.
2. Implement a resolver under `app/services/repo/resolvers/` that can recognise URLs for your repository and return the proper `ConnectorType`.
3. Add controller classes and views under `app/controllers/<connector>` to browse collections and datasets.
4. Provide processor classes implementing the behaviour required by Loop:
   - identify and parse repository URLs
   - browse datasets and list files
   - download individual files
   - select datasets for upload
   - upload files to a dataset
5. Register any additional routes in `config/routes.rb`.

Following these conventions allows Loop to load the connector dynamically and display it in the Repositories menu.

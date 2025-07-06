# OnDemand Loop Guide

Welcome to the OnDemand Loop documentation.

OnDemand Loop is a companion application for Open OnDemand that simplifies moving research data between clusters and remote repositories. It relies on a pluggable connector framework—Dataverse serves as the initial reference connector, with others possible in the future.

You organize your work in **projects**. Each project groups everything you download from or upload to a particular repository. Within a project you can create:

- **Download files** to pull remote data into the cluster.
- **Upload bundles** to stage local files for sending back to a repository.

This guide introduces the entire application. Alongside the User Guide sections, it includes:

- **Admin Guide** – details on configuring and managing OnDemand Loop.
- **Installation Guide** – instructions to build and install the application as a passenger app on a server running Open OnDemand.
- **Development Guide** – how to run the app locally, make changes, understand the connector architecture, and create new connectors.

Together, these sections take you from basic usage through administration and development.

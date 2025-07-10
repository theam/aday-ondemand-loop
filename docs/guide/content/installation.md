# Installation Guide

This guide explains how to build and deploy OnDemand Loop alongside an existing
Open OnDemand installation. The application is designed to run as a Passenger
app so that it lives under `/var/www/ood/apps/sys/loop` in the same manner as
the standard Dashboard app.

## System Requirements

OnDemand Loop targets the same software versions used by Open OnDemand itself.
Use the versions below (or the versions bundled with your OOD release):

- **Ruby** 3.1
- **Node.js** 18
- **Open OnDemand** 3.1 or newer

## Building the Application

The repository includes a Makefile with helper targets. The preferred way to
compile Loop is to install all Ruby gems and Node packages into local folders,
avoiding conflicts with system-wide installs. This is exactly how the
`scripts/loop_build.sh` script operates and how the application has been tested.
See that script for the exact commands executed during the build.
To run the build inside the Docker based builder image, execute:

```bash
make release_build
```

The script stores Ruby gems under `vendor/bundle` and Node packages in
`node_modules` within the `application` directory so that the build is isolated
from system packages.

This command installs all Ruby and Node dependencies and precompiles the CSS and
JavaScript assets. The same steps can be performed manually by executing the
`scripts/loop_build.sh` script on a machine that has Ruby and Node available.

## Deployment Options

### 1. Build on the Server

Clone the repository (or a release tag) directly into the OOD server, run the build script,
and copy the built application into the OOD `sys` folder:

```bash
cd /tmp
git clone <repo-or-release> loop
cd loop
./scripts/loop_build.sh
mkdir /var/www/ood/apps/sys/loop
cp -R ./application/* /var/www/ood/apps/sys/loop/
```

### 2. Build Elsewhere and Copy

If you prefer to compile the application in a controlled environment, run the
build steps on another machine and then copy `ondemand-loop/application` directory to
`/var/www/ood/apps/sys` on your production server. Then rename it to `loop`, ie: `/var/www/ood/apps/sys/loop`.
Ensure file permissions are preserved during the transfer.

### 3. Deploy with Puppet

Sites already managing Open OnDemand with the official Puppet module can deploy
Loop in a similar fashion to the Dashboard app. Build the application using the
steps above, then copy the resulting `loop` directory into a dedicated branch of
your deployment repository. The Puppet configuration can then reference that
branch when installing the app:

```yaml
openondemand::install_apps:
  'loop':
    ensure: latest
    git_repo: https://github.com/sample/deploy-ondemand-loop.git
    git_revision: production_v1.0.0-2025-07-09
```

This approach keeps the build artifacts under version control while allowing the
Puppet module to deploy the precompiled application.

## Dataverse Integration

Dataverse supports **External Tools**, which enable integrations with external
web applications. By registering OnDemand Loop as an External Tool with
`dataset` scope, users can launch Loop directly from a dataset page to initiate
transfers into the HPC cluster.

With Dataverse running at `http://localhost:8080` and the Loop app accessible at
`https://localhost:33000`, register the tool using:

```bash
curl --location 'http://localhost:8080/api/admin/externalTools' \
--header 'Content-Type: application/json' \
--data '{
  "displayName": "Explore in OOD",
  "description": "An external tool to Explore and Download dataset files in OOD",
  "toolName": "ondemand_loop_dataset_tool",
  "scope": "dataset",
  "types": ["explore"],
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

For production deployments, adjust the Dataverse URL and the `toolUrl` to match
your server names.

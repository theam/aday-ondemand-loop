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

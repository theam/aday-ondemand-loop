# Local Environment

The repository contains a Docker based setup that mirrors an Open OnDemand installation. A `Makefile` exposes handy commands.

## Prerequisites
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- `make`

## Running the App

Build the application and start the containers:

```bash
make loop_build
make loop_up
```

Open the app at [https://localhost:33000/pun/sys/loop](https://localhost:33000/pun/sys/loop).

A test user `ood/ood` is configured. The environment uses a self‑signed certificate so your browser will warn about the connection.

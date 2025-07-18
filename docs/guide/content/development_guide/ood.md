# Open OnDemand

### Overview

OnDemand Loop is deployed as a [Phusion Passenger](https://www.phusionpassenger.com/) application within the Open OnDemand (OOD) environment, in the same manner as the core OOD dashboard app. This tight integration allows OnDemand Loop to run directly as the current user, giving seamless access to the user's environment on the HPC cluster.

We rely on Open OnDemand to handle all cluster interaction, including authentication, job submission, and terminal access. Additionally, we leverage the OOD **Files** app to navigate and manage the local HPC filesystem, which is central to how OnDemand Loop reads and writes project data.

### Compatibility

We have tested OnDemand Loop with **Open OnDemand version 3.1.7**, and we aim to maintain compatibility from this version forward.

Compatibility testing with the **4.x** series is planned soon.

#### Known OOD Releases

| OOD Version | Release Date | Status               |
|-------------|--------------|----------------------|
| 3.1.7       | 2023‑05‑03   | ✅ Tested            |
| 3.1.13      | 2025‑05‑23   | 🚫 Not in test scope |
| 3.1.14      | 2025‑07‑11   | 🔜 Planned testing   |
| 4.0.0       | 2025‑01‑24   | 🔜 Planned testing   |
| 4.0.1       | 2025‑02‑13   | 🚫 Not in test scope |
| 4.0.2       | 2025‑03‑25   | 🚫 Not in test scope |
| 4.0.3       | 2025‑04‑23   | 🚫 Not in test scope |
| 4.0.4       | 2025‑05‑21   | 🚫 Not in test scope |
| 4.0.5       | 2025‑05‑27   | 🚫 Not in test scope |
| 4.0.6       | 2025‑07‑10   | ✅ Tested            |


!!! note

    ✅ Tested = Confirmed working  
    ⚠️ Not yet tested = Expected compatible, pending verification  
    🔜 Planned testing = High-priority target for validation

### Upgrading Open OnDemand (Development)

The Open OnDemand container used in development comes from the [ondemand_development](https://github.com/hmdc/ondemand_development) project.
Docker images are published under [hmdc/sid-ood on Docker Hub](https://hub.docker.com/r/hmdc/sid-ood/tags) and follow the naming convention: `ood-<version>.el8`

For example: `ood-3.1.7.el8`

The exact image used by the development environment is specified by the `OOD_IMAGE` variable in the `Makefile`.

#### To upgrade the OOD image:

1. Open `Makefile` and update the `OOD_IMAGE` variable to the desired version, e.g.  
   `OOD_IMAGE = hmdc/sid-ood:ood-3.1.8.el8`
2. Stop any running containers:  
   `make loop_down`
3. Restart the environment with the new image:  
   `make loop_up`

If the updated image requires a newer Ruby or Node.js version, update the **builder image** in the same way to ensure OnDemand Loop can be rebuilt successfully.

# Supported Repositories

OnDemand Loop integrates with remote data repositories using pluggable **connectors**.  
Each connector manages browsing, downloading, and uploading data workflows.

Currently supported connectors:

- [**Dataverse**](#dataverse)
- [**Zenodo**](#zenodo)

<div style="display: flex; flex-wrap: wrap; gap: 1.5rem; align-items: center; margin-top: 1rem;">
  <img src="../../assets/dataverse_project.svg" alt="Dataverse" width="200">
  <img src="../../assets/zenodo_project.svg" alt="Zenodo" width="200">
</div>

### Dataverse
Dataverse repositories host published research datasets.
The connector supports public installations that respond to the standard Dataverse API.
You can find a list of known public Dataverse instances on the <a href="https://dataverse.org/installations" target="_blank" rel="noopener noreferrer">Dataverse Website</a>.

**Explore**

- Paste a Dataverse, collection, or dataset URL in the *Explore* bar.
- Browse collections and datasets directly within OnDemand Loop.
- Search dataset files using Dataverse's API.

**Download**

- Download individual files from public datasets.
- Files must be available without authentication and under 10&nbsp;GB in size.
- Checksums are verified after download.

**Upload**

- Requires a Dataverse API token.
- Upload to an existing dataset or create a new dataset inside a collection.
- Files are transferred using the Dataverse API and verified with checksums.

## Known Dataverse Releases

| Version | Release Date   | Status              |
|---------|----------------|---------------------|
| 4.20    | 2020‑04‑06     | ❌ Not supported     |
| 5.12.1  | 2022‑11‑04     | ⚠️ Pending testing   |
| 5.13    | 2023‑02‑14     | ⚠️ Pending testing   |
| 5.14    | 2023‑08‑04     | ⚠️ Pending testing   |
| 6.0     | 2023‑09‑08     | ⚠️ Pending testing   |
| 6.1     | 2023‑12‑12     | ⚠️ Pending testing   |
| 6.2     | 2024‑04‑01     | ⚠️ Pending testing   |
| 6.3     | 2024‑07‑03     | ⚠️ Pending testing   |
| 6.4     | 2024‑09‑30     | ⚠️ Pending testing   |
| 6.5     | 2024‑12‑12     | ✅ Supported         |
| 6.6     | 2025‑03‑18     | ✅ Supported         |

!!! note

    ✅ Supported = Confirmed compatible and actively maintained  
    ⚠️ Pending testing = Not yet verified with OnDemand Loop  
    ❌ Not supported = Not compatible or no longer in scope

### Zenodo
Zenodo stores research outputs such as datasets, papers, and software.  
The connector supports the official Zenodo instances:

- <a href="https://zenodo.org" target="_blank" rel="noopener noreferrer">Zenodo Production</a>
- <a href="https://sandbox.zenodo.org" target="_blank" rel="noopener noreferrer">Zenodo Sandbox</a>

Zenodo does not currently expose a version number through its public API.  
We began testing and supporting Zenodo in OnDemand Loop as of **June 2025** and will continue to validate compatibility with future Zenodo API updates.

**Explore**

- Search Zenodo records from the *Repositories* menu.
- Paste a record URL in the *Explore* bar to view metadata and files.

**Download**

- Download files attached to a public Zenodo record.

**Upload**

- Requires a personal access token.
- Uploads target a *draft deposition* (existing or newly created in Zenodo).
- Files are streamed directly to the deposition's bucket via HTTP PUT.


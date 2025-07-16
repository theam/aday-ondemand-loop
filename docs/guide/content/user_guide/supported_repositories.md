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

### Zenodo
Zenodo stores research outputs such as datasets, papers, and software. The connector supports the official Zenodo instances:

- <a href="https://zenodo.org" target="_blank" rel="noopener noreferrer">Zenodo Production</a>
- <a href="https://sandbox.zenodo.org" target="_blank" rel="noopener noreferrer">Zenodo Sandbox</a>

**Explore**

- Search Zenodo records from the *Repositories* menu.
- Paste a record URL in the *Explore* bar to view metadata and files.

**Download**

- Download files attached to a public Zenodo record.

**Upload**

- Requires a personal access token.
- Uploads target a *draft deposition* (existing or newly created in Zenodo).
- Files are streamed directly to the deposition's bucket via HTTP PUT.


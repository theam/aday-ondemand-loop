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

### Known Dataverse Releases

```
dataverse_versions:
  - version: 4.20    - ⚠️ Partial Support
  - version: 5.0     - ⏳ Testing pending
  - version: 5.2     - ⏳ Testing pending
  - version: 5.3     - ⏳ Testing pending
  - version: 5.5     - ⏳ Testing pending
  - version: 5.6     - ⏳ Testing pending
  - version: 5.8     - ⏳ Testing pending
  - version: 5.9     - ⏳ Testing pending
  - version: 5.10.1  - ⚠️ Partial Support
  - version: 5.11.1  - ⏳ Testing pending
  - version: 5.12    - ⏳ Testing pending
  - version: 5.12.1  - ⏳ Testing pending
  - version: 5.13    - ⏳ Testing pending
  - version: 5.14    - ⏳ Testing pending
  - version: 6.0     - 🟢 Minor UI Issues
  - version: 6.1     - 🟢 Minor UI Issues
  - version: 6.2     - ✅ Supported
  - version: 6.3     - ✅ Supported
  - version: 6.4     - ✅ Supported
  - version: 6.5     - ✅ Supported
  - version: 6.6     - ✅ Supported - Reference Implementation

```

!!! note "Supported Capabilities"

    **✅ Supported**  
    Fully tested and confirmed compatible with OnDemand Loop. Actively maintained.

    **🟢 Minor UI Issues**  
    All core functionality works — browsing, downloading, and uploading —
    but some UI elements may be missing metadata or render inconsistently.

    **⚠️ Partial Support**  
    Core features like browsing and downloading work. Upload functionality may be limited or broken.
    Some UI elements may be incomplete or missing.

    **⏳ Testing Pending**  
    Detected in the wild but not yet tested with OnDemand Loop.

    **❌ Not Supported**  
    Known to be incompatible or out of scope for testing.


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


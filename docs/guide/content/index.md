# OnDemand Loop User Guide

OnDemand Loop is a companion application for [Open OnDemand](https://openondemand.org/) built with a pluggable connector framework to support multiple remote repositories. [Dataverse](https://dataverse.org/) is the first connector and serves as the reference implementation, with others like Zenodo possible in the future.

You organise your work using **projects**. A project groups everything you download from or upload to a specific repository. Inside a project you can create **download files** to pull remote data to the cluster, and **upload bundles** to stage local files for pushing back to a repository.

Each upload bundle is associated with a single dataset in the remote repository. Multiple bundles can exist within the same project so that related uploads remain grouped even when they target different datasets.

## Creating and Managing Projects

Projects keep related downloads and uploads in one place. On the home page press
**Create Project** to generate a new project with a random HPC-themed name. The
project appears in the list and can be renamed using the pencil icon.

Only one project can be active at a time. Use the pin button to set your newly
created project as the active project before adding download files.

Click a project name to open its detail page where you can:

- view and edit project information
- create download requests to fetch data from a remote repository
- create upload bundles for sending data back to a repository
- open the project folder or metadata folder on the cluster
- delete the project when it is no longer needed (files already on disk or in
  remote repositories are not removed)

## Exploring and Selecting a Remote Repository

You can reach a repository either by pasting a URL or by browsing from the
navigation menu. When you already have a direct link to a dataset or record,
click **Explore** in the top bar to open the repository resolver. Paste the URL
and press **Connect**. Loop analyses the address and redirects you to the proper
page for that repository so you can start navigating immediately.

If you prefer to browse first, open the **Repositories** menu in the navigation
bar and pick the connector you want. Choosing **Dataverse** lists available
installations from the hub so you can drill down into collections and datasets.
Selecting **Zenodo** shows a search form to look up records by keyword. In both
cases you are taken to an interface where you can explore, select files, and add
them to your active project.

## Downloading Files

After locating a dataset in a remote repository, select the checkboxes for the
files you want. The **Add Files to Active Project** button becomes active when
at least one file is chosen. Clicking it schedules those files for download
into your current project. If no project is specified, Loop automatically
creates one so the transfer can proceed.

Progress is visible on the project’s **Downloads** tab and on the global
**Downloads** page available from the navigation bar. This page aggregates
downloads from all projects, showing the file name, size, and a status badge.
Active transfers display a progress bar and can be cancelled if needed.

Completed downloads remain on the Downloads page for twenty‑four hours for
reference. They are permanently recorded under each project’s Downloads tab
along with links to open the file location on the cluster.

## Creating an Upload Bundle

From the project details page you can create new upload bundles. Paste the URL of
the repository location you want to upload into and press **Create Upload
Bundle**. Loop analyses the URL using its connector framework and creates a new
bundle whose name is derived from the repository domain.

If the URL points to a collection or dataset the connector presents a dialog to
either choose the target dataset or create a new one. Zenodo depositions and
Dataverse collections are both supported. When a dataset is selected or created
the bundle stores the relevant identifiers so subsequent uploads go to that
location.

An API key is required to push files to the remote repository. If no key has
been provided, the bundle header displays a red badge with an exclamation icon
and a pencil button. Click the pencil to enter the key. You may store the key
globally so other bundles for the same server can reuse it, or save it only for
this bundle.

Once created, the bundle appears as a tab in the project summary with actions to
add files and manage dataset details.

## Adding Local Files to a Bundle

Use the **Add Files** button shown with each bundle to open the file browser.
Browse to the desired folder on the cluster and double‑click a file to stage
it, or drag the entry onto the highlighted drop zone. You can also drag paths
directly from the browser window. Added files appear in the list beneath the
bundle with their size and status.

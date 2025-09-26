# API keys

Some repository features in OnDemand Loop are only available to authenticated users. API keys let the application request restricted content — such as draft datasets or unpublished depositions — from services like Dataverse and Zenodo on your behalf.

Without a repository API key, OnDemand Loop can browse and download only the public versions of datasets that have already been published. Drafts, embargoed records, or private uploads remain invisible, and attempts to load them from the interface will fail.

---

## Getting your Dataverse API token

1. Sign in to your Dataverse installation.
2. Click your user name in the top-right corner and select **API Token** from the menu.
3. If you do not already have a token, click **Create Token**. Otherwise, copy the existing token value.
4. Keep the token secure — treat it like a password. You can regenerate or delete it at any time from the same page.

!!! tip

    Some Dataverse installations label the menu item **My Data > API Token**. The token works across all Dataverse repositories hosted on the same installation.

---

## Getting your Zenodo API key

1. Sign in to [Zenodo](https://zenodo.org/).
2. Open the **Applications** page from the user menu.
3. In the **Personal access tokens** section, click **New token**.
4. Enter a descriptive name (for example, `OnDemand Loop`) and select the scopes required by your workflow. For accessing drafts and uploading files through OnDemand Loop, enable at least the `deposit:actions`, `deposit:write`, and `deposit:read` scopes.
5. Click **Create** and copy the generated token. This value is shown only once; store it securely.

!!! warning

    Zenodo lets you create multiple tokens with different permissions. Remove any tokens you no longer use to reduce risk if a key is ever exposed.

---

## Setting API keys in OnDemand Loop

Once you have the token or key, add it to the corresponding repository connector:

1. In OnDemand Loop, open the **Repositories** drop-down in the navigation bar and choose **Repository Settings**.
2. Select the repository installation you want to configure (for example, a specific Dataverse server or Zenodo).
3. Paste your API token in the field provided for that connector.
4. Click **Save** to store the credentials securely for the current user account.

After you save the key, OnDemand Loop can load draft datasets from Dataverse, view unpublished Zenodo depositions, and perform other actions that require authenticated access. You can remove or update keys at any time from the same settings page.

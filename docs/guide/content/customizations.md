# Customizations

OnDemand Loop ships with sensible defaults for both the in-app navigation bar
and its entry inside the Open OnDemand dashboard. Administrators can override
these defaults to align the experience with local branding, terminology, and
menu organization.

### Open OnDemand navigation menu (`manifest.yml`)

The `manifest.yml` file that accompanies the application controls how OnDemand
Loop appears inside the broader Open OnDemand interface. Administrators can
adjust the following attributes:

- **Application name and description** displayed to users
- **Menu category placement** (e.g., Files, Interactive Apps, custom
  categories)
- **Icons, subcategories, and window behavior** for the application shortcut

#### Default configuration

```yaml
---
name: OnDemand Loop
category: Files
description: |-
  Transfer files from and to remote repositories like Dataverse.
icon: fa://copy
new_window: false
```

#### Example customizations

```yaml
# Place in Interactive Apps menu:
---
name: OnDemand Loop
category: Interactive Apps
subcategory: Data Transfer
description: |-
  Transfer files from and to remote repositories like Dataverse.
icon: fa://exchange-alt
new_window: false
```

```yaml
# Create custom Data Tools menu:
---
name: OnDemand Loop
category: Data Tools
description: |-
  Transfer files from and to remote repositories like Dataverse.
icon: fa://database
new_window: true
```

!!! tip "Navigation best practices"
    - Reuse existing categories when possible to avoid menu proliferation.
    - Choose descriptive `subcategory` values to group related applications.
    - Test navigation changes with end users to ensure intuitive placement.
    - Coordinate with other application deployments for consistent categorization.

### Application navigation bar overrides

To customize the navigation bar at the top of the application, add a `navigation` key to any YAML file inside `/etc/loop/config/loop.d`. Configuration entries can hide or replace existing items, introduce brand-new links, or add dropdown menus with arbitrary depth.

#### Navigation item types

The navigation system recognizes the following item types:

- **`nav_link`** – standalone links that direct users to a URL
- **`nav_menu`** – dropdown menu containers with nested items
- **`nav_label`** – display-only entries for headings or status indicators

### `nav_link`

A standalone link that directs users to a URL.

```yaml
navigation:
  - id: "nav-projects"
    label: "My Projects"
    url: "/projects"
    position: 1
    alignment: "left"
    icon: "bs://bi-folder"
    new_tab: false
```

**Attributes**

- `id` – unique identifier used to update or hide an existing items
- `label` – text rendered inside the navbar
- `url` – destination path
- `position` – order within its alignment group
- `alignment` – "left" (default) or "right"
- `icon` – optional Bootstrap (`bs://`) or connector (`connector://`) icon
- `new_tab` – open in a new window when `true`
- `hidden` – hide the item when `true`, show when `false` (default)

### `nav_label`

Items without a `url` or nested `items` automatically render as labels. Labels
can highlight the application name, status indicators, or short instructions.

```yaml
navigation:
  - id: "status-display"
    label: "System Status"
    position: 2
    alignment: "right"
    icon: "bs://bi-activity"
```

### `nav_menu`

A parent item that renders nested entries in a dropdown.

```yaml
navigation:
  - id: "repositories"
    label: "Repositories"
    position: 2
    alignment: "left"
    icon: "bs://bi-database"
    items:
      - id: "nav-dataverse"
        label: "Dataverse"
        url: "/dataverse"
        icon: "connector://dataverse"
        position: 1
      - id: "nav-zenodo"
        label: "Zenodo"
        url: "/zenodo"
        icon: "connector://zenodo"
        position: 2
      - id: "separator"
        label: "---"
        position: 3
      - id: "nav-settings"
        label: "Settings"
        url: "/settings"
        icon: "bs://bi-gear"
        position: 4
```

Nested entries can be:

- **`nav_menu_link`** – links inside dropdown menus
- **`nav_menu_label`** – headers rendered as plain text
- **`nav_menu_divider`** – separators (use `label: "---"`)

### Advanced configuration examples

Use the following reference snippets to compose more elaborate menus. Mix and
match entries, update `id` values to override defaults, and mark any entry with
`hidden: true` to stage future releases without exposing the item yet.

#### Example 1 – complete left-aligned navigation

```yaml
navigation:
  - id: "nav-home"
    label: "Home"
    url: "/"
    position: 1
    alignment: "left"
    icon: "bs://bi-house"

  - id: "nav-projects"
    label: "Projects"
    url: "/projects"
    position: 2
    alignment: "left"
    icon: "bs://bi-folder"

  - id: "tools-menu"
    label: "Tools"
    position: 3
    alignment: "left"
    items:
      - id: "nav-upload"
        label: "Upload Files"
        url: "/upload"
        icon: "bs://bi-upload"
        position: 1
      - id: "nav-download"
        label: "Download Status"
        url: "/downloads"
        icon: "bs://bi-download"
        position: 2
      - id: "tools-separator"
        label: "---"
        position: 3
      - id: "nav-analytics"
        label: "Analytics"
        url: "/analytics"
        icon: "bs://bi-graph-up"
        position: 4
```

#### Example 2 – right-aligned user menu

```yaml
navigation:
  - id: "user-menu"
    label: "User Account"
    position: 1
    alignment: "right"
    icon: "bs://bi-person-circle"
    items:
      - id: "nav-profile"
        label: "Profile"
        url: "/profile"
        icon: "bs://bi-person"
        position: 1
      - id: "nav-settings"
        label: "Settings"
        url: "/settings"
        icon: "bs://bi-gear"
        position: 2
      - id: "user-separator"
        label: "---"
        position: 3
      - id: "nav-logout"
        label: "Logout"
        url: "/logout"
        icon: "bs://bi-box-arrow-right"
        position: 4

  - id: "help-link"
    label: "Help"
    url: "/help"
    position: 2
    alignment: "right"
    new_tab: true
    icon: "bs://bi-question-circle"
```

#### Example 3 – mixed navigation with custom partials

```yaml
navigation:
  - id: "nav-dashboard"
    label: "Dashboard"
    url: "/dashboard"
    position: 1
    alignment: "left"
    icon: "bs://bi-speedometer2"

  - id: "repositories"
    label: "Repositories"
    position: 2
    alignment: "left"
    items:
      - id: "repo-header"
        label: "External Repositories"
        position: 1
      - id: "nav-dataverse"
        label: "Dataverse"
        url: "/connect/dataverse"
        icon: "connector://dataverse"
        position: 2
      - id: "nav-zenodo"
        label: "Zenodo"
        url: "/connect/zenodo"
        icon: "connector://zenodo"
        position: 3

  - id: "search-widget"
    label: "Search"
    partial: "search_form"
    position: 1
    alignment: "right"

  - id: "status-display"
    label: "System Status"
    position: 2
    alignment: "right"
    icon: "bs://bi-activity"
```

#### Example 4 – hidden items and conditional display

```yaml
navigation:
  - id: "nav-admin"
    label: "Admin Panel"
    url: "/admin"
    position: 10
    alignment: "right"
    icon: "bs://bi-shield-lock"
    hidden: true

  - id: "dev-tools"
    label: "Development"
    position: 20
    alignment: "right"
    hidden: false
    items:
      - id: "nav-logs"
        label: "View Logs"
        url: "/logs"
        icon: "bs://bi-file-text"
        position: 1
      - id: "nav-debug"
        label: "Debug Info"
        url: "/debug"
        icon: "bs://bi-bug"
        position: 2
        hidden: true
```

### Icon reference

- **Bootstrap icons** – use the format `bs://bi-icon-name` (e.g.,
  `bs://bi-house`, `bs://bi-gear`)
- **Connector icons** – use `connector://service-name` (e.g.,
  `connector://dataverse`, `connector://zenodo`)
- **Custom assets** – provide a direct asset path (e.g.,
  `/assets/custom-icon.svg`)

### Best practices

1. Use incremental `position` values for predictable ordering within an
   alignment group.
2. Balance the number of left and right aligned items for better visual
   distribution.
3. Keep labels concise yet descriptive.
4. Use separators (`label: "---"`) to group dropdown options.
5. Mark experimental features with `hidden: true` until you are ready to reveal
   them.

Place the YAML snippet alongside other configuration files so it is evaluated
during application initialization.

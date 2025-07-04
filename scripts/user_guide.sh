#!/bin/bash

# Build the user guide with MkDocs
set -e

# Install MkDocs each run so the container can remain lightweight
pip install --quiet mkdocs mkdocs-material

# Build the documentation
# Use an absolute path for the output directory so MkDocs does not
# treat it as a subdirectory of the documentation folder.
SITE_DIR="$(pwd)/site"
mkdocs build -f docs/user_guide/mkdocs.yml --site-dir "$SITE_DIR"

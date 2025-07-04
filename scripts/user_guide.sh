#!/bin/bash

# Build the user guide with MkDocs
set -e

# Install MkDocs each run so the container can remain lightweight
pip install --quiet mkdocs mkdocs-material

# Build the documentation
mkdocs build -f docs/user_guide/mkdocs.yml --site-dir site

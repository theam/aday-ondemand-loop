#!/bin/bash

# Build the user guide with MkDocs
set -e

# Build the documentation
mkdocs build -f docs/user_guide/mkdocs.yml --site-dir site

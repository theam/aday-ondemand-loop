#!/bin/bash
set -e

OUTPUT="application/release_notes.md"

# Find the last tag (do not assume current tag)
previous_tag=$(git tag --sort=-creatordate | head -n 1)

echo "Generating release notes from $previous_tag to HEAD"

escaped_previous=$(printf '%q' "$previous_tag")

{
  echo "## What’s Changed"
  echo ""

  # ✨ Features
  features=$(git log "$escaped_previous..HEAD" --pretty=format:"%s|%h" | grep '^feat:' || true)
  if [ -n "$features" ]; then
    echo "### ✨ Features"
    echo "$features" | while IFS='|' read -r subject hash; do
      echo "- ${subject#feat:} ($hash)"
    done
    echo ""
  fi

  # 🐛 Bug Fixes
  fixes=$(git log "$escaped_previous..HEAD" --pretty=format:"%s|%h" | grep '^fix:' || true)
  if [ -n "$fixes" ]; then
    echo "### 🐛 Bug Fixes"
    echo "$fixes" | while IFS='|' read -r subject hash; do
      echo "- ${subject#fix:} ($hash)"
    done
    echo ""
  fi

  # 🧩 Other Changes
  misc=$(git log "$escaped_previous..HEAD" --pretty=format:"%s|%h" | grep -vE '^(feat|fix):' || true)
  if [ -n "$misc" ]; then
    echo "### 🧩 Other Changes"
    echo "$misc" | while IFS='|' read -r subject hash; do
      echo "- $subject ($hash)"
    done
    echo ""
  fi
} > "$OUTPUT"

echo "✅ Release notes written to $OUTPUT"

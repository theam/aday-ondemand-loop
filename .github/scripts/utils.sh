#!/usr/bin/env bash
set_output() {
  local name="$1"
  local value="$2"
  local fallback="${3:-_not provided_}"
  if [[ -z "$value" ]]; then
    value="$fallback"
  fi

  echo "::notice title=Output::$name::${value}"
  echo "${name}<<EOF" >> "$GITHUB_OUTPUT"
  echo "$value" >> "$GITHUB_OUTPUT"
  echo "EOF" >> "$GITHUB_OUTPUT"
}

# Get the path to the cached issue JSON file (always returns the same path)
get_issue_json_path() {
  echo "/tmp/gh_issue.json"
}

# Store issue JSON in a temp file under /tmp (reuses get_issue_json_path)
cache_issue_json() {
  local issue_number="$1"
  local repo="$2"
  local cache_file
  cache_file=$(get_issue_json_path)

  if [[ ! -f "$cache_file" ]]; then
    gh issue view "$issue_number" --repo "$repo" --json title,state,assignees,comments > "$cache_file"
  fi
}


validate_issue_state_and_assignment() {
  echo "🔎 Validating issue..."

  local json_file
  json_file=$(get_issue_json_path)

  if [[ ! -f "$json_file" ]]; then
    echo "❌ Cached issue JSON not found at $json_file"
    set_output "message" "❌ **Internal error: Issue JSON not cached.**"
    return 1
  fi

  # Check if issue is open
  local state
  state=$(jq -r '.state' "$json_file")
  if [[ "$state" != "OPEN" ]]; then
    set_output "message" "❌ **Issue must be open. Current state: $state**"
    return 1
  fi

  # Check if issue is assigned
  local assignee_count
  assignee_count=$(jq -r '.assignees | length' "$json_file")
  if [[ "$assignee_count" -eq 0 ]]; then
    set_output "message" "❌ **Issue must be assigned to at least one user.**"
    return 1
  fi

  echo "✅ Issue is open and assigned."
}

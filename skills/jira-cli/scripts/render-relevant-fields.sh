#!/usr/bin/env bash
# Render implementation-relevant custom Jira fields from `jira issue view KEY --raw`.

set -euo pipefail

config_path="${JIRA_CONFIG_FILE:-$HOME/.config/.jira/.config.yml}"
pattern="${JIRA_RELEVANT_FIELD_PATTERN:-acceptance|criteria|definition[[:space:]]+of[[:space:]]+done|(^|[^[:alnum:]])dod([^[:alnum:]]|$)|requirements?|scope|user[[:space:]]+story|deliverables?|success[[:space:]]+criteria}"

if ! command -v jq >/dev/null 2>&1; then
  printf 'jira-cli: jq is required to render relevant Jira fields.\n' >&2
  exit 127
fi

if ! command -v yq >/dev/null 2>&1; then
  printf 'jira-cli: Mike Farah yq is required to read %s.\n' "$config_path" >&2
  exit 127
fi

if [ ! -f "$config_path" ]; then
  printf 'jira-cli: Jira config not found at %s. Cannot map custom fields to names.\n' "$config_path" >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

raw_json="$tmpdir/issue.json"
entries_jsonl="$tmpdir/custom-fields.jsonl"

cat >"$raw_json"

jq -c '
  def nonempty:
    if . == null then false
    elif type == "string" then length > 0
    elif type == "array" then length > 0
    elif type == "object" then length > 0
    else true end;

  (.fields // {})
  | to_entries[]
  | select(.key | test("^customfield_[0-9]+$"))
  | select(.value | nonempty)
' "$raw_json" >"$entries_jsonl"

if [ ! -s "$entries_jsonl" ]; then
  printf 'No non-empty custom fields found.\n'
  exit 0
fi

printed=0

while IFS= read -r entry; do
  key="$(jq -r '.key' <<<"$entry")"
  name="$key"

  while IFS= read -r candidate; do
    if [ -n "$candidate" ] && [ "$candidate" != "null" ]; then
      name="$candidate"
      break
    fi
  done < <(yq -r ".issue.fields.custom[] | select(.key == \"$key\") | .name" "$config_path" 2>/dev/null || true)

  if ! printf '%s\n' "$name" | grep -Eiq "$pattern"; then
    continue
  fi

  value="$(jq -r '
    def render:
      if . == null then ""
      elif type == "string" then .
      elif type == "number" or type == "boolean" then tostring
      elif type == "array" then map(render) | map(select(. != "")) | join("\n")
      elif type == "object" then
        if has("text") then .text
        elif has("value") then .value | render
        elif has("displayName") then .displayName
        elif has("name") then .name
        elif has("content") then .content | render
        else tojson end
      else tostring end;
    .value | render
  ' <<<"$entry")"

  if [ -z "$value" ]; then
    continue
  fi

  if [ "$printed" -eq 0 ]; then
    printf '## Relevant Jira fields\n\n'
  fi

  printf '### %s (%s)\n%s\n\n' "$name" "$key" "$value"
  printed=1
done <"$entries_jsonl"

if [ "$printed" -eq 0 ]; then
  printf 'No relevant non-empty custom fields found.\n'
fi

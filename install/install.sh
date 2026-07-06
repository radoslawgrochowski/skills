#!/usr/bin/env bash
# Install skills declared in skills.nix into a destination directory.
#
# Expects SKILLS_LIST_JSON to point at the JSON manifest produced by
# resolve.nix (one record per skill: { src, name, owner, repo, path }).

set -euo pipefail

dest="${HOME}/.agents/skills"
dry_run=0
assume_yes=0

while [ $# -gt 0 ]; do
  case "$1" in
    --yes|-y) assume_yes=1; shift ;;
    --dry-run) dry_run=1; shift ;;
    --dest) dest="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: install [--yes|-y] [--dry-run] [--dest PATH]"
      echo
      echo "Copies skills declared in skills.nix into a destination directory"
      echo "after a preview and confirmation prompt."
      echo
      echo "Flags:"
      echo "  --yes, -y     Skip the confirmation prompt."
      echo "  --dry-run     Print the preview only; write nothing."
      echo "  --dest PATH   Override the install directory (default ~/.agents/skills)."
      exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

: "${SKILLS_LIST_JSON:?SKILLS_LIST_JSON must point at the skills manifest}"

mapfile -t names  < <(jq -r '.[].name'  "$SKILLS_LIST_JSON")
mapfile -t owners < <(jq -r '.[].owner' "$SKILLS_LIST_JSON")
mapfile -t repos  < <(jq -r '.[].repo'  "$SKILLS_LIST_JSON")
mapfile -t paths  < <(jq -r '.[].path'  "$SKILLS_LIST_JSON")
mapfile -t srcs   < <(jq -r '.[].src'   "$SKILLS_LIST_JSON")

count=${#names[@]}
if [ "$count" -eq 0 ]; then
  echo "No skills to install."
  exit 0
fi

# Display path with $HOME abbreviated to ~ for the preview only.
display_dest="$dest"
if [ -n "${HOME:-}" ] && [[ "$display_dest" == "${HOME}"* ]]; then
  display_dest="~${display_dest#"${HOME}"}"
fi

printf '%-20s %-50s %s\n' "SKILL" "SOURCE" "DEST"
for i in "${!names[@]}"; do
  printf '%-20s %-50s %s\n' \
    "${names[i]}" \
    "${owners[i]}/${repos[i]}:${paths[i]}" \
    "$display_dest/${names[i]}"
done
echo
if [ "$count" -eq 1 ]; then
  echo "1 skill."
else
  echo "$count skills."
fi

if [ "$dry_run" -eq 1 ]; then
  exit 0
fi

if [ "$assume_yes" -eq 0 ]; then
  read -r -p "Proceed? [y/N] " ans
  case "${ans:-}" in
    y|Y|yes|YES) ;;
    *) echo "Aborted."; exit 0 ;;
  esac
fi

for i in "${!names[@]}"; do
  target="$dest/${names[i]}"
  mkdir -p "$target"
  chmod -R u+w "$target"
  cp -aL "${srcs[i]}/." "$target/"
  chmod -R u+w "$target"
  echo "+ ${names[i]}  $target"
done

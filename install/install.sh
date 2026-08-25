#!/usr/bin/env bash
# Install local and external skills plus the OpenCode review command.
#
# Expects SKILLS_LIST_JSON to point at the JSON manifest produced by resolve.nix
# (one record per skill: { src, name, source, path }).

set -euo pipefail

dest="${HOME}/.agents/skills"
command_dest="${HOME}/.config/opencode/commands"
dry_run=0
assume_yes=0

while [ $# -gt 0 ]; do
  case "$1" in
    --yes|-y) assume_yes=1; shift ;;
    --dry-run) dry_run=1; shift ;;
    --dest) dest="$2"; shift 2 ;;
    --command-dest) command_dest="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: install [--yes|-y] [--dry-run] [--dest PATH] [--command-dest PATH]"
      echo
      echo "Copies local and external skills plus the OpenCode review command"
      echo "after a preview and confirmation prompt."
      echo
      echo "Flags:"
      echo "  --yes, -y          Skip the confirmation prompt."
      echo "  --dry-run          Print the preview only; write nothing."
      echo "  --dest PATH        Override the skills directory (default ~/.agents/skills)."
      echo "  --command-dest PATH  Override the OpenCode commands directory"
      echo "                       (default ~/.config/opencode/commands)."
      exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

: "${SKILLS_LIST_JSON:?SKILLS_LIST_JSON must point at the skills manifest}"
: "${REVIEW_COMMAND_SRC:?REVIEW_COMMAND_SRC must point at review.md}"

mapfile -t names   < <(jq -r '.[].name'   "$SKILLS_LIST_JSON")
mapfile -t sources < <(jq -r '.[].source' "$SKILLS_LIST_JSON")
mapfile -t srcs    < <(jq -r '.[].src'    "$SKILLS_LIST_JSON")

count=${#names[@]}
if [ "$count" -eq 0 ]; then
  echo "No skills to install."
  exit 0
fi

# Display paths with $HOME abbreviated to ~ for the preview only.
display_path() {
  local value="$1"
  if [ -n "${HOME:-}" ] && [[ "$value" == "${HOME}"* ]]; then
    value="~${value#"${HOME}"}"
  fi
  printf '%s' "$value"
}

display_dest="$(display_path "$dest")"
display_command_dest="$(display_path "$command_dest")"
command_target="$command_dest/review.md"

if [ -L "$command_target" ]; then
  echo "Refusing to replace symlink: $command_target" >&2
  exit 1
fi
if [ -e "$command_target" ] && [ ! -f "$command_target" ]; then
  echo "Refusing to replace non-file: $command_target" >&2
  exit 1
fi

printf '%-20s %-50s %s\n' "SKILL" "SOURCE" "DEST"
for i in "${!names[@]}"; do
  printf '%-20s %-50s %s\n' \
    "${names[i]}" \
    "${sources[i]}" \
    "$display_dest/${names[i]}"
done
echo
command_action="add"
if [ -e "$command_target" ]; then
  command_action="replace"
fi

printf '%-20s %-50s %s\n' "COMMAND" "ACTION" "DEST"
printf '%-20s %-50s %s\n' "review" "$command_action" "$display_command_dest/review.md"
echo

if [ "$count" -eq 1 ]; then
  echo "1 skill and 1 OpenCode command."
else
  echo "$count skills and 1 OpenCode command."
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

mkdir -p "$command_dest"
command_tmp="$(mktemp "$command_dest/.review.md.XXXXXX")"
trap 'rm -f "$command_tmp"' EXIT
cp -aL "$REVIEW_COMMAND_SRC" "$command_tmp"
chmod u+w "$command_tmp"
mv -f "$command_tmp" "$command_target"
trap - EXIT
echo "+ review  $command_target"

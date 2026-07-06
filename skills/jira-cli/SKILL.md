---
name: jira-cli
description: Jira CLI issue lookup and implementation context. Use when the user mentions Jira, gives a ticket key like ABC-123, shares a Jira issue URL, or asks to implement/fix/build from a ticket; CLI-only, expands relevant configured custom fields for implementation work.
---

# Jira CLI

Use the `jira` command for terminal-first Jira issue lookups. Never use Jira REST APIs from this skill.

## Workflow

1. Extract issue keys from the user's prompt. If the input is a Jira URL, use the final issue key segment such as `ABC-123`.

Completion criterion: you have at least one issue key before querying Jira. If there are multiple keys, keep outputs separated by issue.

2. Show the issue in readable plain text:

```sh
jira issue view ABC-123 --plain
```

Completion criterion: the user can see the ticket summary, status, assignee, description, and the fields rendered by `jira`.

3. For implementation work, expand relevant custom fields from the raw issue payload:

```sh
jira issue view ABC-123 --raw | bash "$HOME/.agents/skills/jira-cli/scripts/render-relevant-fields.sh"
```

Implementation work includes requests to implement, fix, build, investigate, estimate, plan, or verify against a ticket. The helper maps non-empty `customfield_*` values through `~/.config/.jira/.config.yml` and renders fields whose configured names look relevant: acceptance criteria, definition of done, requirements, scope, user story, deliverables, and success criteria.

Completion criterion: if relevant non-empty fields exist, show them after the plain issue output; if none exist, say that no relevant non-empty custom fields were found.

4. For simple lookup requests, keep the answer concise. Do not expand raw custom fields unless the user asks for implementation context or the plain output is clearly missing ticket requirements; if extra configured fields look useful, offer to expand them.

Completion criterion: the answer contains the requested Jira facts without unnecessary raw-field noise.

## Field Catalog

- Field IDs are not stable enough to hardcode in the skill. Discover field names from `~/.config/.jira/.config.yml`.
- Require Mike Farah `yq` (`pkgs.yq-go`) and `jq` for custom-field expansion.
- If `~/.config/.jira/.config.yml` is missing or stale, explain that the Jira CLI field catalog may need refreshing. Do not run `jira init --force` or any config-changing command without explicit user approval.

## Command Safety

- Prefer read-only commands: `jira issue view`, `jira issue list`, `jira issue --help`, and `jira --help`.
- If the user asks to change Jira state, inspect `jira issue --help` and the relevant subcommand help first, then ask for confirmation before running create, edit, move, assign, comment, worklog, link, unlink, clone, or delete commands.
- Use the issue key exactly as given or extracted. If the prompt is ambiguous, inspect the issue before inferring work from the key alone.

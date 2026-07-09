---
name: jujutsu
description: Jujutsu jj version control safety and workflow. Use when the user mentions jj, Jujutsu, .jj/, or asks for status, diff, commit, rebase, squash, bookmark, fetch, push, or other VCS work inside a Jujutsu repository.
---

# Jujutsu

Use `jj` for version-control operations in repositories that contain `.jj/`. Jujutsu has no staging area: the working copy is a mutable commit named `@`, and changes are snapshotted by normal `jj` commands.

## Safety Rules

- In a `.jj/` repo, use `jj` for mutations. Do not run mutating `git` commands such as `git add`, `git commit`, `git checkout`, `git reset`, `git merge`, or `git rebase` unless the user explicitly asks for Git interop and you have inspected the repo state first.
- Read-only Git commands are acceptable when useful: `git log`, `git diff`, `git show`, `git blame`, and `git grep`.
- Use `jj --no-pager` for commands that print output, for example `jj log --no-pager`, `jj diff --no-pager --git`, and `jj show --no-pager @`. The `--no-pager` flag is global and works both before and after the subcommand.
- Use inline messages with `-m` to avoid editor prompts: `jj desc -m "Message"`, `jj new -m "Message"`, `jj squash -m "Message"`.
- Before setting a change description, inspect recent descriptions and match the repository convention. If recent history uses Conventional Commits, use that style, for example `feat: add payment validation` or `fix: handle missing amount`.
- Avoid interactive commands in agent sessions: `jj split`, `jj squash -i`, `jj resolve`, and commands that open an editor.
- After mutating history or the working copy, verify with `jj status` and inspect the relevant diff or log before reporting success.

## Workflow

Inspect state before changing it:

```sh
jj status
jj log --no-pager
jj diff --no-pager --git
```

Create or describe work:

```sh
jj log --no-pager --limit 10
jj new -m "feat: add payment validation"
jj desc -m "feat: add payment validation"
```

Move around the stack:

```sh
jj edit <change-id>
jj edit @-
jj next --edit
```

Refine changes:

```sh
jj squash -m "Combined message"
jj absorb
jj rebase -d <destination>
jj undo
```

Work with Git remotes through jj:

```sh
jj git fetch
jj bookmark list --no-pager
jj bookmark create <name> -r @
jj bookmark move <name> --to @
jj git push --bookmark <name>
```

Only push when the user explicitly asks. Before pushing, verify that the bookmark points at the intended change; bookmarks do not automatically advance like Git branches.

## Gotchas

- There is no staging area and no normal `jj commit` step. Use `jj new`, `jj desc`, `jj squash`, or `jj absorb` to shape commits.
- Prefer change IDs over commit IDs when referencing revisions; change IDs stay stable when commits are rewritten.
- Use `@-` for the parent of `@`, not `@~1`.
- Use `|` for revset unions, not commas: `jj log --no-pager -r "abc | def"`.
- Template fields are Jujutsu fields, not Git fields. Use `description`, not `desc`.
- If a command has surprising results, check `jj op log --no-pager`; recover the previous operation with `jj undo` when appropriate.

---
name: code-review
description: Code review for working-copy changes, revisions, bookmarks, branches, and Bitbucket pull requests. Use when the user asks to review code, a change, a branch, or a PR; uses Jujutsu first, Jira requirements, repository documentation, REVIEW.local.md, and existing Bitbucket reviewer comments.
---

# Code Review

Review changes and report actionable findings. This workflow is read-only: do not edit source files, apply fixes, update `REVIEW.local.md`, or change Jira, Bitbucket, or version-control state.

## Required References

Read these files before the review:

- `references/review-criteria.md` for the review axes, evidence rules, output, and `REVIEW.local.md` proposals.
- `references/bitbucket-pr-context.md` before any Bitbucket MCP call.

## Workflow

### 1. Pin the review target

Interpret the command input as one of: no arguments, a revision/change ID, an explicit comparison base, a bookmark or branch to review, or a Bitbucket PR URL/`pr:<id>`. Ask one short question if the input remains ambiguous after inspection. A bare bookmark or branch is not automatically a comparison base.

Prefer Jujutsu when `.jj/` exists:

- No arguments: inspect `jj status`, `jj log --no-pager -r @`, and `jj diff --no-pager --git -r @`.
- One revision or change ID: inspect `jj show --no-pager --git <revision>`.
- Explicit comparison base, such as "since main": resolve it, list `jj log --no-pager -r '<base>..@'`, and compare `jj diff --no-pager --git --from 'fork_point(<base>|@)' --to @`.
- Bookmark or branch target: get its destination base from the related PR. Compare `jj diff --no-pager --git --from 'fork_point(<base>|<target>)' --to <target>`. When no PR exists, first resolve whether the input is a target or base; if it is a target, ask for its destination base.

Quote user-supplied revsets safely. Confirm that the target resolves and the diff is not empty before continuing.

When `.jj/` is absent, use read-only Git inspection as the fallback:

- No arguments: inspect `git status --short`, `git diff`, and `git diff --cached`; include full untracked files.
- One commit: inspect `git show <revision>`.
- Explicit comparison base: inspect `git log <base>..HEAD --oneline` and `git diff <base>...HEAD`.
- Branch target: get its destination branch from the related PR, or ask for the destination base when no PR exists. Then inspect `git log <base>..<target> --oneline` and `git diff <base>...<target>`.

Do not recommend Git when Jujutsu is available. Never use mutating VCS commands during a review.

Completion criterion: the exact reviewed revision range and every changed or untracked file are known.

### 2. Load repository context

Read all applicable `CONTEXT.md` and `AGENTS.md` files. Read `REVIEW.local.md` when present; treat it as local context even when version control does not list it. Inspect top-level `/docs`, other documented standards, and documentation linked from `REVIEW.local.md`. Select the documents relevant to the changed paths and behavior.

Read every changed file in full. Inspect nearby tests and similar implementations before judging whether a change fits the codebase. Review only changed behavior or pre-existing behavior made unsafe by the change.

Completion criterion: every changed file has full-file context, and every applicable local rule or relevant documentation source is listed.

### 3. Load the specification

Find a Jira key in this order:

1. User input.
2. Bitbucket PR title or source branch.
3. Reviewed change descriptions or commit messages.

When a Jira key exists, load the `jira-cli` skill and use its read-only implementation-context workflow. If no specification exists, continue and report that the Spec axis has no source.

Completion criterion: the review has a cited specification source or records `No specification available`.

### 4. Check Bitbucket context

On every review, try to find the related open Bitbucket PR by following `references/bitbucket-pr-context.md`. Continue the local review when repository identifiers are unavailable or no matching PR exists, unless the user explicitly requested a PR review.

Inspect existing PR comments for suggestions from other reviewers. Investigate each suggestion against the current diff and repository context. Ignore non-issues. Report a valid suggestion as pending user confirmation; never apply it or reply to the comment.

Completion criterion: a matching PR and its comments were inspected, no PR was found, or the exact missing identifier is recorded.

### 5. Run independent review axes

Run Correctness, Standards, and Spec reviews as independent parallel sub-agents when available. Give each agent the pinned target, changed-file list, relevant full-file context, and only the reference sources needed for its axis. If sub-agents are unavailable, perform the axes sequentially and keep their findings separate.

Each finding must include a changed file and line, severity, realistic failure scenario, evidence, and a direct fix direction. Investigate uncertain points before reporting them. Do not report formatting or type errors that established tooling reports directly.

Completion criterion: all three axes return findings or an explicit pass/no-source result.

### 6. Validate and report

Recheck every candidate finding against the full file, specification, repository rules, and similar code. Remove duplicates, pre-existing issues unrelated to the change, speculative concerns, and style preferences without a documented basis.

Use the report structure in `references/review-criteria.md`. Findings are the primary output. Keep valid existing PR suggestions separate and ask for confirmation without changing files. If `REVIEW.local.md` is missing or stale, include a minimal proposed patch for durable context and ask before a later implementation run writes it.

Completion criterion: every reported issue is actionable and evidence-backed, and the review made no repository or remote-state changes.

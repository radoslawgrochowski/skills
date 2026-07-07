---
name: project-tooling-audit
description: Project tooling audit for CI, release automation, formatters, linters, Renovate, Knip, TypeScript, Nix, React, Playwright, Jest, and Vitest. Use when the user asks to audit, check, investigate, review, or compare a project's tooling against expected project standards.
---

# Project Tooling Audit

Use this skill to inspect a repository's tooling against stack-specific project standards and produce an evidence-backed audit report. This is audit-first: do not add or rewrite tooling configuration unless the user explicitly asks to implement fixes after the audit.

## Required Reference

Read `references/tooling-requirements.md` before auditing. Use it as the recommendation catalog and applicability guide.

## Workflow

1. Establish the audit scope.

Identify the repository root and whether the project is a single package, monorepo, app, library, infra repo, or mixed workspace. If the user names a subproject, audit that scope and still inspect root-level tooling that affects it.

Completion criterion: you can name the audited root and any relevant packages/apps.

2. Detect stacks before judging gaps.

Use read-only evidence from file names and config contents. Inspect relevant manifests and configuration such as `package.json`, workspace files, lockfiles, `tsconfig*`, ESLint and Prettier config, `renovate*`, `knip*`, Jest/Vitest setup, Playwright config, `.github/workflows`, `flake.nix`, `treefmt*`, and formatter/linter scripts.

Completion criterion: list detected stacks, for example TypeScript, JavaScript, React, webapp, reusable UI library, Nix flake, GitHub Actions, published package, or Docker/image release.

3. Classify applicability first.

Do not mark a recommendation as missing until it is applicable. For example, Knip applies to JS/TS projects; `nixfmt` applies when Nix files exist; Playwright e2e applies to webapps; release automation applies when the repo appears to publish artifacts.

Completion criterion: every audited requirement has an applicability reason.

4. Collect evidence.

Use concrete evidence: file paths, package names, scripts, CI jobs, config extends, workflow steps, and test setup files. Treat CI wiring as separate evidence from local configuration. A tool that exists locally but is absent from CI is usually `partial`.

Completion criterion: every `present` or `partial` status has at least one file path or command as evidence.

5. Check organisation configuration without guessing.

Look for organisation signals such as package scopes, internal registries, Git remote orgs, shared config packages, existing `extends` presets, or repository naming. If a project appears to belong to an organisation, check whether organisation-level configs are used for ESLint, TypeScript, Prettier, Renovate presets, and similar tools. Treat Renovate as both dependency automation and an organisation policy/config check. Report `unknown` when the organisation signal exists but the expected shared config package or preset cannot be confirmed from repo evidence.

Completion criterion: organisation-specific findings are evidence-based, not invented.

6. Produce the tooling audit report.

Use the report structure below. Keep findings concise but include enough evidence for another engineer to verify them.

7. Stop after the audit unless asked to fix.

If the user asks for remediation, propose the smallest safe implementation plan first. Do not generate full ESLint, Renovate, Playwright, or CI configs during the audit unless explicitly requested.

## Status Vocabulary

- `present`: the recommendation is satisfied with clear repo evidence.
- `partial`: some setup exists, but it is incomplete, inconsistent across packages, or not wired into CI.
- `missing`: the recommendation is applicable and no satisfying evidence was found.
- `not applicable`: the stack or use case is not detected.
- `unknown`: evidence is insufficient, especially for organisation-specific expectations or external branch protection/required checks.

Use one of these statuses for each requirement. For heuristic recommendations such as Playwright component testing, include a separate recommendation strength such as `recommended` or `consider` in the notes while keeping the requirement status vocabulary unchanged.

## Evidence Rules

- Do not claim `present` without citing paths, scripts, dependency names, or workflow steps.
- Do not claim `missing` until applicability is established.
- Prefer `partial` when a tool exists locally but is not used by CI.
- Prefer `unknown` when the answer depends on branch protection, external organisation policy, unpublished shared packages, or hidden CI settings.
- In monorepos, distinguish root-level tooling from package-level coverage.
- If a config is generated or imported from another repo, report the visible integration point and mark unresolved details as `unknown`.

## Report Structure

Use this structure unless the user asks for a different format:

```markdown
# Project Tooling Audit

## Scope
- Root: `<path>`
- Project shape: `<single package | monorepo | app | library | mixed | unknown>`
- Detected stacks: `<comma-separated list>`

## Executive Summary
- `<highest-impact gap or confirmation>`
- `<second key point>`
- `<third key point>`

## Findings
| Area | Requirement | Status | Evidence | Notes |
| --- | --- | --- | --- | --- |
| CI | Version control and CI exist | present | `.git`, `.github/workflows/main.yml` | CI runs tests and lint |

## Priority Remediation
1. `<highest-value next step>`
2. `<next step>`
3. `<next step>`

## Verification Commands
- `<command that checks existing setup>`
- `<command that should be added or run after remediation>`

## Unknowns
- `<external or policy-dependent item that could not be verified from repo evidence>`
```

Keep `Findings` as the primary section. If there are no gaps, state that explicitly and mention remaining unknowns.

## Common Search Targets

Search for these when relevant:

- Version control and CI: `.git`, `.jj`, `.github/workflows/*`, `.gitlab-ci.yml`, `buildkite.yml`, `azure-pipelines.yml`.
- Project metadata: `README*`, `LICENSE*`, `COPYING*`, `CHANGELOG*`, root `package.json` `license` field.
- JS/TS package tooling: `package.json`, `engines`, `devEngines`, `packageManager`, `pnpm` settings, workspace files, lockfiles, `tsconfig*.json`, `eslint.config.*`, `.eslintrc*`, `prettier.config.*`, `.prettierrc*`.
- Quality tools: `renovate.json`, `.github/renovate.json`, `knip.json`, `knip.ts`, `zizmor`, `actionlint`, `lint-staged`, `lefthook`, `husky`.
- Tests: `jest.config.*`, `vitest.config.*`, setup files, deterministic environment setup, `jest-fail-on-console`, console spies, `@testing-library/*`, Playwright config.
- Nix: `flake.nix`, `flake.lock`, `treefmt.nix`, `treefmt.toml`, `nixfmt`, `nixfmt-rfc-style`, `nixfmt-tree`, `deadnix`, `statix`, `cachix`, `nix develop`, `nix flake check`.
- Web quality: `lighthouse`, `bundlesize`, `size-limit`, `webpack-bundle-analyzer`, `rollup-plugin-visualizer`, `browserslist`.
- Release automation: `.changeset`, `changeset`, `semantic-release`, release workflows, `release-please`, publish scripts, Docker/image release workflows, changelogs, version files.

# Tooling Requirements

Use these recommendations as an audit checklist. They are not blanket mandates. First detect whether each stack or use case applies, then assign `present`, `partial`, `missing`, `not applicable`, or `unknown`.

## Baseline For Every Project

### Project Metadata

Applicability: every source repository.

Expected evidence:

- README or equivalent entry-point documentation such as `README.md`, package docs, or service docs linked from the repo root.
- License declaration through `LICENSE*`, `COPYING*`, or a root `package.json` `license` field for JS packages.
- Changelog policy through `CHANGELOG*`, generated changelog configuration, Changesets, release-please, semantic-release, or documented release notes process.
- README describes what the project is, how to install/run/test it, and any important release or deployment entry points where applicable.

Status guidance:

- `present`: README or equivalent docs exist, license evidence is visible, and changelog/release-notes policy is visible when the project has releases.
- `partial`: README exists but is too sparse for onboarding, license exists only in package metadata without a dedicated license file where one is expected, or changelog policy is unclear for a released project.
- `missing`: no README/equivalent docs, no license evidence, or no changelog/release-notes evidence for a released project.
- `unknown`: license policy is organisation-managed or not visible from repo files.

### Version Control

Applicability: every source repository.

Expected evidence:

- Git or Jujutsu metadata such as `.git` or `.jj`.
- Ignore rules such as `.gitignore` when build outputs, dependencies, or secrets are possible.
- Clear default-branch workflow if visible from local config or docs.

Status guidance:

- `present`: VCS metadata exists and ignore rules are appropriate for detected stacks.
- `partial`: VCS exists but obvious generated artifacts or dependency directories are not ignored.
- `unknown`: branch protection and required checks cannot be verified from local files.

### Continuous Integration

Applicability: every maintained project.

Expected evidence:

- CI configuration such as `.github/workflows/*`, `.gitlab-ci.yml`, Buildkite, CircleCI, Azure Pipelines, or equivalent.
- CI runs the same quality gates developers run locally: format check, lint, typecheck, tests, build, `nix flake check`, or stack equivalents.
- All necessary project commands are checked in CI: install with lockfile enforcement, format check, lint, typecheck, unit/integration tests, e2e/component tests when applicable, build/package checks, security/audit checks, and release dry-run or validation when applicable.
- CI uses pinned or reviewed actions where possible.

Status guidance:

- `present`: CI exists and runs relevant quality gates for detected stacks.
- `partial`: CI exists but skips important local checks, only runs on limited events, or is not aligned with detected tooling.
- `missing`: no CI configuration is found.
- `unknown`: required status checks or branch protection are external and not visible.

### Release And Version Automation

Applicability: repositories that publish artifacts, packages, libraries, CLIs, containers, Nix packages, or versioned deliverables.

Detection signals:

- Package publish metadata or scripts: `publish`, `npm publish`, package `version`, `private: false`.
- `.changeset`, `changeset`, `semantic-release`, `release-please`, `standard-version`, or changelog automation.
- Release workflows, Docker/image publishing, GitHub releases, package registry deployment, or Nix package outputs.

Expected evidence:

- A documented or automated versioning and changelog process.
- CI/release jobs that publish from trusted branches/tags.
- Changesets, semantic-release, release-please, or an equivalent release mechanism for JS packages.

Status guidance:

- `present`: release/version automation is configured and wired to CI or documented release commands.
- `partial`: release tooling exists but CI integration, changelog generation, or publish rules are incomplete.
- `missing`: artifacts appear to be published but no release/version automation is visible.
- `not applicable`: internal app or non-published repo with no release artifacts detected.

Do not flag apps as missing `changesets` or `semantic-release` unless they publish versioned packages or artifacts.

## Formatting

### JavaScript, TypeScript, JSON, Markdown, YAML, CSS

Applicability: JS/TS projects or repos containing these file types.

Expected evidence:

- Prettier or an equivalent formatter configured through `prettier.config.*`, `.prettierrc*`, package scripts, editor config, or CI.
- Formatting scripts such as `format`, `format:check`, or equivalent.
- CI verifies formatting rather than only providing a local write command.

Status guidance:

- `present`: formatter is configured for relevant file types and checked in CI.
- `partial`: formatter exists locally but is not checked in CI, or only covers some relevant file types.
- `missing`: relevant files exist and no formatter evidence is found.

### Nix

Applicability: repos containing `*.nix`, `flake.nix`, or Nix workflows.

Expected evidence:

- `nix fmt` backed by `formatter` in `flake.nix`, `treefmt`, `nixfmt`, `nixfmt-rfc-style`, or `nixfmt-tree`.
- CI runs `nix fmt -- --check`, `treefmt --ci`, `nix fmt`, or another formatting check according to the repo's formatter design.
- Formatter is available in the dev shell or flake outputs.

Status guidance:

- `present`: Nix formatter is configured and CI checks it.
- `partial`: formatter exists but CI does not check it, or formatter is not available through normal dev workflow.
- `missing`: Nix files exist but no Nix formatter is visible.
- `not applicable`: no Nix files or Nix workflow detected.

## Linters And Static Analysis

### JavaScript And TypeScript

Applicability: JS/TS source exists.

Expected evidence:

- ESLint or equivalent static analysis configured through `eslint.config.*`, `.eslintrc*`, package scripts, or shared package config.
- TypeScript projects have `tsconfig*.json` and typecheck scripts.
- CI runs lint and typecheck.
- Rules are consistent across packages in monorepos.

Status guidance:

- `present`: lint/typecheck tooling exists, covers relevant packages, and is in CI.
- `partial`: local lint exists but not CI, package coverage is inconsistent, or typecheck is missing for TS.
- `missing`: JS/TS source exists but no lint/static analysis is found.

### GitHub Actions

Applicability: `.github/workflows/*` exists.

Expected evidence:

- `zizmor`, `actionlint`, or an equivalent workflow linter/security checker.
- CI job or local command that checks workflow files.

Status guidance:

- `present`: workflow lint/security checking is configured and run in CI or documented checks.
- `partial`: a tool dependency or config exists but is not wired into CI.
- `missing`: GitHub Actions workflows exist but no workflow lint/security checker is visible.
- `not applicable`: no GitHub Actions workflows detected.

### Nix

Applicability: Nix files or flakes exist.

Expected evidence:

- `nix flake check` when using flakes.
- Nix evaluation/build checks for packages, apps, dev shells, or custom checks.
- Optional Nix linting such as `statix` or `deadnix` when the repo has substantial Nix code.

Status guidance:

- `present`: flake checks or equivalent Nix checks are wired into CI.
- `partial`: checks exist locally but CI does not run them, or checks cover only part of the flake.
- `missing`: flake exists but no evaluation/check path is visible.
- `not applicable`: no Nix detected.

## Organisation Shared Configs

Applicability: projects with evidence of organisation ownership or internal package ecosystem.

Organisation signals:

- Package scopes such as `@acme/*`.
- Internal registries or auth in `.npmrc`, package manager config, or lockfiles.
- Git remote URL or repository owner matching an organisation.
- Existing shared config packages or presets.
- Imports or `extends` values referencing organisation packages.

Check shared configuration for:

- ESLint, for example `@acme/eslint-config` in Acme projects.
- TypeScript, for example organisation `tsconfig` packages or base configs.
- Prettier, for example organisation Prettier config packages.
- Renovate, for example organisation presets in `extends`; audit this as organisation config as well as dependency automation.
- Commitlint, semantic-release, Changesets, or other tooling where the organisation has shared policy packages.

Status guidance:

- `present`: organisation signals exist and relevant tooling uses visible organisation configs.
- `partial`: some tools use organisation config while others use generic local config despite strong organisation signals.
- `missing`: a known organisation config is clearly available in the repo ecosystem but applicable tooling does not use it.
- `unknown`: organisation signals exist but the expected shared config package or preset cannot be confirmed from repo evidence.

Do not invent company-specific package names. Use examples from the repo or the user's prompt only.

## Dependency Automation

### Renovate

Applicability: maintained projects with external dependencies, including npm, Nix flakes, Docker images, GitHub Actions, or other package ecosystems.

Expected evidence:

- `renovate.json`, `.github/renovate.json`, `.renovaterc*`, or organisation Renovate presets.
- Config covers detected ecosystems such as npm/pnpm/yarn, GitHub Actions, Docker, Nix flakes, or Terraform when present.
- Grouping, schedule, automerge, lockfile maintenance, and security update policy are explicit or inherited from a shared preset.

Status guidance:

- `present`: Renovate is configured and appears to cover detected ecosystems.
- `partial`: Renovate exists but misses important ecosystems, uses only default config where org preset is expected, or lacks lockfile/update policy evidence.
- `missing`: external dependencies exist but no Renovate or equivalent dependency automation is found.
- `unknown`: organisation-level Renovate may be configured outside the repo and cannot be confirmed locally.

## JavaScript And TypeScript Project Hygiene

### Root Package Metadata

Applicability: JS/TS projects with a root `package.json`.

Expected evidence:

- Root `package.json` defines `engines` for supported runtime versions such as Node.js.
- Root `package.json` defines `devEngines` when the package manager/runtime supports it, so contributor tooling versions are explicit.
- Root `package.json` defines `packageManager` with a pinned package manager and version.
- Corepack is enabled or documented when relying on the `packageManager` field for pnpm/Yarn version selection.
- Prefer `pnpm` or `bun` for JS projects unless the repo has a documented reason to use npm or Yarn.

Status guidance:

- `present`: root `package.json` defines `engines`, `devEngines`, and `packageManager`, Corepack usage is enabled or documented when relevant, and the selected package manager is desirable or justified.
- `partial`: some fields exist but one is missing, the package manager is unpinned, Corepack usage is unclear, or npm/Yarn is used without visible rationale.
- `missing`: root `package.json` exists but none of these metadata fields are configured.
- `not applicable`: no root `package.json` or JS/TS project detected.

### Immutable Installs

Applicability: JS/TS projects with a committed lockfile.

Expected evidence:

- Lockfile is committed for the selected package manager, such as `pnpm-lock.yaml`, `bun.lockb`, `bun.lock`, `package-lock.json`, or `yarn.lock`.
- CI uses immutable/frozen install commands such as `pnpm install --frozen-lockfile`, `bun install --frozen-lockfile`, `npm ci`, or Yarn immutable installs.
- Local docs or scripts avoid commands that silently rewrite the lockfile during CI.

Status guidance:

- `present`: lockfile exists and CI uses immutable/frozen install semantics.
- `partial`: lockfile exists but CI install command may update it, or immutable install exists in one workflow but not all relevant workflows.
- `missing`: package dependencies exist but no lockfile or immutable CI install is visible.
- `not applicable`: no JS/TS package dependencies detected.

### pnpm Settings

Applicability: JS/TS projects using pnpm, detected through `packageManager`, `pnpm-lock.yaml`, `pnpm-workspace.yaml`, package scripts, or CI.

Expected evidence:

- pnpm settings are configured in root `package.json`, `.npmrc`, or workspace-level pnpm config.
- `minimumReleaseAgeStrict: true`.
- `autoInstallPeers: false`.
- `engineStrict: true` or `.npmrc` equivalent `engine-strict=true`.
- `strictPeerDependencies: true` or `.npmrc` equivalent `strict-peer-dependencies=true`.

Status guidance:

- `present`: all recommended pnpm settings are configured at the root or inherited through a visible shared config.
- `partial`: pnpm is used but only some recommended settings are configured.
- `missing`: pnpm is used and none of the recommended settings are visible.
- `not applicable`: pnpm is not used.

### Knip

Applicability: JS/TS projects, especially monorepos, libraries, CLIs, and apps with many exports or scripts.

Expected evidence:

- `knip` dependency, `knip.json`, `knip.ts`, `knip.config.*`, or package scripts.
- CI runs Knip or a documented unused-code/dependency check.

Status guidance:

- `present`: Knip is configured and checked in CI.
- `partial`: Knip exists locally but is not in CI or has package coverage gaps.
- `missing`: JS/TS project has no unused export/dependency checker.
- `not applicable`: no JS/TS project detected.

### TypeScript Quality

Applicability: TypeScript source or `tsconfig*.json` exists.

Expected evidence:

- `strict: true` is enabled directly or inherited from a shared/base `tsconfig`.
- Consider stronger correctness flags such as `noUncheckedIndexedAccess` and `exactOptionalPropertyTypes`, especially for libraries and shared code.
- Monorepos or multi-package TS workspaces use project references or another explicit build graph when package boundaries matter.
- Libraries emit correct type declarations and package metadata, such as `declaration`, `declarationMap`, `types`, `exports`, and subpath export coverage.
- CI runs typecheck and, for libraries, validates declaration/package output.

Status guidance:

- `present`: strict TypeScript settings and typecheck are configured, CI runs them, and library type output is covered when applicable.
- `partial`: TypeScript exists but strictness is incomplete, CI skips typecheck, project references/build graph are missing in a monorepo, or library declarations/exports are incomplete.
- `missing`: TypeScript exists but no meaningful typecheck or `tsconfig` quality evidence is found.
- `not applicable`: no TypeScript detected.

### pnpm Audit

Applicability: JS/TS projects using pnpm with external dependencies.

Expected evidence:

- CI or scheduled automation runs `pnpm audit`, GitHub dependency review, OSV, Snyk, or an equivalent vulnerability check.
- Audit policy is explicit about severity thresholds and exceptions.

Status guidance:

- `present`: pnpm dependency vulnerability checks are automated with visible policy.
- `partial`: audit command exists locally but is not in CI/scheduled checks, or policy is unclear.
- `missing`: pnpm dependencies exist but no vulnerability/audit check is visible.
- `not applicable`: pnpm is not used or no external dependencies are detected.

### Test Console Hygiene

Applicability: Jest or Vitest tests exist.

Expected evidence:

- `jest-fail-on-console` dependency and global setup in Jest, or equivalent setup for Vitest/Jest that fails tests on unexpected `console.error` and `console.warn`.
- Setup is global, not copied ad hoc into a few test files.
- Allowlist or explicit spies exist only for intentional console output.

Status guidance:

- `present`: console-failure guard is configured globally for the test runner.
- `partial`: dependency exists but is not wired globally, only some packages use it, or only one console method is guarded.
- `missing`: Jest/Vitest exists but no console-failure guard is visible.
- `not applicable`: no Jest/Vitest or equivalent JS test runner detected.

Equivalent setups can include custom setup files that throw on unexpected console usage. Do not require the exact `jest-fail-on-console` package if behavior is clearly implemented.

### Deterministic Test Environment

Applicability: every detected test runner, including Jest, Vitest, Playwright, Cypress, Storybook test runner, Node test runner, or other project-specific runners.

Expected evidence:

- Each test runner has deterministic environment setup appropriate for its scope, such as fixed timezone, locale, fake timers or controlled clocks, seeded randomness, isolated temp directories, stable ports, and controlled network/backend dependencies.
- Browser/e2e runners configure deterministic browser context, storage state, permissions, viewport/device settings, and mocked or controlled backend where applicable.
- CI uses the same deterministic setup as local test commands.

Status guidance:

- `present`: every detected test runner has visible deterministic environment setup and CI uses it.
- `partial`: some runners are deterministic but others are not, or CI uses a different setup from local commands.
- `missing`: tests exist but no deterministic environment controls are visible.
- `not applicable`: no test runners detected.

When multiple runners exist, audit each runner separately in the notes. For example, Jest can be `present` while Playwright is `partial`.

## React And Webapps

### Playwright End-To-End Tests With Mocked Backend

Applicability: browser webapps, React apps, SPA/SSR frontend apps, or repos with frontend routes and user flows.

Detection signals:

- React, Next.js, Remix, Vite, Webpack, frontend app directories, routes, pages, or browser build scripts.
- Existing Testing Library tests do not replace end-to-end coverage for key app flows.

Expected evidence:

- Playwright e2e config and tests for critical flows.
- Backend mocking strategy such as MSW, Playwright route mocks, test server fixtures, contract stubs, or local fake services.
- CI runs e2e tests or a smoke subset.
- Tests avoid dependence on unstable shared environments unless explicitly justified.

Status guidance:

- `present`: Playwright e2e tests exist, backend is mocked or controlled, and CI runs them.
- `partial`: Playwright exists but backend is live/uncontrolled, CI does not run tests, or coverage is limited to trivial smoke tests.
- `missing`: a webapp is detected but no e2e setup is found.
- `not applicable`: no webapp detected.

### Playwright Component Testing

Applicability: React projects with a reusable component library or many shared UI base components.

Strong recommendation signals:

- Component library packages such as `packages/ui`, `libs/ui`, `src/components`, `design-system`, or `ui-kit`.
- Many exported reusable components consumed by multiple apps or packages.
- Storybook, Ladle, Styleguidist, or similar component demo setup.
- Visual/state-heavy base components such as dialogs, menus, comboboxes, data tables, forms, date pickers, or drag/drop components.

Recommendation strength:

- `recommended`: several strong component-library signals exist.
- `consider`: some reusable UI signals exist, but the repo mostly contains app-specific components.
- `not applicable`: no React or no reusable UI surface detected.
- `unknown`: file structure is insufficient to determine whether components are reusable base components.

Status guidance:

- `present`: Playwright CT or equivalent browser component tests exist for reusable components and run in CI.
- `partial`: component tests exist but are not in CI or cover only isolated examples.
- `missing`: recommendation strength is `recommended` and no component test setup is found.
- `not applicable`: recommendation strength is `not applicable`.
- `unknown`: recommendation strength is `unknown`.

Use the status vocabulary for the requirement and put the recommendation strength in notes.

### Web Performance And Browser Support

Applicability: browser webapps, frontend libraries, design systems, or packages shipped to browsers.

Expected evidence:

- Lighthouse, WebPageTest, Playwright performance checks, or another performance-budget mechanism for webapps.
- Bundle size checks such as `size-limit`, `bundlesize`, package-size checks, build analyzer thresholds, or CI-enforced artifact-size budgets for browser bundles.
- Browser support policy through `browserslist`, package metadata, docs, or framework configuration.
- CI runs performance/bundle checks where they are stable enough to gate changes, or documents why they are advisory.

Status guidance:

- `present`: browser support is declared and performance or bundle-size checks are automated where applicable.
- `partial`: browser support exists without checks, checks exist but are not in CI, or only one of performance/bundle-size is covered for a webapp.
- `missing`: web/browser code exists but no browser support or performance/bundle-size evidence is visible.
- `not applicable`: no browser-targeted code detected.

## Nix And Flakes

### Flake Alignment

Applicability: `flake.nix` exists.

Expected evidence:

- `flake.lock` is committed.
- CI installs Nix and runs flake-native commands such as `nix flake check`, `nix fmt`, `nix develop`, `nix build`, or `nix run` as appropriate.
- Developer commands use the flake instead of duplicating tool versions outside Nix.
- `nix develop` provides the normal developer tooling, or README/dev docs explain the intended dev shell.
- Formatters and checks are exposed through flake outputs when possible.

Status guidance:

- `present`: CI and local commands use the flake for checks, formatting, builds, or install apps.
- `partial`: flake exists but CI bypasses it, duplicates tool setup, or checks only a subset of flake outputs.
- `missing`: flake exists but no CI or documented workflow uses it.
- `not applicable`: no flake detected.

### Nix Dependency Updates

Applicability: `flake.lock` or Nix dependency pins exist.

Expected evidence:

- Renovate, Dependabot, or equivalent automation updates `flake.lock` and other Nix pins.
- CI validates lockfile updates with `nix flake check`.

Status guidance:

- `present`: Nix dependency updates are automated and validated.
- `partial`: updates are automated without clear validation, or validation exists without update automation.
- `missing`: Nix pins exist but no dependency update automation is visible.
- `not applicable`: no Nix pins detected.

### Nix Lint And Binary Cache

Applicability: Nix flakes, substantial Nix code, or projects with expensive Nix builds.

Expected evidence:

- `statix` for Nix linting and `deadnix` for unused Nix code when the repo has more than trivial Nix files.
- CI runs Nix lint checks or exposes them through `nix flake check`.
- Cachix or another binary cache is configured when Nix builds are expensive or shared across a team/CI.
- Cache configuration is documented and CI uses it safely.

Status guidance:

- `present`: Nix linting is configured and CI-visible, and binary cache is configured when build cost justifies it.
- `partial`: one of `statix`/`deadnix`/cache exists but is not wired into CI or docs, or cache need is unclear.
- `missing`: substantial Nix code lacks linting, or expensive Nix builds lack cache evidence.
- `not applicable`: no substantial Nix code and no expensive Nix builds detected.

## Monorepo Coverage

Applicability: workspaces with multiple packages/apps.

Expected evidence:

- Root-level scripts or task runner cover all relevant packages.
- Tool configs are shared or consistently extended.
- CI detects affected packages or runs full quality gates when appropriate.
- Package-level exceptions are documented.

Status guidance:

- `present`: tooling coverage is consistent across packages and CI.
- `partial`: some packages are uncovered or use divergent configs without explanation.
- `missing`: workspace exists but quality tooling is only configured for one package or not at root.
- `unknown`: package ownership or generated package boundaries cannot be determined locally.

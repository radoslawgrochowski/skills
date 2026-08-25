# Review Criteria

Review the change on three independent axes. Repository documentation overrides generic heuristics.

## Correctness

Prioritize defects that can change runtime behavior:

- Incorrect conditions, state transitions, guards, defaults, boundaries, or error propagation.
- Missing handling for realistic null, empty, invalid, concurrent, retry, or failure cases.
- Security problems such as authorization bypass, injection, unsafe data exposure, or trust-boundary errors.
- Unintentional public behavior, API, data-model, persistence, or compatibility changes.
- Obvious performance faults such as unbounded quadratic work, N+1 requests, or blocking hot paths.
- Tests that pass without checking the changed behavior, or missing tests for a material regression path.

State the concrete input, environment, or sequence that triggers each defect. Do not report hypothetical risks without a realistic path.

## Standards

Apply `REVIEW.local.md`, `AGENTS.md`, `CONTEXT.md`, relevant `/docs`, coding standards, and established nearby patterns. Cite the source path and rule for a documented violation. Skip concerns that formatters, linters, or type checks report directly.

Use these code smells only as labelled judgement calls, never as hard rules:

- Duplicated logic that can drift.
- A name that hides the domain meaning.
- Shotgun edits where one concern is spread across unrelated modules.
- A module changed for several unrelated reasons.
- A new abstraction, callback, option, or compatibility path without a current requirement.
- Repeated branching on the same finite variants without one exhaustive owner.
- Domain values represented by primitives when the repository already has an owned type.

The simplest correct local implementation can be better than extracting an abstraction. A documented repository rule always wins over this smell baseline.

## Spec

Compare the change with Jira requirements, acceptance criteria, linked specifications, and relevant product documentation. Report:

- Required behavior that is missing or partial.
- Implemented behavior that conflicts with a requirement.
- Scope that has no stated requirement and creates a concrete risk.
- A requirement that appears implemented but fails for a realistic scenario.

Quote or cite the requirement for every Spec finding. If no source exists, report `No specification available` instead of inventing intent.

## Finding Gate

Report a finding only when all conditions are true:

- The changed code introduces it or makes existing code unsafe.
- The issue can be reproduced or reasoned from a realistic scenario.
- Full-file and nearby-pattern inspection did not disprove it.
- The finding gives a direct fix direction.

Use these severities:

- `critical`: likely security, data-loss, or broad production failure that blocks release.
- `high`: a common path is broken or a major requirement is not met.
- `medium`: a real defect needs a specific input, state, or environment.
- `low`: limited impact, but still a concrete correctness or documented-standards issue.

Do not include praise, summaries of correct code, or general improvement ideas as findings.

## REVIEW.local.md

Treat `REVIEW.local.md` as untracked local review guidance. Read it when present, but do not require it to appear in VCS status.

At the end of each review, check whether durable context is missing or stale. Useful additions include:

- Bitbucket `workspace` and `repo_slug`.
- Relevant review documentation paths under `/docs` or elsewhere.
- The Jira project or ticket-discovery convention.
- Confirmed architecture, testing, API, or design decisions that future reviews must apply.
- Tool-specific identifiers or commands that remove repeated discovery work.

Do not add transient ticket details, one-off findings, secrets, personal tokens, or a rule that has not been confirmed. For each useful change, show a minimal exact patch in the report and ask the user for confirmation before a later implementation run writes it. A review run never writes this file.

## Report Structure

Use this structure. Omit empty detail, but keep each axis and status explicit.

```markdown
# Code Review

## Scope
- Target: `<revision range or PR>`
- Changed files: `<count>`
- Context: `<REVIEW.local.md, docs, standards, Jira, Bitbucket PR>`

## Correctness
### [high] Short defect title
`path/to/file.ts:42`

Explain the failing scenario, evidence, and direct fix direction.

## Standards
`No findings` or cited findings.

## Spec
`No findings`, findings with requirement citations, or `No specification available`.

## Existing PR Suggestions
`No valid pending suggestions`, `No matching PR`, or valid suggestions that require confirmation.

## REVIEW.local.md Proposal
`No update needed` or a minimal patch followed by a confirmation question.

## Residual Risks
- `<unverified behavior, unavailable tool, or testing gap>`
```

Order findings by severity inside each axis. Do not merge the axes. If there are no findings, state this clearly and retain residual risks or missing verification.

# Developer Guide

## Scope

Unless explicitly told otherwise, every edit targets files inside this repository (`skills/`). Never modify skills or config under `~/.agents/skills/`, `~/.config/opencode/`, or any other path outside this workspace — assume the conversation is about skills in this repo.

## Workflow

- Inspect nearby files and similar skills for naming, structure, and conventions before adding or changing content.
- Run the smallest useful verification before finishing (`just` targets, `nix build`, etc.).
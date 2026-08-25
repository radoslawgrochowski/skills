# skills

OpenCode skills for Jujutsu, Jira, code review, and project tooling audits. Managed as a Nix flake with an install script and a justfile.

## Install

Preview the local and external skills plus the global OpenCode `/review` command:

```sh
nix run .#install -- --dry-run
```

Run the installer without `--dry-run` and approve its prompt to write the files. Skills go to `~/.agents/skills`. The review command goes to `~/.config/opencode/commands/review.md` and overrides OpenCode's built-in `/review` command.

Use `--dest PATH` to change the skills directory. Use `--command-dest PATH` to change the OpenCode commands directory. The repository does not write global OpenCode configuration until you run and approve the installer.

Quit and restart OpenCode after installation so it loads the new skill and command.

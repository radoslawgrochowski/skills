# Declarative list of external skill sources to install via `nix run .#install`.
# Local first-party skills live under `skills/<name>/SKILL.md` and are
# auto-discovered by the installer.
#
# Each entry fetches a GitHub repository with `fetchFromGitHub` (pin both
# `rev` and `hash`; bump with `:UpdateNixFetchgit` in neovim) and resolves
# the listed `paths` patterns against the fetched tree.
#
# `paths` patterns use gitignore-style globs:
#   `*`  - one directory segment
#   `**` - zero or more directory segments (recursive)
# A pattern only matches directories containing a `SKILL.md`. An exact path
# without a `SKILL.md` or a pattern that matches zero skills is a hard
# evaluation error (signals a typo in this file).
[
  {
    owner = "multica-ai";
    repo = "andrej-karpathy-skills";
    rev = "2c606141936f1eeef17fa3043a72095b4765b9c2";
    hash = "sha256-4z/wRdYH7UXRzF8RJU0sw8xbpx0BW/7CBv5sVEC2knY=";
    paths = [ "skills/karpathy-guidelines" ];
  }
  {
    owner = "mattpocock";
    repo = "skills";
    rev = "272f99b22574f50e4266791c86b9302682970e23";
    hash = "sha256-3muzsPd/1OgGgG+aIpXWUm9R2Lxa1I/geJxmNL8VJAY=";
    paths = [
      "skills/productivity/grill-me"
      "skills/productivity/grilling"
      "skills/productivity/handoff"
      "skills/productivity/writing-great-skills"
    ];
  }
  {
    owner = "anthropics";
    repo = "skills";
    rev = "9d2f1ae187231d8199c64b5b762e1bdf2244733d";
    hash = "sha256-U7Nt1xrFOSOEm4vuWmy4pVsEyvv+Hj4sv8yXOofmwAw=";
    paths = [ "skills/skill-creator" ];
  }
]

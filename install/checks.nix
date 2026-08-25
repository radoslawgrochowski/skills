{
  pkgs,
  walk,
  glob,
  reviewCommandSource,
}:

let
  # Build a fake tree in the Nix store for the glob matcher to walk.
  fixtureDir = pkgs.runCommandLocal "glob-fixture" { } ''
    mkdir -p $out/skills/productivity/grill-me
    mkdir -p $out/skills/productivity/grilling
    mkdir -p $out/skills/productivity/empty
    mkdir -p $out/skills/engineering/feat-a
    mkdir -p $out/misc
    echo body > $out/skills/productivity/grill-me/SKILL.md
    echo body > $out/skills/productivity/grilling/SKILL.md
    echo body > $out/skills/engineering/feat-a/SKILL.md
    echo body > $out/README.md
  '';
  tree = walk.walk fixtureDir;

  # `assertEq` throws at eval time when `actual` and `expected` disagree,
  # returns `true` on agreement. Asserts are collected into a list and
  # embedded into the build dep graph so failures surface during
  # `nix flake check` rather than only when something tries to build this.
  assertEq =
    name: actual: expected:
    if actual == expected then
      true
    else
      throw "glob check '${name}' failed: got ${builtins.toJSON actual}, expected ${builtins.toJSON expected}";

  pathsOf = builtins.map (m: m.path);

  directChildren = pathsOf (glob.globMatch "skills/productivity/*" tree);
  recursive = pathsOf (glob.globMatch "skills/**" tree);
  exact = pathsOf (glob.globMatch "skills/productivity/grill-me" tree);
  # `globMatch` itself returns [] for a zero-match pattern; the caller
  # (resolve.nix) is what throws. We assert the matcher returns [] so
  # the caller's throw policy stays intact.
  zeroMatch = pathsOf (glob.globMatch "skills/nonexistent/*" tree);

  # `skills/productivity/empty` has no SKILL.md -> excluded from `*`.
  expectedDirect = [
    [
      "skills"
      "productivity"
      "grill-me"
    ]
    [
      "skills"
      "productivity"
      "grilling"
    ]
  ];
  expectedRecursive = [
    [
      "skills"
      "engineering"
      "feat-a"
    ]
    [
      "skills"
      "productivity"
      "grill-me"
    ]
    [
      "skills"
      "productivity"
      "grilling"
    ]
  ];
  expectedExact = [
    [
      "skills"
      "productivity"
      "grill-me"
    ]
  ];
  expectedZero = [ ];

  asserts = [
    (assertEq "direct-children" directChildren expectedDirect)
    (assertEq "recursive" recursive expectedRecursive)
    (assertEq "exact" exact expectedExact)
    (assertEq "zero-match" zeroMatch expectedZero)
  ];

  installerFixtureSkill = pkgs.runCommandLocal "installer-fixture-skill" { } ''
    mkdir -p $out
    printf '%s\n' '# Fixture skill' > $out/SKILL.md
  '';

  installerManifest = pkgs.writeText "installer-fixture-manifest.json" (
    builtins.toJSON [
      {
        src = installerFixtureSkill;
        name = "code-review";
        source = "fixture:code-review";
        path = "skills/code-review";
      }
    ]
  );
in
{
  glob = pkgs.runCommandLocal "glob-checks" { } ''
    # ${builtins.toJSON asserts}
    touch $out
  '';

  installer = pkgs.runCommandLocal "installer-checks" { nativeBuildInputs = [ pkgs.jq ]; } ''
    set -euo pipefail

    work="$TMPDIR/installer-checks"
    mkdir -p "$work"

    env \
      HOME="$work/home" \
      SKILLS_LIST_JSON="${installerManifest}" \
      REVIEW_COMMAND_SRC="${reviewCommandSource}" \
      bash ${./install.sh} \
        --dry-run \
        --dest "$work/dry-skills" \
        --command-dest "$work/dry-commands"

    test ! -e "$work/dry-skills"
    test ! -e "$work/dry-commands"

    printf 'n\n' | env \
      HOME="$work/home" \
      SKILLS_LIST_JSON="${installerManifest}" \
      REVIEW_COMMAND_SRC="${reviewCommandSource}" \
      bash ${./install.sh} \
        --dest "$work/declined-skills" \
        --command-dest "$work/declined-commands"

    test ! -e "$work/declined-skills"
    test ! -e "$work/declined-commands"

    env \
      HOME="$work/home" \
      SKILLS_LIST_JSON="${installerManifest}" \
      REVIEW_COMMAND_SRC="${reviewCommandSource}" \
      bash ${./install.sh} \
        --yes \
        --dest "$work/skills" \
        --command-dest "$work/commands"

    test -f "$work/skills/code-review/SKILL.md"
    test -f "$work/commands/review.md"
    cmp "${reviewCommandSource}" "$work/commands/review.md"

    printf '%s\n' 'old review command' > "$work/commands/review.md"
    env \
      HOME="$work/home" \
      SKILLS_LIST_JSON="${installerManifest}" \
      REVIEW_COMMAND_SRC="${reviewCommandSource}" \
      bash ${./install.sh} \
        --yes \
        --dest "$work/replacement-skills" \
        --command-dest "$work/commands"
    cmp "${reviewCommandSource}" "$work/commands/review.md"

    mkdir -p "$work/symlink-commands"
    printf '%s\n' 'protected' > "$work/protected"
    printf '%s\n' 'protected' > "$work/expected-protected"
    ln -s "$work/protected" "$work/symlink-commands/review.md"
    if env \
      HOME="$work/home" \
      SKILLS_LIST_JSON="${installerManifest}" \
      REVIEW_COMMAND_SRC="${reviewCommandSource}" \
      bash ${./install.sh} \
        --yes \
        --dest "$work/symlink-skills" \
        --command-dest "$work/symlink-commands"; then
      echo "Expected symlink collision to fail" >&2
      exit 1
    fi
    test ! -e "$work/symlink-skills"
    cmp "$work/expected-protected" "$work/protected"

    mkdir -p "$work/directory-commands/review.md"
    if env \
      HOME="$work/home" \
      SKILLS_LIST_JSON="${installerManifest}" \
      REVIEW_COMMAND_SRC="${reviewCommandSource}" \
      bash ${./install.sh} \
        --yes \
        --dest "$work/directory-skills" \
        --command-dest "$work/directory-commands"; then
      echo "Expected directory collision to fail" >&2
      exit 1
    fi
    test ! -e "$work/directory-skills"

    touch $out
  '';
}

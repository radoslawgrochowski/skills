{
  pkgs,
  walk,
  glob,
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
in
{
  glob = pkgs.runCommandLocal "glob-checks" { } ''
    # ${builtins.toJSON asserts}
    touch $out
  '';
}

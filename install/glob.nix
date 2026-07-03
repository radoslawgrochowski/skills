# Gitignore-style glob matcher over a `walk`-produced tree.
#
#   globMatch :: string -> attrs -> [ { path = [string]; } ]
#
# `pattern` uses:
#   `*`  - matches exactly one directory segment
#   `**` - matches zero or more directory segments (recursive)
#   anything else - a literal segment name
#
# A match only counts when the resolved node is a directory containing a
# sibling `SKILL.md`. Non-`SKILL.md` directories matched by a glob are
# silently skipped.
#
# Used by `flake.nix` to turn each entry's `paths` patterns into the final
# list of skill directories.

{ walk }:

let
  inherit (walk) walk;

  # Split a pattern on "/" and drop empty segments (handles trailing/leading
  # slashes and consecutive `//`).
  splitPattern = pat: builtins.filter (s: builtins.isString s && s != "") (builtins.split "/" pat);

  # True if `node` is a directory whose children include `SKILL.md`.
  hasSkillMd = node: node.type == "directory" && builtins.hasAttr "SKILL.md" node.children;

  # Names of `node`'s children that are directories, lexical order.
  dirChildNames =
    node:
    builtins.filter (name: node.children.${name}.type == "directory") (
      builtins.attrNames node.children
    );

  # Internal DFS. `segs` is the remaining pattern; `node` is the current
  # directory node (must have `type = "directory"` when `segs != []`);
  # `curPath` is the accumulated list of segment names from the root.
  matchInternal =
    segs: node: curPath:
    if segs == [ ] then
      if hasSkillMd node then [ { path = curPath; } ] else [ ]
    else
      let
        head = builtins.head segs;
        tail = builtins.tail segs;
      in
      if node.type != "directory" then
        [ ]
      else if head == "**" then
        # Zero segments: advance past `**`.
        let
          zero = matchInternal tail node curPath;
          # One or more segments: descend into each child directory, keeping
          # `**` as the active head so it can consume more segments.
          onePlus = builtins.concatMap (
            name:
            let
              child = node.children.${name};
            in
            matchInternal segs child (curPath ++ [ name ])
          ) (dirChildNames node);
        in
        zero ++ onePlus
      else if head == "*" then
        # Exactly one directory segment.
        builtins.concatMap (
          name:
          let
            child = node.children.${name};
          in
          matchInternal tail child (curPath ++ [ name ])
        ) (dirChildNames node)
      else
      # Literal segment.
      if builtins.hasAttr head node.children then
        let
          child = node.children.${head};
        in
        if child.type == "directory" then matchInternal tail child (curPath ++ [ head ]) else [ ]
      else
        [ ];

  # Public entry point. `walkTree` is the raw `walk rootPath` result (the
  # children mapping of the root); it is wrapped into a node so the matcher
  # has a uniform representation.
  globMatch =
    pattern: walkTree:
    let
      root = {
        type = "directory";
        children = walkTree;
      };
    in
    matchInternal (splitPattern pattern) root [ ];
in
{
  inherit globMatch hasSkillMd splitPattern;
}

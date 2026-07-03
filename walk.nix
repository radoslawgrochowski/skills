# Recursive directory walker.
#
#   walk :: path -> attrs
#
# Returns an attrset mirroring `builtins.readDir`, but for every directory
# entry the value is itself a `walk` result under that directory (instead of
# the bare "directory" string). File entries keep the bare type string.
#
# Example:
#   walk /nix/store/...-source  =>  {
#     "skills" = {
#       type = "directory";
#       children = {
#         "karpathy-guidelines" = {
#           type = "directory";
#           children = { "SKILL.md" = { type = "regular"; }; };
#         };
#       };
#     };
#     "README.md" = { type = "regular"; };
#   }

let
  walk =
    path:
    builtins.mapAttrs (
      name: type:
      if type == "directory" then
        {
          type = "directory";
          children = walk (path + "/${name}");
        }
      else
        { type = type; }
    ) (builtins.readDir path);

  # Resolve a list of path segments against a `walk` tree, returning the node
  # at that path (an attrset with `type` and possibly `children`), or `null` if
  # the path does not exist.
  #
  #   nodeAt :: attrs -> [string] -> attrs | null
  nodeAt =
    tree: segments:
    if segments == [ ] then
      tree
    else
      let
        head = builtins.head segments;
        tail = builtins.tail segments;
      in
      if tree ? "${head}" then
        let
          child = tree.${head};
        in
        if child.type == "directory" then
          nodeAt child.children tail
        else if tail == [ ] then
          child
        else
          null
      else
        null;
in
{
  inherit walk nodeAt;
}

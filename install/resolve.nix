{
  pkgs,
  walk,
  glob,
  skills,
}:

let

  # Resolve one `skills.nix` entry into a list of skill records.
  # Each record: { src, name, owner, repo, path }.
  resolveEntry =
    entry:
    let
      src = pkgs.fetchFromGitHub {
        inherit (entry)
          owner
          repo
          rev
          hash
          ;
      };
      tree = walk.walk src;
      matchOne =
        pattern:
        let
          matches = glob.globMatch pattern tree;
        in
        if matches == [ ] then
          throw "skills.nix: pattern '${pattern}' in ${entry.owner}/${entry.repo} matched no skill directories containing SKILL.md"
        else
          matches;
      allMatches = builtins.concatMap matchOne entry.paths;
    in
    builtins.map (m: {
      src = "${src}/${builtins.concatStringsSep "/" m.path}";
      name = pkgs.lib.last m.path;
      owner = entry.owner;
      repo = entry.repo;
      path = builtins.concatStringsSep "/" m.path;
    }) allMatches;

  allSkills = builtins.concatMap resolveEntry skills;

  skillsListJson = pkgs.writeText "skills-list.json" (builtins.toJSON allSkills);
in
{
  inherit allSkills skillsListJson;
}

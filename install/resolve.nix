{
  pkgs,
  walk,
  glob,
  externalSkills,
  localSkillsRoot,
}:

let

  joinPath = builtins.concatStringsSep "/";

  # Resolve one `external-skills.nix` entry into a list of skill records.
  # Each record: { src, name, source, path }.
  resolveExternalEntry =
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
          throw "external-skills.nix: pattern '${pattern}' in ${entry.owner}/${entry.repo} matched no skill directories containing SKILL.md"
        else
          matches;
      allMatches = builtins.concatMap matchOne entry.paths;
    in
    builtins.map (
      m:
      let
        path = joinPath m.path;
      in
      {
        src = "${src}/${path}";
        name = pkgs.lib.last m.path;
        source = "${entry.owner}/${entry.repo}:${path}";
        path = path;
      }
    ) allMatches;

  localMatches = glob.globMatch "*" (walk.walk localSkillsRoot);

  localSkills = builtins.map (
    m:
    let
      relativePath = joinPath m.path;
      path = "skills/${relativePath}";
    in
    {
      src = "${localSkillsRoot}/${relativePath}";
      name = pkgs.lib.last m.path;
      source = "local:${path}";
      path = path;
    }
  ) localMatches;

  externalSkillRecords = builtins.concatMap resolveExternalEntry externalSkills;
  allSkillsUnchecked = localSkills ++ externalSkillRecords;

  skillNames = builtins.map (skill: skill.name) allSkillsUnchecked;
  duplicateNames = pkgs.lib.unique (
    builtins.filter (
      name: (builtins.length (builtins.filter (candidate: candidate == name) skillNames)) > 1
    ) skillNames
  );

  allSkills =
    if duplicateNames == [ ] then
      allSkillsUnchecked
    else
      throw "duplicate skill name(s): ${builtins.concatStringsSep ", " duplicateNames}";

  skillsListJson = pkgs.writeText "skills-list.json" (builtins.toJSON allSkills);
in
{
  inherit allSkills skillsListJson;
}

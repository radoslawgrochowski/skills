# Builds the `install` app and the `checks` output from a skill list.
{
  pkgs,
  skills,
}:

let
  walk = import ./walk.nix;
  glob = import ./glob.nix { inherit walk; };

  resolved = import ./resolve.nix {
    inherit
      pkgs
      walk
      glob
      skills
      ;
  };
  checks = import ./checks.nix { inherit pkgs walk glob; };

  installScript = pkgs.writeShellApplication {
    name = "install";
    runtimeInputs = [
      pkgs.jq
      pkgs.bash
    ];
    text = ''
      SKILLS_LIST_JSON="${resolved.skillsListJson}" exec bash ${./install.sh} "$@"
    '';
  };
in
{
  installApp = {
    type = "app";
    program = "${installScript}/bin/install";
  };

  checks = checks;
}

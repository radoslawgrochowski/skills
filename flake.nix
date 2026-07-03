{
  description = "radoslawgrochowski skills";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        walk = import ./walk.nix;
        glob = import ./glob.nix { inherit walk; };

        resolved = import ./resolve.nix { inherit pkgs walk glob; };
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
        formatter = pkgs.nixfmt-tree;

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ nixfmt-tree ];
        };

        apps.install = {
          type = "app";
          program = "${installScript}/bin/install";
        };

        checks = checks;
      }
    );
}

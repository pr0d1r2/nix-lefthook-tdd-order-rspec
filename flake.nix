{
  description = "Lefthook-compatible TDD order enforcer for RSpec, packaged as a Nix flake";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock";
    nixpkgs.follows = "nixpkgs-lock/nixpkgs";
    nix-dev-shell-agentic = {
      url = "github:pr0d1r2/nix-dev-shell-agentic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-dev-shell-agentic,
      ...
    }@inputs:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        default =
          let
            isSkipped = pkgs.writeText "is-skipped.sh" (builtins.readFile ./is-skipped.sh);
            specPathFor = pkgs.writeText "spec-path-for.sh" (builtins.readFile ./spec-path-for.sh);
          in
          pkgs.writeShellApplication {
            name = "lefthook-tdd-order-rspec";
            runtimeInputs = [
              pkgs.git
              pkgs.coreutils
              pkgs.gnused
            ];
            text =
              builtins.replaceStrings
                [
                  "@IS_SKIPPED_PATH@"
                  "@SPEC_PATH_FOR_PATH@"
                ]
                [
                  "${isSkipped}"
                  "${specPathFor}"
                ]
                (builtins.readFile ./lefthook-tdd-order-rspec.sh);
          };
      });

      devShells = forAllSystems (
        pkgs:
        let
          inherit (pkgs.stdenv.hostPlatform) system;
          shells = nix-dev-shell-agentic.lib.mkShells {
            inherit pkgs inputs;
            ciPackages = [
              self.packages.${system}.default
            ];
            shellHook = builtins.replaceStrings [ "@BATS_LIB_PATH@" ] [ "${shells.batsWithLibs}" ] (
              builtins.readFile ./dev.sh
            );
          };
        in
        shells
      );
    };
}

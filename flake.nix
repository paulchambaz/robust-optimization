{
  description = "Mogpl dev environment";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
        python = pkgs.python311;
        pythonPackages = python.pkgs;
        devPkgs = with pkgs; [
          glpk
          gurobi
          python
        ];
        pythonPkgs = with pythonPackages; [
          pulp
          numpy
          matplotlib
          gurobipy
        ];
      in {
        app.default = {
        };
        devShells.default = pkgs.mkShell {
          buildInputs = devPkgs ++ pythonPkgs;
          shellHook = ''
            export GRB_LICENSE_FILE="./gurobi.lic"
          '';
        };
      }
    );
}

{
  description = "Mogpl dev environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python311;
        pythonPackages = python.pkgs;
        devPkgs = with pkgs; [
          glpk
          python
        ];
        pythonPkgs = with pythonPackages; [
          pulp
          numpy
          matplotlib
        ];
      in {
        app.default = {
        };
        devShells.default = pkgs.mkShell {
          buildInputs = devPkgs ++ pythonPkgs;
        };
      }
    );
}

{ inputs }:
{ system, self }:
let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
in
pkgs.mkShell {
  inherit (self.checks.${system}.pre-commit-check) shellHook;
  packages = [ pkgs.nixfmt-tree ];
  buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
}

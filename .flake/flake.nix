# Copyright 2024, identinet GmbH. All rights reserved.
# SPDX-License-Identifier: MIT

{
  description = "Dependencies";

  # inputs.nixpkgs.url = "github:identinet/nixpkgs/identinet";
  inputs.nixpkgs_unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, nixpkgs_unstable, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        unstable = nixpkgs_unstable.legacyPackages.${system};
        my-python-packages = python-packages:
          with python-packages;
          [
            pyyaml # YAML module
          ];
        python-with-my-packages = pkgs.python3.withPackages my-python-packages;
        allOsPackages = with pkgs; [
          # Nix packages: https://search.nixos.org/packages
          # Shared dependencies
          # opentofu # Terraform OSS https://opentofu.org/
          bashInteractive
          deno # JS interpreter https://deno.land/
          gh # GitHub CLI https://cli.github.com/
          git-cliff # Changelog generator https://github.com/orhun/git-cliff
          just # Simple make replacement https://just.systems/
          tflint # Terraform linter https://github.com/terraform-linters/tflint
          unstable.nushell # Nu Shell https://www.nushell.sh/

          # Kubernetes tools
          # k9s # interactive kubectl interface  https://k9scli.io/
          # kubectl # kubernetes CLI https://kubectl.docs.kubernetes.io/
          # kubernetes-helm # helm CLI https://helm.sh
          # unstable.fluxcd # fluxcd CLI for interacting with the CD tool https://fluxcd.io
          # yq-go # YAML and JSON CLI parser https://mikefarah.gitbook.io/yq/
          # python-with-my-packages
        ];
        linuxOnlyPackages = with pkgs;
          [
            # datree # kubernetes configuration validation and verification https://datree.io/
          ];
      in {
        devShell = pkgs.mkShell {
          nativeBuildInputs = if pkgs.system == "x86_64-linux" then
            allOsPackages ++ linuxOnlyPackages
          else
            allOsPackages;
          buildInputs = [ ];
        };
      });
}

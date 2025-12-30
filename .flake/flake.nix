# Copyright 2024, identinet GmbH. All rights reserved.
# SPDX-License-Identifier: MIT

{
  description = "Dependencies";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (self: super: {
              unstable = import nixpkgs-unstable {
                inherit system;
                # config.allowUnfree = true;
              };
            })
          ];
        };
        # python-with-my-packages = pkgs.python3.withPackages my-python-packages;
        allOsPackages = with pkgs; [
          # Nix packages: https://search.nixos.org/packages
          # Shared dependencies
          bashInteractive
          deno # JS interpreter https://deno.land/
          gh # GitHub CLI https://cli.github.com/
          git-cliff # Changelog generator https://github.com/orhun/git-cliff
          just # Simple make replacement https://just.systems/
          # terraform # Infrastructure as code https://www.terraform.io/
          opentofu # Terraform OSS https://opentofu.org/
          tflint # Terraform linter https://github.com/terraform-linters/tflint
          nushell # Nu Shell https://www.nushell.sh/
          unstable.renovate # Renovate dependency updater https://docs.renovatebot.com/

          # Kubernetes tools
          # k9s # interactive kubectl interface  https://k9scli.io/
          # kubectl # kubernetes CLI https://kubectl.docs.kubernetes.io/
          # kubernetes-helm # helm CLI https://helm.sh
          # unstable.fluxcd # fluxcd CLI for interacting with the CD tool https://fluxcd.io
          # yq-go # YAML and JSON CLI parser https://mikefarah.gitbook.io/yq/
          # python-with-my-packages
        ];
        linuxOnlyPackages = with pkgs; [
          # datree # kubernetes configuration validation and verification https://datree.io/
        ];
      in
      {
        devShell = pkgs.mkShell {
          nativeBuildInputs =
            if pkgs.system == "x86_64-linux" then allOsPackages ++ linuxOnlyPackages else allOsPackages;
          buildInputs = [ ];
        };
      }
    );
}

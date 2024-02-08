#!/usr/bin/env just --justfile
# Documentation: https://just.systems/man/en/
# Copyright 2024, identinet GmbH. All rights reserved.
# SPDX-License-Identifier: MIT

set shell := ['nu', "-c"]

# Integration with nodejs package.json scripts, see https://just.systems/man/en/chapter_65.html
# export PATH := "node_modules/.bin:" + env_var('PATH')
# To override the value of SOME_VERSION, run: just --set SOME_VERSION 1.2.4 TARGET_NAME
# SOME_VERSION := "1.2.3"

# Print this help
default:
    @just -l

# Format Justfile
format:
    @just --fmt --unstable

# Install git commit hooks
githooks:
    #!/usr/bin/env nu
    let hooks_folder = '.githooks'
    if (git config core.hooksPath) != $hooks_folder {
      print 'Installing git commit hooks'
      mkdir $hooks_folder
      git config core.hooksPath $hooks_folder
    }
    if not ($hooks_folder | path exists) {
      "#!/usr/bin/env sh\nset -eu\necho 'ERROR: customize this git commit hook.'\nexit 1" | save $"($hooks_folder)/pre-commit"
      chmod 755 $"($hooks_folder)/pre-commit"
      git add $hooks_folder
    }

# Lint configuration
lint:
    tflint --recursive

# Create a new release of this module. LEVEL can be one of: major, minor, patch, premajor, preminor, prepatch, or prerelease.
release LEVEL="patch":
    #!/usr/bin/env nu
    if (git rev-parse --abbrev-ref HEAD) != "main" {
      print -e "ERROR: A new release can only be created on the main branch."
      exit 1
    }
    if (git status --porcelain | wc -l) != "0" {
      print -e "ERROR: Repository contains uncommited changes."
      exit 1
    }
    let current_version = (git describe | str replace -r "-.*" "" | deno run npm:semver $in)
    let new_version = ($current_version | deno run npm:semver -i "{{ LEVEL }}" $in)
    print "Changelog:\n"
    git cliff --strip all -u -t $new_version
    input -s $"Version will be bumped from ($current_version) to ($new_version).\nPress enter to confirm.\n"
    ["examples/1Region_3ControlPlane_3Worker_Nodes/main.tf", "examples/3Regions_3ControlPlane_3Worker_Nodes/main.tf"] | par-each {|file|
      open --raw $file | str replace -r "\\?ref=.*" $"?ref=($new_version)\"" | str replace -r ' version *= *".*"' $" version = \"($new_version)\"" | save -f $file
      tofu fmt $file
      git add $file
    }
    git cliff -t $new_version -o CHANGELOG.md
    git add CHANGELOG.md
    git commit -m $"Bump version to ($new_version)"
    git tag -s -m $new_version $new_version
    git push --atomic origin refs/heads/main $"refs/tags/($new_version)"
    git cliff --strip all --current | gh release create -F - $new_version examples/1Region_3ControlPlane_3Worker_Nodes/main.tf

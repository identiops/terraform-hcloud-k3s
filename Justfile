#!/usr/bin/env just --justfile
# Documentation: https://just.systems/man/en/

set shell := ["nu", "-c"]

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

# Install commit hooks
husky_install:
    #!/usr/bin/env nu
    if (git config core.hooksPath) != ".husky" or (".husky/_/husky.sh" | path exists | not in) {
      print "Installing git commit hooks"
      npx husky install
      git config core.hooksPath .husky
      rm .husky/_/.gitignore # commit huskey
      git add .husky
    }

# Add pre-commit hook
husky_add_pre-commit_hook:
    #!/usr/bin/env nu
    npx husky add .husky/pre-commit
    print "Add pre-commit hook with: npx husky add .husky/pre-commit"

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
    let current_version = (git describe | str replace -r "-.*" "" | npx semver $in)
    let new_version = ($current_version | npx semver -i "{{ LEVEL }}" $in)
    input -s $"Version will be bumped from ($current_version) to ($new_version).\nPress enter to confirm.\n"
    open --raw examples/main.tf | str replace -r "\\?ref=.*" $"?ref=($new_version)\"" | save -f examples/main.tf
    git cliff -t $new_version -o CHANGELOG.md
    git add examples/main.tf CHANGELOG.md
    git commit -m "chore: bump version"
    git tag -s -m $new_version $new_version
    git push --atomic origin refs/heads/main $"refs/tags/($new_version)"

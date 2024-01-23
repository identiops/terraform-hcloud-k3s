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

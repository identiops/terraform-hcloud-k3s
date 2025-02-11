#!/usr/bin/env just --justfile
# Documentation: https://just.systems/man/en/
# Documentation: https://www.nushell.sh/book/
#
# Shell decativated so that bash is used by default. This simplifies CI integration
# set shell := ['nu', '-c']
# See https://hub.docker.com/r/nixos/nix/tags

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
    $env.config = { use_ansi_coloring: false, error_style: "plain" }
    let hooks_folder = '.githooks'
    let git_hooks_folder = do {git config core.hooksPath} | complete
    if $git_hooks_folder.exit_code == 0 and $git_hooks_folder.stdout != $hooks_folder {
      print -e 'Installing git commit hooks'
      git config core.hooksPath $hooks_folder
      # npm install -g @commitlint/config-conventional
    }
    if not ($hooks_folder | path exists) {
      mkdir $hooks_folder
      "#!/usr/bin/env -S sh
    set -eu
    just test" | save $"($hooks_folder)/pre-commit"
      chmod 755 $"($hooks_folder)/pre-commit"
      "#!/usr/bin/env -S sh
    set -eu
    MSG_FILE=\"$1\"
    PATTERN='^(fix|feat|docs|style|chore|test|refactor|ci|build)(\\([a-z0-9/-]+\\))?!?: [a-z].+$'
    if ! head -n 1 \"${MSG_FILE}\" | grep -qE \"${PATTERN}\"; then
            echo \"Your commit message:\" 1>&2
            cat \"${MSG_FILE}\" 1>&2
            echo 1>&2
            echo \"The commit message must conform to this pattern: ${PATTERN}\" 1>&2
            echo \"Contents:\" 1>&2
            echo \"- follow the conventional commits style (https://www.conventionalcommits.org/)\" 1>&2
            echo 1>&2
            echo \"Example:\" 1>&2
            echo \"feat: add super awesome feature\" 1>&2
            exit 1
    fi" | save $"($hooks_folder)/commit-msg"
      chmod 755 $"($hooks_folder)/commit-msg"
      # if not (".commitlintrc.yaml" | path exists) {
      # "extends:\n  - '@commitlint/config-conventional'" | save ".commitlintrc.yaml"
      # }
      # git add $hooks_folder ".commitlintrc.yaml"
      git add $hooks_folder
    }

# Lint configuration
lint:
    tflint --recursive

_bump_files CURRENT_VERSION NEW_VERSION:
    #!/usr/bin/env nu
    ["examples/1Region_3ControlPlane_3Worker_Nodes/main.tf", "examples/3Regions_3ControlPlane_3Worker_Nodes/main.tf"] | each {|file|
      open --raw $file | str replace -r '\?ref=[^"]*' "?ref={{ NEW_VERSION }}" | str replace -r '^\s*version *= *".*"' 'version = "{{ NEW_VERSION }}"' | collect | save -f $file
      tofu fmt $file
      git add $file
    }
    null

# Bump version. LEVEL can be one of: major, minor, patch, premajor, preminor, prepatch, or prerelease.
bump LEVEL="patch" NEW_VERSION="":
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
    let new_version = if "{{ NEW_VERSION }}" == "" {$current_version | deno run npm:semver -i "{{ LEVEL }}" $in | lines | get 0} else {"{{ NEW_VERSION }}"}
    print "\nChangelog:\n"
    git cliff --strip all -u -t $new_version
    input -s $"Version will be bumped from ($current_version) to ($new_version)\nPress enter to confirm.\n"
    just _bump_files $current_version $new_version
    git cliff -t $new_version -o CHANGELOG.md; git add CHANGELOG.md
    git commit -n -m $"Release version ($new_version)"
    let new_tag = pwd | path split | reverse | drop (git rev-parse --show-toplevel | path split | length) | reverse | append $new_version | str join "/"
    git tag -s -m $new_tag $new_tag
    git push --atomic origin refs/heads/main $"refs/tags/($new_tag)"
    git cliff --strip all --current | gh release create -F - $new_tag examples/1Region_3ControlPlane_3Worker_Nodes/main.tf

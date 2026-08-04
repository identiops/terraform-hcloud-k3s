#!/usr/bin/env just --justfile
# Documentation: https://just.systems/man/en/
# Documentation: https://www.nushell.sh/book/

set shell := ["bash", "-euo", "pipefail", "-c"]

import '.justlib/default.just'
import '.justlib/bump.just'

# Print this help
[group("internal")]
default:
    @just -l

# Format code
[group("code")]
format-code:
    tofu fmt

# Lint configuration
[group("code")]
lint:
    tflint --recursive

alias test := lint

_bump_files CURRENT_VERSION NEW_VERSION:
    #!/usr/bin/env nu
    let current_version = "{{ CURRENT_VERSION }}"
    let new_version = "{{ NEW_VERSION }}"
    ["examples/1Region_3ControlPlane_3Worker_Nodes/main.tf", "examples/3Regions_3ControlPlane_3Worker_Nodes/main.tf"] | each {|file|
      open --raw $file | lines | str replace -ar '\?ref=[^"]*' $"?ref=($new_version)" | str replace -ar '^\s*version\s*=\s*".*"' $'version = "($new_version)"' | collect | save -f $file
      tofu fmt $file
    }
    null

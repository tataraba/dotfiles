set dotenv-load := false
set export := true

# Provide a default name for any new projects
project-name := "new-project"


@_default:
    just --list

@_fmt:
    just --fmt --unstable


# Creates a project with or without src layout based on uv init command.
_uv-init type project:
    #!/bin/bash

    TYPE="${type}"
    PROJECT_NAME="$project"

    if [ "$TYPE" == "library" ]; then
        uv init --lib "$PROJECT_NAME"
    else
        uv init --app "$PROJECT_NAME"
        rm "$PROJECT_NAME"/hello.py
    fi


@_install-uv:
    python -m pip install \
                --disable-pip-version-check \
                --no-compile \
                --upgrade \
            pip uv


# Create a new library with src layout. Used for packaging.
@new-library name=project-name:
    mkdir {{ name }}
    just bootstrap library {{ name }}
    cd {{ name }} && touch .envrc && echo "layout uv" >> .envrc && direnv allow

# Create a new application. Useful for web apps, scripts, or CLIs.
@new-app name=project-name:
    mkdir {{ name }}
    just bootstrap app {{ name }}
    cd {{ name }} && touch .envrc && echo "layout uv" >> .envrc && direnv allow

# Bootstrap a new project
bootstrap type project:
    #!/bin/bash
    set -euxo pipefail
    if command -v uv &> /dev/null; then 
        just _uv-init {{ type }} {{ project }}; 
    else 
        echo "Installing UV"
        just _install-uv
        just _uv-init {{ type }} {{ project }} 
    fi
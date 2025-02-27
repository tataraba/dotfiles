set dotenv-load := false
set export := true

# Provide a default name for any new projects
name := "new-project"


@_default:
    just --list

@_fmt:
    just --fmt --unstable


# Creates a project with or without src layout based on uv init command.
_uv-init type project:
    #!/usr/bin/env bash
    set -euo pipefail

    TYPE="${type}"
    PROJECT_NAME="$project"

    if [ "$TYPE" == "lib" ]; then
        uv init --lib "$PROJECT_NAME"
    elif [ "$TYPE" == "cli" ]; then
        uv init --app "$PROJECT_NAME"
        rm "$PROJECT_NAME"/hello.py
        mkdir "$PROJECT_NAME"/$PROJECT_NAME
        echo "__app_name__ = \"$PROJECT_NAME\"" >> "$PROJECT_NAME"/$PROJECT_NAME/__init__.py
        echo "__version__ = \"0.0.1\"" >> "$PROJECT_NAME"/$PROJECT_NAME/__init__.py
        cat .template/_cli.py >> "$PROJECT_NAME"/$PROJECT_NAME/cli.py
        cat .template/_main.py >> "$PROJECT_NAME"/$PROJECT_NAME/__main__.py
    else
        uv init --app "$PROJECT_NAME"
        rm "$PROJECT_NAME"/hello.py
    fi

    cp .gitignore "$PROJECT_NAME"/.gitignore
    cat .pyproject-ruff.toml >> "$PROJECT_NAME"/pyproject.toml
    cd "$PROJECT_NAME" && touch .envrc && echo "layout uv" >> .envrc && direnv allow

    if [ "$TYPE" == "cli" ]; then
        echo "Installing typer..."
        uv add typer --project "$PROJECT_NAME"
    fi

@_install-uv:
    #!/usr/bin/env bash
    set -euo pipefail
    if {{ os_family() }} == "windows"; then
        echo "# For Windows, please visit https://docs.astral.sh/uv/getting-started/installation/ for instructions on how to install uv."
        exit 1
    if ! command -v uv &> /dev/null;
    then
      echo "uv is not found on path! Starting install..."
      curl -LsSf https://astral.sh/uv/install.sh | sh
    else
      uv self update
    fi


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

# Create a new application. Use "lib" type for library.
@create name=name type="app":
    mkdir {{ name }}
    just bootstrap {{ type }} {{ name }}






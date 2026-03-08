#!/bin/bash

# check flag
command_exists() {

    command -v "$1" >/dev/null 2>&1

}

# Remove whitespace/ blank lines from requirements.txt
get_clean_requirements() {
    sed -e 's/#.*//' -e '/^[[:space:]]*$/d' -e 's/[[:space:]]//g' requirements.txt
}


# Function to install Poetry
install_poetry() {
    echo "Installing Poetry..."
    curl -sSL https://install.python-poetry.org | python3 -
    # Add to current path so the script can continue
    export PATH="$HOME/.local/bin:$PATH"
}


install_uv() {
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Add to current path so the script can continue
    export PATH="$HOME/.cargo/bin:$PATH"
}


migrate_to_poetry() {

    echo "Migrating to Poetry..."
    [ ! -f "pyproject.toml" ] && poetry init --no-interaction
    
    # Use the cleaned list of packages
    local reqs=$(get_clean_requirements)
    if [ -n "$reqs" ]; then
        # We pass the list to 'add'; xargs handles the conversion to arguments
        echo "$reqs" | xargs poetry add
    fi

}


migrate_to_uv() {
    echo "Migrating to uv..."
    # uv init sets up the project structure and pyproject.toml
    [ ! -f "pyproject.toml" ] && uv init
    
    if [ -f "requirements.txt" ]; then
        # 'uv add -r' is the specialized command for this exact task
        uv add -r requirements.txt
    fi
}


# exit if no command
set -e



# Check for reqs
if [ ! -f "requirements.txt"]; then

    echo "No requirements.txt found in current directory, exiting."

    exit 1

fi


echo "Select Target Manager: (1) Poetry (2) uv"

read -p "> " choice

case $choice in

    1)

        command_exists poetry || install_poetry
        migrate_to_poetry
        ;;

    2)

        command_exists uv || install_uv
        migrate_to_uv
        ;;

    *)

        echo "Invalid choice." ; exit 1 ;;

esac


mv requirements.txt requirements.txt.bak

echo "Migration complete." 
#!/usr/bin/env bash

clean_requirements() {
    # 1. Remove comments
    # 2. Delete empty lines
    # 3. Remove inline whitespace
    sed -e 's/#.*//' -e '/^[[:space:]]*$/d' -e 's/[[:space:]]//g' "$1"
}



# check and get requirements
if [[ ! -f "requirements.txt" ]]; then
    echo "No requirements.txt found in current directory"
    exit 1
fi

# check command exists (poetry)
if  ! command -v poetry &> /dev/null; then
    echo "Poetry not found, installing"
    curl -sSL https://install.python-poetry.org | python3 -
    export PATH="$HOME/.local/bin:$PATH"
fi

# poetry init
if [[ ! -f "pyproject.toml" ]]; then
    echo "Initialising poetry"
    poetry init --no-interaction
fi

# Dependencies
deps=$(clean_requirements "requirements.txt")

for dep in $deps; do
    echo "Adding $dep"
    poetry add "$dep"
done

echo "Migration from pip2poetry complete"
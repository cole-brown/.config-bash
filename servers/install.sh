#!/usr/bin/env bash

_install_path_script="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# ------------------------------
# Ensure files exist...
# ------------------------------

dc_path_bash_init="$HOME/.bashrc"

dc_init_name=".bash.sh"
dc_init_path="${_install_path_script}/${dc_init_name}"

if [[ ! -f "$dc_path_bash_init" ]]; then
    echo "No '$HOME/.bashrc' file; cannot install."
    exit 1
fi

if [[ ! -f "$dc_init_path" ]]; then
    echo "No '$dc_init_path' file; cannot install."
    exit 2
fi

# ------------------------------
# Try to not double install.
# ------------------------------

if grep "$dc_init_name" "$dc_path_bash_init"; then
    # Separate from grep's output?
    echo
    echo "'$dc_init_name' already referenced in '$dc_path_bash_init'... Aborting install."
    exit 3
fi

# ------------------------------
# Install.
# ------------------------------

cat <<EOF >>"$dc_path_bash_init"

if [[ -f "$dc_init_path" ]]; then
    source "$dc_init_path"
fi
EOF

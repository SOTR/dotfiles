#!/bin/bash


vim_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "Calling setup script in $vim_dir"

[ -z "$VUNDLE_URI" ] && VUNDLE_URI="https://github.com/gmarik/vundle.git"

setup_vundle() {
    vim \
        "+set nomore" \
        "+BundleInstall!" \
        "+BundleClean" \
        "+qall"
}

sync_repo() {
    local repo_path="$1"
    local repo_uri="$2"
    local repo_branch="$3"
    local repo_name="$4"

    echo "Trying to update $repo_name in $repo_path"

    if [ ! -e "$repo_path" ]; then
        echo "Trying to clone repo $repo_uri in $repo_path"
        mkdir -p "$repo_path"
        git clone -b "$repo_branch" "$repo_uri" "$repo_path"
        ret="$?"
        echo "Successfully cloned $repo_name."
    else
        echo "Trying to update repo in $repo_path"
        cd "$repo_path" && git pull origin "$repo_branch"
        ret="$?"
        echo "Successfully updated $repo_name"
    fi
}

sync_repo       "$HOME/.vim/bundle/vundle" \
                "$VUNDLE_URI" \
                "master" \
                "vundle"

setup_vundle

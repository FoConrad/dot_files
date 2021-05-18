#!/usr/bin/env bash

echo "Execute this at your own risk. Better to do by hand"
exit 1

OH_MY_ZSH_REL_PATH="../oh-my-zsh"

check_n_link() {
    if [[ "$#" -ne 2 ]]; then
        >&2 echo "Please pass absolute path of real_file then the link_file"
        exit 1
    fi

    local real_file="$1"
    local link_file="$2"

    if [[ -e "${link_file}" ]]; then
        >&2 echo "A file already exists where you want the link"
        ls -l "${link_file}"
    fi

    ln -s "${real_file}" "${link_file}"
}

# My theme
check_n_link "$(pwd)/conrad.zsh-theme" "${OH_MY_ZSH_REL_PATH}/themes/conrad.zsh-theme"

# directories lib
check_n_link "$(pwd)/directories.lib.zsh" "${OH_MY_ZSH_REL_PATH}/lib/directories.zsh"

# git plugin
check_n_link "$(pwd)/git.plugin.zsh" "${OH_MY_ZSH_REL_PATH}/plugins/git/git.plugin.zsh"

# tmux plugin
check_n_link "$(pwd)/tmux.plugin.zsh" "${OH_MY_ZSH_REL_PATH}/plugins/tmux/tmux.plugin.zsh"

# vi-mode plugin
check_n_link "$(pwd)/vi-mode.plugin.zsh" "${OH_MY_ZSH_REL_PATH}/plugins/vi-mode/vi-mode.plugin.zsh"

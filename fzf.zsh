# Setup fzf
# ---------
if [[ ! "$PATH" == */home/con/config/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/con/config/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/con/config/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/con/config/fzf/shell/key-bindings.zsh"

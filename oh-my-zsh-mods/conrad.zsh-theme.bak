# Simple theme based on my old zsh settings.

function get_host {
	echo '@'$HOST
}

MODE_INDICATOR_NORMAL="%{$fg_bold[red]%}N%{$reset_color%}"
MODE_INDICATOR_INSERT="%{$fg_bold[blue]%}I%{$reset_color%}"

local ret_status="%(?:%{$fg_bold[green]%}?:%{$fg_bold[red]%}%S?%s%?)"
PROMPT='%{$fg[green]%}% $?%{$reset_color%}$(vi_mode_prompt_info)> '
RPROMPT='%~$(git_prompt_info) ''!%{%B%F{cyan}%}%!%{%f%k%b%}'


ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_PREFIX="("
ZSH_THEME_GIT_PROMPT_SUFFIX=")"

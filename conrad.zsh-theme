# Simple theme based on my old zsh settings.

function get_host {
	echo '@'$HOST
}

_fix_cursor() {
   echo -ne '\e[1 q'
}

preexec_functions+=(_fix_cursor)

function get_job_count() {
    local job_arg=""

    [[ "$1" == "-r" || "$1" == "-s" ]] && job_arg="$1"

    jobs $job_arg | grep -E '^\[[0-9]+\]' | wc -l | xargs echo
}

STOPPED_JOB_DOTS=""
RUNNING_JOB_DOTS=""
function get_dots() {
    local ret="$?"
    local nstopped="$(get_job_count -s)"
    local nrunning="$(get_job_count -r)"

    [[ "$nstopped" -gt 0 ]] && STOPPED_JOB_DOTS="$(printf '●%.0s' {1..$nstopped})" || STOPPED_JOB_DOTS=''
    [[ "$nrunning" -gt 0 ]] && RUNNING_JOB_DOTS="$(printf '●%.0s' {1..$nrunning})" || RUNNING_JOB_DOTS=''
    echo -n "%{$fg_bold[red]%}$STOPPED_JOB_DOTS%{$reset_color%}%{$fg_bold[green]%}$RUNNING_JOB_DOTS%{$reset_color%}"
    [[ "$nrunning" -gt 0 || "$nstopped" -gt 0 ]] && echo -n ' '
    (exit $ret)
}


MODE_INDICATOR_NORMAL="%{$fg_bold[red]%}%{\e[1 q%}%{$reset_color%}"
MODE_INDICATOR_INSERT="%{$fg_bold[red]%}$STOPPED_JOB_DOTS%{$reset_color%}%{$fg_bold[green]%}$RUNNING_JOB_DOTS%{$reset_color%}%{$fg_bold[blue]%}%{\e[5 q%}%{$reset_color%}"

local ret_status="%(?:%{$fg_bold[green]%}?:%{$fg_bold[red]%}%S?%s%?)"
PROMPT='$(get_dots)''%{$fg[green]%}% $?%{$reset_color%}$(vi_mode_prompt_info)> '
RPROMPT='%~$(git_prompt_info) ''!%{%B%F{cyan}%}%!%{%f%k%b%}'


ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_PREFIX="("
ZSH_THEME_GIT_PROMPT_SUFFIX=")"

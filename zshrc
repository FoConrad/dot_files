###################################### # ######################################
################################ Conrad Config ################################
###################################### # ######################################

# Stop ctrl-s from freezing the screen in vim. See
# https://unix.stackexchange.com/questions/12107/how-to-unfreeze-after-accidentally-pressing-ctrl-s-in-a-terminal
# or similar search results
stty -ixon

############### General exports, only page when output is long ################
export XDG_CONFIG_HOME="$HOME/.config"
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig
export LIBRARY_PATH=$LD_LIBRARY_PATH  # Probably vestigal

PATH="${PATH}"
add_to_path() {
    local pos="-b"
    if [[ "$#" -eq 2 ]]; then
        pos="$1"
        shift
    fi
    
    # Don't re-add once tmux fires
    if [[ -n "${TMUX}" ]]; then
        [[ "$pos" == "-f" ]] && PATH="${1}:${PATH}" || PATH="${PATH}:${1}"
    fi

    echo "${PATH}"
}

# readline exports which might have to be specified. No problem as of yet, but
# listing here for reference

## readline is keg-only, which means it was not symlinked into /usr/local,
## because macOS provides the BSD libedit library, which shadows libreadline.
## In order to prevent conflicts when programs look for libreadline we are
## defaulting this GNU Readline installation to keg-only.

# For compilers to find readline you may need to set:
#   export LDFLAGS="-L/usr/local/opt/readline/lib"
#   export CPPFLAGS="-I/usr/local/opt/readline/include"

# For pkg-config to find readline you may need to set:
#   export PKG_CONFIG_PATH="/usr/local/opt/readline/lib/pkgconfig"

################################ golang stuff #################################
export GOPATH=${HOME}/build/go
export PATH="$(add_to_path ${GOPATH}/bin)"

export EDITOR='vim'
export LESS="-F -X -R $LESS"

export CUPS_USER='conradbc'
export DOCKER_USER="foconrad" # rel. ~/config/docker.plugin.zsh/docker_util.zsh
# export LANG=en_US.UTF-8  # may need manual setting

########################## zsh exports and settings ###########################
export ZSH="${HOME}/.oh-my-zsh"
export ZSH_DISABLE_COMPFIX=true # hack
ZSH_THEME="conrad"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
DISABLE_AUTO_TITLE="true"
KEYTIMEOUT=10 # For going into insertion mode

plugins=(git tmux autojump vi-mode docker iterm2)
################################# Keybindings #################################
bindkey -v
bindkey -M viins 'kj' vi-cmd-mode  # @todo - THIS DOES NOT WORK?
bindkey '^q' push-line-or-edit

source $ZSH/oh-my-zsh.sh

setopt HIST_IGNORE_SPACE
setopt hist_ignore_dups

########### Nonessential and external configs / utility definitions ###########
source $HOME/config/rockerbox_profile # Env vars, and some docker funcs
source $HOME/config/rbuid_funcs # Functions for emulating pixel fires

source $HOME/config/docker.plugin.zsh/docker_util.zsh

###################### Override run-help to use zsh func ######################
autoload -Uz vman

unalias run-help
autoload run-help

########################## Alias' and redefinitions ###########################

# Program corrections
alias scala='/usr/local/Cellar/scala@2.11/2.11.12/bin/scala'
alias awk='/usr/bin/env gawk'
alias vmore="vim -u ${HOME}/config/vim.less"

alias -g L="|less"
alias -g V="|vim -u ${HOME}/config/vim.less -"
alias -g X="|bash -x"
# See no evil...
alias -g E='2>/dev/null'
alias -g B='&>/dev/null &'
alias -g Q='>/dev/null'
# Trick the following command about the status of the display
alias -g DY="DISPLAY=':0.0'"
alias -g DN="DISPLAY=''"
alias -g J='-j$(nproc)'
alias -g cG=' | grep --color=yes -E '

# alias :e for vim has been moved to function below where it now accepts the -p
# flag, to open up files found in the paste buffer
alias ':q'='exit'
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'
alias -s tex=vim
alias -s java=vim
alias -s c=vim
alias -s h=vim
alias -s cpp=vim
alias ll='ls -latr'

alias bash5="/usr/local/Cellar/bash/5.0.11/bin/bash"
alias hist="vim -R ${HOME}/.zsh_history"
alias scratch="vim -c 'setlocal buftype=nofile' -c 'setlocal bufhidden=hide' -c 'setlocal noswapfile'"

# Some import aliases (not sure why lorem is a function...)
alias gcommit="git status -uno | grep '^\s*modified' | awk '{print \$2}' | xargs echo git commit -m tmp"
alias gcur="git branch | grep '^\*' | cut -f2 -d' '"

# Tmux start scripts
alias work_t='~/config/tmux_starts/dev-work.tmux'
alias pyplay_t='~/config/tmux_starts/py-play.tmux'
alias sicp_t='~/config/tmux_starts/sicp.tmux'

# Aliases for viewing and chosing a dev-work session
alias rb_work="~/dot_files/tmux_starts/rb_work.sh"
alias rbw="rb_work"

# Short cut to editing common files
alias ezsh='vim ~/.zshrc'
alias evim='vim ~/.vimrc'
alias essh='vim ~/.ssh/config'
alias etmux='vim ~/.tmux.conf'
alias ehosts='vim /etc/hosts'
alias sehosts='sudo vim /etc/hosts'

# Zsh autocomplete pattern so that vim will ignore trying to open .pyc
zstyle ':completion:*:*:vim:*' file-patterns '^*.(aux|log|pyc):source-files' '*:all-files'

_vftf() {
    echo vim -R -c "set ft=$1" -
    vim -R -c "set ft=$1" -
}
alias -g VFT='| _vftf'

########################### Zsh autoload functions ############################

# XXX, NOTE: To future self, if you are thinking of adding to fpath, please
# move this export and organize better
export fpath=( ~/dot_files/zsh_autoload "${fpath[@]}" )

autoload -Uz jump_back
alias jb='jump_back'

autoload -Uz  gdiff_add
alias gdiffa='gdiff_add'

autoload -Uz  remove_swaps
alias rmswp='remove_swaps'

#autoload -Uz  pyparse
#alias parse='pyparse'
############# On to useful functions and the wild west for hacks ##############

# Implementing basic alias for :e to add -p flags which opens all files in
# paste buffer for editing
:e() {
    # Please replace pbpaste with your systems paste board for example:
    #   xclip -selection clipboard -out

    if [[ "$#" -gt 0 && $1 = '-p' ]]; then
        shift 1 
        # NOTE: Currently all files in paste buffer need to be single words,
        # but command line arg files can be multiple:
        #   :e Geeks.java 'Hello World.java'

        local file_array=( $(pbpaste | xargs echo ) )
        local all_files=( "${file_array[@]}" "$@" )
    else
        local all_files=( "$@" )
    fi

    local cmd="vim"
    for argy_wargy in "${all_files[@]}"; do
        cmd="${cmd}  '${argy_wargy}'"
    done

    eval "$cmd"
}

nargs() {
    echo "$#"
}

# Start a shell without rc files or profiles. Shells acceptrd are
# zsh, bash (for bash 5), and bash3
norc() {
    local exec_v=""
    local shell="$(which zsh)"
    local args="-df"

    [[ "$#" -gt 0 && "$1" = "-e" ]] && {
        exec_v="exec";
        shift;
    }

    if [[ "$#" -gt 1 && "$2"  =~ ^[^35]$ ]] || [[ "$#" -gt 0 && ! "$1" =~ ^(zsh|bash[35]?)$ ]]; then
        # Args can be: {}, zsh, bash, bash3, bash5, bash 3, bash 5.
        echo "Usage (regex desc.): norc [-e] [zsh|bash ?[3|5]]"
        return 1
    fi

    #if  [[ "$1" = "bash" && "$2" -eq 5 || "$1" = "bash5" ]]; then
    if  [[ "$1" =~ "^bash" ]]; then
        [[ "$1" =~ 3$ || "$2" -eq 3 ]] && \
            shell=/bin/bash || \
            shell="/usr/local/Cellar/bash/5.0.11/bin/bash" 
        # Where this function got its name from
        args="--norc --noprofile"
    fi
    eval "$exec_v $shell $args"
}

# Making a quick and dirty tree command for pprinting dir structures. Next proj
# is to make one in scala
dtree() {
    local usage_str='usage: dtree [-i <indent-level>] [-f (only directories)]'
    usage_str="${usage_str} [-h (no hidden files/dirs)] <target-dir>"

    local indent_level=4
    local ignore_files_f=""
    local ignore_hiddens_h=""

    while getopts "i:fh" opt; do
        case "${opt}" in
            i) indent_level="${OPTARG}"
                ;;
            f) local ignore_files_f="-type d"
                ;;
            h) local ignore_hiddens_h="-not -path */\.*"
                ;;
            *) >&2 echo "${usage_str}"
                ;;
        esac
    done
    shift $((OPTIND-1))
    local indent_str=$(printf '_%.0s' {1.."$indent_level"})

    # It is terrible I am relying on not quoting these variables to split the
    # args
    find "$@" ${=ignore_hiddens_h} ${=ignore_files_f} -print | \
        sed -e 's;[^/]*/;|'"${indent_str};g;s;${indent_str}|; |;g"
}

export DOCK_RUNNER_HOME="/Users/conrad/projects/dr/configs/main_config"
ddr() {
    VENV_PATH="/Users/conrad/projects/dr/dwenv/bin/activate"
    source "${VENV_PATH}"

    python -m dr "$@"
    deactivate
}

# TODO: Cleanup
parse() {
    VENV_PATH="/Users/conrad/projects/command_line_config_parser/penv/bin/activate"
    source "${VENV_PATH}"

    eval python -m parse --pprint "$1" --config-file "$2"
    deactivate
}

tmd() {
    MDENV_PATH="/Users/conrad/build/term_md/md_env/bin/activate"
    source "${MDENV_PATH}"

    THEME="953.3567"

    if [[ "$#" -gt 0 ]]; then
        mdv -t "${THEME}" "$1" | less
    else
        mdv -t "${THEME}"  <(cat) | less
    fi
    
    deactivate
}

# TODO: Clean up
entr_fire() { # aliased to ef
    [[ "$#" -eq 0 || "$1" =~ '^(-h|--help)$' || ! ( -e "$1" || "$#" -gt 1 ) ]] && {
        cat <<EOF >&2
usage: entr_fire <file or file-command> [<entr-comand>]
    Note: 1) if <file> is not a file, then <file-command> is executed to provide
             file names for entr
          2) if <file> exists and no second arg is provided, the command ./<file> is
             executed. if <file-command> is provided, a command must be provided
EOF
        return 1
    }

    local fcmd="echo $1"
    [[ ! -e "$1" ]] && fcmd='eval $1'

    [[ "$#" -gt 1 ]] && local entr_cmd="entr $2" || local entr_cmd="entr ./$1"

    echo "> $fcmd | $entr_cmd"
    eval "$fcmd | $entr_cmd"
}

markdown_watch() {
    local md_file="$1"
    open "$md_file" -a Google\ Chrome
}

# TODO: This needs some final, minor, small, left-as-exercise-to-reader level
#       edits to get in running condition
cols() {
    python ${HOME}/config/script_funcs/cols.py "$@"
}

notify() {
    [[ "$#" -eq 0 || "$1" =~ '^(-h|--help)$' ]] && {
        >2 echo "usage: notify [--help|-h|-a|-n] <message>";
        exit;
    }

    local notify_type="notification"
    [[ "$#" -gt 1 && "$1" =~ "^-[ae]$" ]] && { notify_type="alert"; shift }
    [[ "$#" -gt 1 && "$1" =~ "^-n$" ]] && shift

    echo "osascript -e 'display ${notify_type} \"$@\"'" | bash -x
}

# More easily loading files into racket vs executing them
racket-load() {
    if [[ "$#" -lt 1 ]]; then
        2> echo "usage: racket-load <script> [args]"
        return 1
    fi
    local orig_script="$1" ; shift

    local offset=$(grep -n '^#lang ' $orig_script | head -1 | cut -f1 -d:)
    [[ -z "$offset" ]] && offset="1" || offset=$((offset+1))

    local tmp_script=$(mktemp)

    tail -n +"${offset}" ${orig_script} > "${tmp_script}.scm"
    racket -if "${tmp_script}.scm" "$@"
}

winman() {
    echo brew services start yabai | bash -x
    echo brew services start skhdrc | bash -x
}

duckgo() {
	search=""
	echo "Searching for: $@"
	for term in "$@"; do
		search="$search+$term"
	done
	firefox -new-window "https://www.duckduckgo.com/?t=lm&q=$search"
}

man_grep() {
    [[ "$#" -lt 2 || "$1" =~ '^(-h|--help)$' ]] && {
        >2 echo "usage: man_grep [<grep-flags>] pattern man-page"
        exit;
    }
    echo "man '${@: -1}' | grep '${@:1:$((#-1))}'"
    man "${@: -1}" | col -b | grep "${@:1:$((#-1))}"
}

pp(){
  if [ $# -gt 0 ];then
    ping -c 5 $*
  else
    ping -c 5 google.com
  fi
}
mkcd(){
    /bin/mkdir -p $1 && cd $1
}

dt(){
  date "+%Y%m%d%H%M%S"
}

######################### Alias' for above functions ##########################

alias ef='entr_fire'

autoload -U compinit && compinit -u

france() {
  ssh -C2qTnN -D 8080 con &
  open -a "Firefox" --args -P tunnel -no-remote 2>&1 >/dev/null
}


alias boingo='echo nchriste.carleto 98McMc76'

#eval "$(thefuck --alias)"
# You can use whatever you want as an alias, like for Mondays:
#eval "$(thefuck --alias shit)"

# Allow for quick error recognition when using java make
alias make_errors='clear ; make 2>&1 | grep -E --color  "(\w+.java|[0-9]+|$)"'
# alias eclimd="tmux new-session -d -s eclimd /Applications/Eclipse.app/Contents/Eclipse/eclimd"
# Auto start eclimd if not already running
#tmux ls | grep eclimd || eclimd

alias pgen="pwgen  -s1ny 15"

alias git_grep="git branch -a | tr -d \* | sed '/->/d' | xargs git grep $1"
alias whereami='getent hosts $(hostname)'

# For use with cims_print, when it incorporates the appendix trimming
# feature.
appendix_start() {
    local file_name=$1
    local ref_page=$(pdfgrep -in 'r ?eferences' $file_name | cut -d: -f1)
    local last=0
    for app_page in $(pdfgrep -in 'a ?ppendix' $file_name | cut -d: -f1); do
        if [ "$app_page" -ge "$ref_page" ]; then
            last=$app_page
            break
        fi
    done
    echo "Remove after page $last"
}

# There are ways to reduce the size (bytes, not dimension) of the pdf, and this
# is sometimes necessary. Large pdfs sometimes do not print on the printer used
# with this function. It is not clear yet whether this is a set size, or if
# there are other factors.
# TODO: Reduce size (bytes) of pdf, if needed.
# TODO: Flag for removing appendix
# NOTE: At that point, should this just be a python script (nah, bash is fun)
cims_print() {
    local file="$1"
    shift
    if [ -f $file ] && [[ "${file##*.}" == "pdf" ]]; then
        local pages=$(pdfinfo $file | grep Pages | awk '{print $2}') || return 1
        if [ $pages -gt 10 ]; then
            echo -n "There are $pages pages in document. Continue with printing? [y/N] "
            read -r response
            response=$(echo $response | awk '{print tolower($0)}')
            [[ "$response" =~ ^(yes|y)$ ]] || return 0
        fi
        # If the pdf is not already on letter paper, convert it
        if ! pdfinfo $file | grep 'Page size.*letter' >/dev/null; then
            echo "Converting paper type to letter..."
            echo "pdfjam $file --paper letter --suffix LETTER --quiet" | bash -x
            # Base name as pdfjam produces the new pdf in current directory
            file=$(echo "$(basename ${file%.*}-LETTER.pdf)")
        fi
        echo scp $file cims: | bash -x
        echo ssh cims lpr -P BWPR16 -o Duplex=DuplexNoTumble -o media=letter $@ $(basename $file) | bash -x
    else
        echo "$file is not a pdf file"
    fi
}
alias fs='wmctrl -r ":ACTIVE:" -b toggle,fullscreen'

alias ]="xdg-open $@ 2>/dev/null || open $@"

tensor_start() {
    ssh -N -f -L ${2}:127.0.0.1:6006 FoConrad@apt${1}.apt.emulab.net
}

tensor_show() {
  ps_rows="$(ps aux | grep '[s]sh -N -f')" # | cut -f2 -d' '
  num_rows="$(echo $ps_rows | wc -l)"
  if [ -z "$ps_rows" ]; then
    echo "No sessions running..."
    return
  fi
  echo -e "Rows found:"
  while read -r line; do
    echo "  $line"
  done <<< "$ps_rows"
  kill_pid="$(echo $ps_rows | cut -f2 -d' ')"
  if [ "$num_rows" -ne 1 ]; then
    read "REPLY?Which PIDs to kill (a for all): "
    kill_pid=($(paste -s -d ' ' <(cut -f2 -d' ' <<< $ps_rows)))
    if ! [[ ${REPLY:l} =~ ^a(ll)?$ ]]; then
      for pid in ${(z)REPLY}; do
        if ! [[ ${kill_pid[(ie)$pid]} -le ${#kill_pid} ]]; then
          echo "Given PID '$pid' is not in the valid PIDs: $kill_pid"
          return 1
        fi
      done
      kill_pid=($REPLY)
    fi
  else
    read "REPLY?Kill the program? "
    if ! [[ $REPLY =~ ^[Yy]$ ]]; then
      return
    fi
  fi
  echo "kill -9 $kill_pid" | bash -x
}

func_grep() {
  func_name="$1"
  shift
  alts=1
  if [[ $func_name =~ "^\(.*\)$" ]]; then
    alts=2
  fi
  pcregrep -Mo "${func_name}\([^{]+(\{([^{}]++|(?${alts}))*\})" $@
}


pli() {
    grep $@ =(ps aux)
}
plik() {
    pli $@ | awk '{print $2}' | xargs kill -9
}
# execute 'b s' to set jump point and then 'b' to return there
b() {
    if [ $# -lt 1 ]; then
        if [ -z ${B_OLD_DIR+x} ] || [ ! -n "$B_OLD_DIR" ]; then
            return
        fi
        cd $B_OLD_DIR
    else
        export B_OLD_DIR="$(pwd)"
    fi
}

pdf_term() {
    pdftotext $1 - | less
}

qtabs() {
    ([ $# -gt 0 ] && echo "$@" || echo "$(find . -maxdepth 1 -name '*.pdf')") \
        | xargs qpdfview B
}

pdfind() {
    find . -name '*.pdf' | time xargs -n4 -I{} -P$(nproc) pdfgrep -m1 -iH "$@" {}
}

lorem() {
    /Users/conrad/dot_files/script_funcs//lorem.zsh "$@"
}

tclock() {
    while true; do 
        tput clear; date +"%H : %M : %S %b %d" | figlet -w 120
        sleep 1
    done
}

clean() {
    local dest_parent="${HOME}/Documents/desktop_move"

    [[ "$#" -gt 0 ]] && local base_target="$1" || local base_target="Desktop"
    local target="${HOME}/${base_target}"
    local dest="${dest_parent}/cleaned_${base_target}_$(dt)"

    # TODO: Improve this function to include:
    #   1. Other directories
    #   2. File type black- / white-lists to only move certain filetypes 
    #   3. Option for deleting instead of moving
    # NOTE: The lower-casing argument 1 done in ZSH style, doesn't work in bash
    if [[ "$#" -gt 0 && "${base_target:l}" != "desktop" ]]; then
        >&2 echo "Error: not implemented. Only accepts 'Desktop' or nothing"
        return 1
    fi

    if [[ "$(ls ${target} | wc -l | tr -d '[:space:]')" -eq 0 ]]; then
        return 0
    fi

    # Make directory where we'll store current Desktop files/dirs
    echo mkdir "${dest}" | bash -x
    find "${target}" -maxdepth 1 -not -path '*/\.*' -not -path "${target}"  -exec echo mv "'{}'" "${dest}" \; | bash -x

    # NOTE: The ' around variables is gucci because the command substitution,
    # and everything inside, is surrounded by double quotes "

    local files_remaining=$(find "$target" -not -path "*/\.*" -not -path "${target}")
    if [[ -n "${files_remaining}" ]]; then
        >&2 echo 'Error: some files remaining. Listed:'
        echo "${files_remaining}"
    fi

}

# Clojure setup
export PATH="$(add_to_path ${HOME}/build/clojure/leiningen)"

# Inkscape CLI (won't work GUI wihtout X)
export PATH="$(add_to_path /Applications/Inkscape.app/Contents/Resources/bin)"

alias q="QHOME=~/q rlwrap -r ~/q/l64/q"
export PATH="$(add_to_path $HOME/q/l64)"

a2q() {
    java -jar /home/con/workspace/grad/classes/advanced_databases_parent/advanced_databases/homework/hw2/aquery/aquery/target/scala-2.11/aquery.jar $*
}

what () {
    type $1
    declare -f $1 || alias $1
}

alias pwman="bash /home/con/workspace/projects/pw_man/pw_man.sh"

# aws() {
    #pwman aws
#}

[ -f ~/config/fzf.zsh ] && source ~/config/fzf.zsh
 _gen_fzf_default_opts() {
  local base03="234"
  local base02="235"
  local base01="240"
  local base00="241"
  local base0="244"
  local base1="245"
  local base2="254"
  local base3="230"
  local yellow="136"
  local orange="166"
  local red="160"
  local magenta="125"
  local violet="61"
  local blue="33"
  local cyan="37"
  local green="64"

  # Comment and uncomment below for the light theme.

  # Solarized Dark color scheme for fzf
  #export FZF_DEFAULT_OPTS="
    #--color fg:-1,bg:-1,hl:$blue,fg+:$base2,bg+:$base02,hl+:$blue
    #--color info:$yellow,prompt:$yellow,pointer:$base3,marker:$base3,spinner:$yellow
  #"
  ## Solarized Light color scheme for fzf
  export FZF_DEFAULT_OPTS="
    --color fg:-1,bg:-1,hl:$blue,fg+:$magenta,bg+:-1,hl+:$blue
    --color info:$yellow,prompt:$yellow,pointer:$base03,marker:$base03,spinner:$yellow
  "
}
_gen_fzf_default_opts


# Clipboard global aliases. Lol, make sure that the output commands are in
# single quotes or they will be expanded right now!!!!!
alias -g CO='$(pbpaste)'
alias -g CI="|pbcopy"
alias -g SO='$(pbpaste -pboard ruler)' # Mouse middle button
alias -g SI="|pbcopy -pboard ruler"

# Add some other files
source "${HOME}/config/script_funcs/pawk.sh"

alias sw="/Users/conrad/dot_files/script_funcs/timer.sh"

# Mac stuff
alias awk='/usr/bin/env gawk'
alias nproc="sysctl -n hw.ncpu"
alias cgo="source ${HOME}/work/def_py3_env/bin/activate"

alias desc='declare -f'

dget() {
    scp desk:${1} .
}

eval "$(thefuck --alias)"
# You can use whatever you want as an alias, like for Mondays:
eval "$(thefuck --alias shit)"

######################### New functions and aliases ###########################
untar() {
    if [ $# -lt 1 ]; then
        echo "Usage: untar [opts] file.tar[bz2|gz]"
        exit 1
    fi
    local args="xvf"
    
    for last_arg; do :; done
    [[ "$last" =~ "\.gz$" ]] && args="${args}z"
    [[ "$last" =~ "\.bz2$" ]] && args="${args}j"
    tar "${args}" "$@"
}
# Tmux ease
# There is tmux mode!
#alias ts='tmux new-s -s'

############################ Custom plugins as well ###########################
source ${HOME}/config/builds/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Other tools
#   yabai
alias yab="brew services start koekeishiya/formulae/yabai"
# Rot 13 in pawk. Pawk is best for iterating over input, but here we skip the
# line iteration and directly map the input file 'rfil'. Honestly, the quoting
# problem here is because of the alias, but could use a better solution
alias -g rot13="pyp3 raw 'print(\"\".join(map( \
    lambda c: c if not c.isalpha() else ( \
            lambda base: chr( base + ((ord(c)-base+13)%26) ) \
        )(ord(\"A\" if c.isupper() else \"a\")), \
    rfil.read())), end=\"\")'"

display() {
    echo "osascript -e 'display notification \"$@\"'" | bash -x
}

# Run in subshell so CD doesnt actuallt change CWD
rlink() (
    local target_file="$1"

    cd "$(dirname $target_file)"
    target_file="$(basename $target_file)"

    # Iterate down a (possible) chain of symlinks
    while [ -L "$target_file" ]; do
        target_file="$(readlink $target_file)"
        cd "$(dirname $target_file)"
        target_file="$(basename $target_file)"
    done
    echo "$(pwd -P)/${target_file}"
)

Gd() {
    grep -rnI "$1" "$2"
}

G() {
    grep -rnI "$@" .
}

Gf() {
    [[ "$#" -gt 1 ]] && local dir="$2" || local dir="."
    
    grep -onrEI ".{0,20}${1}.{0,30}" "${dir}" 2>/dev/null | sed -E -e 's/^([^[[:space:]]]*)[[:space:]]*/\1/g' -e 's/[[:space:]]*\$//g'
}
 
# TODO: Same as above but only print file_name:linum with no match showing,
# ONCE, for every file matching

trim() {
    sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*\$//g'
}

line() {
    if [[ "$1" =~ "-*" ]]; then
        # As param alread has negative sign
        tail $1 | head -1
    else
        head -$1 | tail -1
    fi
}

pfind() {
    # Indexing would have been confusing....
    local pname="${1}" ; shift
    local cols="user,pid,%cpu,%mem,start,time,command"
    ps -emo ${cols} |  { head -1; grep -i "[${pname:0:1}]${pname:1}" }
}

myip() {
    # For linux this might be 'ip addr'
    IP_ADDR_CMD='ifconfig'
    # Device specific
    IP_ADDR_DEV='en0';

    if [[ "$#" -gt 0 && "$1" = "-p" ]]; then
        dig +short myip.opendns.com @resolver1.opendns.com
    else
        # Network private ip addr
        eval "${IP_ADDR_CMD}" | grep -A3 "${IP_ADDR_DEV}"  | grep 'inet\b' | awk '{print $2}'
    fi
}

tmp_ws() {
    local _tdir="$(mktemp -d)"

    if ! [[ "$#" -gt 0 && "$1" =~ ^-?q(uiet)?$ ]]; then
    cat <<EOF
Entering session in directory > ${_tdir}
Exit current shell to remove (all files within removed permanently) in the temp.
directory and return to current directory $(pwd)"
EOF
    fi
    (
        cd "${_tdir}"
        exec "${SHELL:-zsh}"
    )
    rm -r "${_tdir}"
    if [[ "$?" -ne 0 ]]; then
        >&2 echo "Removal of temp. directory failed with command > rm -r \"${_tdir}\""
        >&2 echo "Please remove manually"
    fi
}
alias tmpws='tmp_ws'

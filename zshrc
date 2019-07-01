# Path manipulation
# Go path addition
PATH=$PATH:/usr/local/go/bin

# Stop ctrl-s from freezing the screen in vim. See
# https://unix.stackexchange.com/questions/12107/how-to-unfreeze-after-accidentally-pressing-ctrl-s-in-a-terminal
# or similar search results
stty -ixon

# Finally export it
export PATH=$PATH

# Cuda, directly from http://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#environment-setup
export PATH=/usr/local/cuda-9.1/bin:${PATH}
export LD_LIBRARY_PATH=/usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda-9.1/lib64:${LD_LIBRARY_PATH}
export LIBRARY_PATH=$LD_LIBRARY_PATH

# Path to your oh-my-zsh installation.
export ZSH=/home/con/.oh-my-zsh
export XDG_CONFIG_HOME="$HOME/.config"
PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig
export PKG_CONFIG_PATH
ZSH_THEME="conrad"
export KEYTIMEOUT=10 # For going into insertion mode

export CUPS_USER='conradbc'

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

COMPLETION_WAITING_DOTS="true"

DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(git autojump vi-mode)
bindkey -v
bindkey -M viins 'kj' vi-cmd-mode  # @todo - THIS DOES NOT WORK?

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='vim'
export LESS="-F -X $LESS"

###########Conrad Config#################

# Program corrections
alias awk='/usr/bin/env gawk'

###
setopt HIST_IGNORE_SPACE
#alias cd=' cd'
#alias ls=' ls --color=auto'


alias -g L="|less"
alias -g V="|vim -u /home/con/config/vim.less -"
#alias vmore="vim -u ~/.vim/vimrc.pager"
#alias -g V=" | vim -u ~/.vim/vimrc.pager --not-a-term -"
# See no evil...
alias -g B='&>/dev/null &'
# Trick the following command about the status of the display
alias -g DY="DISPLAY=':0.0'"
alias -g DN="DISPLAY=''"
alias -g CN="CUDA_VISIBLE_DEVICES=''"
alias -g J='-j$(nproc)'

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
  date "+%m%d%y%H%M%S"
}


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

alias cgo='source ~/builds/anaconda3/activate'
alias ]='xdg-open'

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
  grep -zPo "${func_name}\([^{]+(\{([^{}]++|(?${alts}))*\})" $@ | tr '\0' '\n' \
      | grep -zP --color=yes "${func_name}"
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
    #if [ $# -gt 0 ]; then
        #qpdfview $@ 2>/dev/null > /dev/null &
    #else
        #find . -name '*pdf' -exec qpdfview {} + 2>/dev/null > /dev/null &
    #fi
    ([ $# -gt 0 ] && echo "$@" || echo "$(find . -maxdepth 1 -name '*.pdf')") \
        | xargs qpdfview B
}

pdfind() {
    find . -name '*.pdf' | time xargs -n4 -I{} -P$(nproc) pdfgrep -m1 -iH "$@" {}
}

lorem() {
    # Hack from https://unix.stackexchange.com/questions/97160/is-there-something-like-a-lorem-ipsum-generator
    [[ "$1" =~ "^[0-9]+$" ]] && head -n $1 <(tr -dc a-z1-4 </dev/urandom | tr 1-2 ' \n' | awk 'length==0 || length>50' | tr 3-4 ' ' | sed 's/^ *//' | cat -s | sed 's/ / /g' | fmt) || echo "Please enter integer argument"
}

tclock() {
    while true; do 
        tput clear; date +"%H : %M : %S %b %d" | figlet -w 120
        sleep 1
    done
}


alias q="QHOME=~/q rlwrap -r ~/q/l64/q"
export PATH=$PATH:$HOME/q/l64
a2q() {
    java -jar /home/con/workspace/grad/classes/advanced_databases_parent/advanced_databases/homework/hw2/aquery/aquery/target/scala-2.11/aquery.jar $*
}
what () {
    type $1
    declare -f $1 || alias $1
}

vman () {
    /usr/bin/man $* V -c 'set ft=man'
}

alias dev-t='wmctrl -r ":ACTIVE:" -b add,fullscreen; ~/config/dev-tmux.sh'
alias pyplay='~/config/dev-py-play.sh'
alias pwman="bash /home/con/workspace/projects/pw_man/pw_man.sh"

aws() {
    pwman aws
}

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
    --color fg:-1,bg:-1,hl:$blue,fg+:$base02,bg+:-1,hl+:$blue
    --color info:$yellow,prompt:$yellow,pointer:$base03,marker:$base03,spinner:$yellow
  "
}
_gen_fzf_default_opts


# Clipboard global aliases. Lol, make sure that the output commands are in
# single quotes or they will be expanded right now!!!!!
alias -g CO='$(xclip -o -selection clipboard)'
alias -g CI="|xclip -i -selection clipboard"
alias -g SO='$(xclip -o -selection primary)' # Mouse middle button
alias -g SI="|xclip -i -selection primary"

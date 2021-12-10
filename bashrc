[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable to show git branch when in a git repository
# source: https://github.com/jimeh/git-aware-prompt/blob/master/prompt.sh
# added highlighting of repo part in path
function find_git_branch {
    git_subpath='/'
    local dir=${PWD} head
    until [ "$dir" = "" ]; do
        if [ -f "$dir/.git/HEAD" ]; then
            head=$(< "$dir/.git/HEAD")
            if [[ $head == ref:\ refs/heads/* ]]; then
                git_branch=" (${head#*/*/})"
            elif [[ $head != '' ]]; then
                git_describe=$(git describe --always)
                git_branch=" (detached: $git_describe)"
            else
                git_branch=' (unknown)'
	        fi
	        prompt_dir="${dir/$HOME/~}"
            return
        fi
        git_subpath="/${dir##*/}$git_subpath"
        dir="${dir%/*}"
    done
    git_branch=''
    prompt_dir="${PWD/$HOME/~}"
    git_subpath=''
}
function find_git_dirty {
    st=$(git status -s 2>/dev/null | tail -n 1)
    if [[ $st == "" ]]; then
        git_dirty=''
    else
        git_dirty='*'
    fi
}
PROMPT_COMMAND="find_git_branch; find_git_dirty; $PROMPT_COMMAND"
GREEN="\\[\\033[01;32m\\]"
WHITE="\\[\\033[00m\\]"
BLUE="\\[\\033[01;34m\\]"
CYAN="\\[\\e[1;36m\\]"
RED="\\[\\e[0;31m\\]"
YELLOW="\\[\\e[1;33m\\]"
PS1="$GREEN\u@\h$WHITE: $BLUE\$prompt_dir$CYAN\$git_subpath$RED\$git_branch$YELLOW\$git_dirty\n$WHITE\$(date +"%H:%M:%S") $BLUE\$$WHITE "

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
function alert {
    notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" \
    "$(history|tail -n1|sed -e 's/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//')"
    for i in {1..3}; do
        pacmd play-file /usr/share/sounds/gnome/default/alerts/glass.ogg alsa_output.pci-0000_00_1f.3.analog-stereo; sleep 0.2
    done
}

source ~/.shellrc

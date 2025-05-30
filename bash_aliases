# use colored commands
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# tmux always with colors
alias tmux='tmux -2'
alias c='clear'
alias cls='clear && ls'

# git
alias gst='git status'
alias ga='git add'
alias gci='git commit'
alias glg='git log --pretty=format:"%h%x09%an%x09%ad%x09%s"'
alias gc='git checkout'
alias gd='git diff'
alias gdc='git diff --cached'
alias gdg='git show --color --pretty=format:%b $@'

if which nvim >/dev/null; then
    alias vim=nvim
fi

#ktlint
alias ktlint-format='mvn antrun:run@ktlint-format | mvn clean install'

#todoist
alias todo="google-chrome --app=https://todoist.com/app/filter/2240647440"

#kubectl
alias k="kubectl"
alias z="source ~/.zshrc"
alias aws="awsv2"

# aliases files
for f in ~/dotfiles/aliases/*; do
    source $f
done

# clear ubuntu cached
alias cache-clear-ubuntu="rm -fr ~/.cache/*"

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

#docker
function dockerip() { docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $1; }

#use vimx if available
if which vimx >/dev/null; then
    alias vim=vimx
fi

#ktlint
alias ktlint-format='mvn antrun:run@ktlint-format | mvn clean install'

#notion
alias notion="google-chrome --app=http://notion.so"

#todoist
alias todo="google-chrome --app=https://todoist.com/app/filter/2240647440"

#projects
alias goprojects="cd ~/projects"
alias gopopis="cd ~/projects/react-tutorials/build-an-pp-and-master-react-in-1hour/ && vim ."
alias goscripts="cd ~/projects/janscripts/ && vim README.md"

#kubectl
alias k="kubectl"
alias z="source ~/.zshrc"

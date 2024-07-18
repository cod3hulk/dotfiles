#!/bin/zsh

# apt
alias apti='apt install'
alias apts='apt-cache search'

# neovim
alias vi='nvim'
alias vim='nvim'
alias vimdiff='nvim -d'
alias gvim='o -a VimR'

# git
alias gcob='gco $(git branch -r | cut -d "/" -f2- | fzf)'
alias gcp='git create-pull-request'
alias gpo='git push -u origin "$(git-branch-current 2> /dev/null)"'
alias gcu='git reset HEAD^'

# docker
alias compose='docker-compose'

# edit alias
alias aliases="vi ${HOME}/.dotfiles/alias/alias.zsh"

# mvn
alias mc='mvn clean'
alias mcc='mvn clean compile'
alias mct='mc test'
alias mci='mc install'
alias mcp='mc package'
alias mt='mvn test'
alias mi='mvn install'
alias mp='mvn package'

# kubernetes
alias kc='kubectx'
alias kn='kubens'
alias kl='kubectl get deployments --no-headers -o custom-columns=":metadata.name" | sed -E "s/(.*)-[0-9a-z]{8}$/\1/" | uniq | fzf | xargs -I {} stern --color always "^{}"'
alias kle='kl | ag -A 15 ERROR'
alias kp='kubectl get pods | fzf --header-lines=1 | cut -d " " -f 1 | pbcopy'
alias kd='kubectl get deployments | fzf --header-lines=1'
alias k='kubectl'

alias ff='fd'
function fs() { local dir="$(ff -t d $1 | fzf)"; [ ! -z "$dir" ] && cd "$dir"; }
alias eg='egrep'

# node 
alias ts='npx ts-node'

# tig
alias tigs="tig status"

# IntelliJ
[[ -x /snap/bin/intellij-idea-community ]] && alias ij='nohup intellij-idea-community . > /dev/null 2>&1 &'

# local aliases
[[ -f "${HOME}/.aliases.local" ]] && source "${HOME}/.aliases.local"

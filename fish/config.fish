if status is-interactive
    eval (/opt/homebrew/bin/brew shellenv)
end

set fish_greeting ""

set -gx TERM xterm-256color

# theme
set -g theme_color_scheme terminal-dark
set -g fish_prompt_pwd_dir_length 1
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_hostname always
set -g theme_display_git_default_branch yes

# aliases
alias ls "ls -p -G"
alias la "ls -A"
alias ll "ls -l"
alias lla "ll -A"
alias g git
alias c clear
alias f ranger
alias ..='cd ..'
alias ...='cd ../..'
alias nvim-dev 'docker-compose up -d --build && docker-compose exec nvim-dev fish'
abbr dcc 'docker compose exec app bash -c "g++ -I src/include src/*.cpp -o build/program"'
abbr dcr docker compose exec app ./build/program
alias dsstore "find . -name '.DS_Store' -type f -ls -delete"
command -qv nvim && alias v nvim

bind \<l peco-src

set -gx EDITOR nvim

# set -gx PATH bin $PATH
# set -gx PATH ~/bin $PATH
# set -gx PATH ~/.local/bin $PATH

# NodeJS
# set -gx PATH node_modules/.bin $PATH

# Go
# set -g GOPATH $HOME/go
# set -gx PATH $GOPATH/bin $PATH

# switch (uname)
#     case Darwin
#         source (dirname (status --current-filename))/config-osx.fish
#     case Linux
#         source (dirname (status --current-filename))/config-linux.fish
#     case '*'
#         source (dirname (status --current-filename))/config-windows.fish
# end
#
# set LOCAL_CONFIG (dirname (status --current-filename))/config-local.fish
# if test -f $LOCAL_CONFIG
#     source $LOCAL_CONFIG
# end

# Created by `pipx` on 2025-03-03 11:59:32
set PATH $PATH /Users/yuki/.local/bin

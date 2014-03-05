set fish_greeting ""

# rbenv
set PATH $HOME/.rbenv/shims $PATH

# brew
set -x HOMEBREW_NO_EMOJI "you bet"
set PATH /usr/local/{bin,sbin} $PATH

# ssl
[ -f /usr/local/share/ca-bundle.crt ]; and set -x SSL_CERT_FILE /usr/local/share/ca-bundle.crt

# git prompt
set -g GIT_PS1_SHOWDIRTYSTATE 1
set -g GIT_PS1_SHOWSTASHSTATE 1
set -g GIT_PS1_SHOWUNTRACKEDFILES 1

# bundler
source ~/.config/fish/bundler.fish

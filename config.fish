set fish_greeting ""

# brew
set -x HOMEBREW_NO_EMOJI "you bet"
set PATH /usr/local/{bin,sbin} $PATH

# arch
set PATH /opt/arch/{bin,sbin} $PATH

if [ -f /usr/local/share/chruby/chruby.fish ]
    source /usr/local/share/chruby/chruby.fish
    chruby ruby-2.1.4
end

source ~/.config/fish/bundler.fish

set fish_greeting ""

# arch
set PATH /opt/arch/{bin,sbin} $PATH

if [ -f /usr/local/share/chruby/chruby.fish ]
    source /usr/local/share/chruby/chruby.fish
    chruby ruby-2.1.4
end

source ~/.config/fish/bundler.fish

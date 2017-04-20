set fish_greeting ""

# arch
set PATH /opt/arch/{bin,sbin} $PATH

#set CHRUBY_ROOT /opt/arch
#if [ -f /opt/arch/share/chruby/chruby.fish ]
#    source /opt/arch/share/chruby/chruby.fish
#    if [ -f ~/.ruby-version ]
#        chruby (cat ~/.ruby-version)
#    end
#end
#
source ~/.config/fish/bundler.fish

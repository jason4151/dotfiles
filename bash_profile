# .bash_profile
#
# Environment variables and startup programs go here. Aliases and functions
# belong in .bashrc. System-wide settings are in /etc/profile.

#=== Shell Initialization ===#
# Source .bashrc if it exists
[ -f ~/.bashrc ] && . ~/.bashrc

#=== Path Configuration ===#
# Base PATH for all systems
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/sbin:$PATH"

#=== Terminal Settings ===#
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

#=== macOS-Specific ===#
if [[ "$OSTYPE" == "darwin"* ]] && [ -d "/opt/homebrew/bin" ]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /usr/local/opt/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# SSH aliases
[[ ! -f ~/.aliases.ssh ]] || source ~/.aliases.ssh

# Path
export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH

# Aliases
alias virc='vi ~/.zshrc; source ~/.zshrc'
alias whatsmyip='dig TXT +short o-o.myaddr.l.google.com @ns1.google.com'
alias pwgen='pwgen -sy 32 1'
alias p='cd ~/Projects'
alias t='cd ~/Projects/terraform'
alias ave="unset AWS_VAULT && aws-vault exec $1"
alias kubectl="minikube kubectl --"

export CLICOLOR=1
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd
alias ll='ls -lah'

# macOS maintenance
maintenance() {
  sudo periodic daily weekly monthly
  defaults write com.apple.dock ResetLaunchPad -bool true; killall Dock
  sudo killall -HUP mDNSResponder;sudo killall mDNSResponderHelper;sudo dscacheutil -flushcache
}

# Terraform
alias tf='terraform'
alias tfv='terraform validate'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfwl='terraform workspace list'
alias tfwn='terraform workspace new'
alias tfws='terraform workspace select'

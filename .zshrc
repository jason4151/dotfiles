# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /usr/local/opt/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Path
export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH

# Aliases
alias virc='vi ~/.zshrc; source ~/.zshrc'
alias whatsmyip='dig TXT +short o-o.myaddr.l.google.com @ns1.google.com'
alias pwgen='pwgen -sy 32 1'
alias p='cd ~/Projects'
alias t='cd ~/Projects/terraform'
alias ave="unset AWS_VAULT && aws-vault exec $1"

export CLICOLOR=1
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd
alias ll='ls -lah'

# macOS maintenance
maintenance() {
  sudo periodic daily weekly monthly
  #sudo atsutil databases -remove
  #sudo rm -rf ~/Library/{Caches,Logs}/*
  defaults write com.apple.dock ResetLaunchPad -bool true; killall Dock
  sudo killall -HUP mDNSResponder;sudo killall mDNSResponderHelper;sudo dscacheutil -flushcache
}

# Update Homebrew
brewski() {
  brew update
  brew upgrade
  brew outdated --cask 
  brew doctor
  brew missing
  brew cleanup -s
}

# AWS SSO
#aws-profile(){
#  aws sso login --profile ${1}
#  yawsso -p ${1}
#  export AWS_PROFILE=${1}
#  terraform workspace select ${1} || terraform workspace new ${1}
#}

# Terraform
alias tf='terraform'
alias tfv='terraform validate'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfwl='terraform workspace list'
alias tfwn='terraform workspace new'
alias tfws='terraform workspace select'

# SSH
#ssh-addkeys() { for i in $(find /Volumes/Private/Keys -name "*.pem"); do ssh-add --apple-use-keychain $i; done }
alias pimdev='ssh ubuntu@10.15.48.226 -i ~/.ssh/id_pim'
alias pimqa='ssh ubuntu@10.15.49.80 -i ~/.ssh/id_pim'
alias pimprod='ssh ubuntu@10.15.50.163 -i ~/.ssh/id_pim'
alias matillion='ssh centos@10.15.53.51 -i ~/.ssh/id_matillion'
alias jenkins-turbo-1='ssh ec2-user@10.15.3.129 -i ~/.ssh/id_jenkins-turbo'
alias jenkins-turbo-2='ssh ec2-user@10.15.3.216 -i ~/.ssh/id_jenkins-turbo'
alias jenkins-web-1='ssh ec2-user@10.15.3.149 -i ~/.ssh/id_jenkins-web'
alias waterbottles='ssh ubuntu@10.173.198.166 -i ~/.ssh/id_sbc-water-bottles'

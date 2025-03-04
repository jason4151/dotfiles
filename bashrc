# .bashrc
#
# Personal environment variables and startup programs go in .bash_profile.
# User-specific aliases and functions go here. System-wide settings are in
# /etc/profile and /etc/bashrc.

# Source global definitions
[ -f /etc/bashrc ] && . /etc/bashrc

# Exit if not interactive
[[ $- != *i* ]] && return

#=== Shell Environment ===#
umask 002  # Default file permissions

# Shell options
shopt -s cdspell checkwinsize histappend extglob  # Core options
[[ "${BASH_VERSINFO[0]}" -ge 4 ]] && shopt -s globstar  # Bash 4+ only
HISTCONTROL=ignoredups:erasedups
HISTSIZE=10000
HISTFILESIZE=20000

# Prompt: User@host:directory with color
PS1='\[\e[32m\]\u@\h\[\e[m\]:\[\e[33m\]\w\[\e[m\]\$ '

# Default tools
export EDITOR='vim'
export VISUAL="$EDITOR"
export PAGER='less'

#=== Core Aliases ===#
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# ls family
alias ls='ls -hF --color=auto'  # Add color on Linux
alias ll='ls -lFv'              # Long list, directories first
alias la='ls -lAFv'             # Include hidden files
alias lt='ls -ltr'              # Sort by time
alias lx='ls -lXB'              # Sort by extension
alias lk='ls -lSr'              # Sort by size

# Modern replacements (if installed)
if command -v exa >/dev/null 2>&1; then
    alias ls='exa --color=auto'
    alias ll='exa -l --git'
    alias la='exa -la --git'
fi
if command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never'
fi

#=== Less Settings ===#
export LESS='-i -N -R -S -M'
export LESSCHARSET='utf-8'
[ -x /usr/bin/lesspipe.sh ] && export LESSOPEN='|/usr/bin/lesspipe.sh %s'

#=== Navigation Shortcuts ===#
alias ..='cd ..'
alias doc='cd ~/Documents'
alias dl='cd ~/Downloads'
alias p='cd ~/Projects'
alias t='cd ~/Projects/terraform'

#=== System Monitoring ===#
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias ports='lsof -i -P | grep LISTEN'
else
    alias ports='ss -tuln'
fi
alias meminfo='free -h'
alias cpuinfo='lscpu'
alias psmem='ps aux | sort -nr -k 4 | head -10'
alias duh='du -h ~ | sort -rh | head -20'
alias mountt='mount | column -t'

#=== File & Network Utilities ===#
alias cpr='rsync -ah --progress' # Simplified rsync
alias pwgen='pwgen -sy 32 1'

#=== Kubernetes Tools ===#
# kubectl aliases
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias kx='kubectl exec -it'
alias ka='kubectl apply -f'
alias kdel='kubectl delete'

# Minikube aliases
alias m='minikube'
alias ms='minikube start'
alias mstop='minikube stop'
alias mdel='minikube delete'
alias mip='minikube ip'
alias mdash='minikube dashboard'
alias msvc='minikube service'

#=== Terraform Tools ===#
alias tf='terraform'
alias tfv='terraform validate'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfwl='terraform workspace list'
alias tfwn='terraform workspace new'
alias tfws='terraform workspace select'

#=== AWS Tools ===#
# AWS CLI shortcuts
alias awswho='aws sts get-caller-identity'  # Show current AWS identity
alias awsl='aws ec2 describe-instances --output table'  # List EC2 instances
alias awsprof='aws-vault list'  # List aws-vault profiles
alias awsiam='aws iam list-users --output table'  # List IAM users
alias awseks='aws eks list-clusters --output table'  # List EKS clusters
alias awss3ls='aws s3 ls'  # List S3 buckets
alias awss3tf='aws s3 ls s3:// --recursive | grep ".tfstate"'  # Find Terraform state files

# aws-vault integration
alias av='aws-vault'  # Base aws-vault command
alias avl='aws-vault login'  # Login to AWS console
alias ave='aws-vault exec'  # Execute command with profile
alias avs='aws-vault exec -- aws sts get-caller-identity'  # Show identity with vault

# SSM-based AWS tools
aws_jumpbox() {
    local profile="$1"
    local aws_cmd="aws"
    if [ -n "$profile" ]; then
        if ! command -v aws-vault >/dev/null 2>&1; then
            echo "Error: aws-vault not installed."
            return 1
        fi
        aws_cmd="aws-vault exec $profile -- aws"
    fi
    if ! $aws_cmd sts get-caller-identity >/dev/null 2>&1; then
        echo "Error: AWS CLI not authenticated. Configure credentials or use aws-vault."
        return 1
    fi
    AWS_ACCOUNT_ID=$($aws_cmd sts get-caller-identity --query "Account" --output text)
    if [ -z "$AWS_ACCOUNT_ID" ]; then
        echo "Error: Failed to retrieve AWS account ID."
        return 1
    fi
    AWS_ACCOUNT_NAME=$($aws_cmd organizations describe-account --account-id "$AWS_ACCOUNT_ID" --query "Account.Name" --output text 2>/dev/null || echo "Unknown")
    echo "Connected to AWS account ID: $AWS_ACCOUNT_ID (Name: $AWS_ACCOUNT_NAME)"
    AWS_INSTANCE_ID=$($aws_cmd ec2 describe-instances --filters "Name=tag:Name,Values=jump-box" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].[InstanceId]" --output text | head -n 1)
    if [ -z "$AWS_INSTANCE_ID" ]; then
        echo "Error: No running instance found with tag Name=jump-box."
        return 1
    fi
    echo "Starting SSM session to jump-box instance: $AWS_INSTANCE_ID"
    $aws_cmd ssm start-session --target "$AWS_INSTANCE_ID" --document-name AWS-StartInteractiveCommand --parameters command="bash -l"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to start SSM session."
        return 1
    fi
}

aws_portforward() {
    local profile="$1"
    local aws_cmd="aws"
    if [ -n "$profile" ]; then
        if ! command -v aws-vault >/dev/null 2>&1; then
            echo "Error: aws-vault not installed."
            return 1
        fi
        aws_cmd="aws-vault exec $profile -- aws"
    fi
    if ! $aws_cmd sts get-caller-identity >/dev/null 2>&1; then
        echo "Error: AWS CLI not authenticated. Configure credentials or use aws-vault."
        return 1
    fi
    local aws_account_id=$($aws_cmd sts get-caller-identity --query "Account" --output text)
    if [ -z "$aws_account_id" ]; then
        echo "Error: Failed to retrieve AWS account ID."
        return 1
    fi
    local aws_account_name=$($aws_cmd organizations describe-account --account-id "$aws_account_id" --query "Account.Name" --output text 2>/dev/null || echo "Unknown")
    echo "Connected to AWS account ID: $aws_account_id (Name: $aws_account_name)"
    local remote_hostname
    local port_number
    read -p "Enter the remote hostname: " remote_hostname
    read -p "Enter the port number to be used: " port_number
    if [ -z "$remote_hostname" ] || [ -z "$port_number" ]; then
        echo "Error: Hostname and port number are required."
        return 1
    fi
    echo "Retrieving instance ID for jump-box..."
    local instance_id=$($aws_cmd ec2 describe-instances --filters "Name=tag:Name,Values=jump-box" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].[InstanceId]" --output text | head -n 1)
    if [ -z "$instance_id" ]; then
        echo "Error: No running jump-box instance found."
        return 1
    fi
    echo "Starting port forwarding from localhost:$port_number to $remote_hostname:$port_number via $instance_id..."
    $aws_cmd ssm start-session \
        --target "$instance_id" \
        --document-name AWS-StartPortForwardingSessionToRemoteHost \
        --parameters "{\"host\":[\"$remote_hostname\"],\"portNumber\":[\"$port_number\"],\"localPortNumber\":[\"$port_number\"]}" \
        --region "${AWS_REGION:-us-west-2}" &
    local ssm_pid=$!
    echo "Port forwarding started (PID: $ssm_pid). Use Ctrl+C to stop."
    wait $ssm_pid
    echo "Port forwarding session ended."
}

# tfswitch integration (if installed)
if command -v tfswitch >/dev/null 2>&1; then
    alias tfs='tfswitch'  # Switch Terraform versions
fi

#=== Custom Functions ===#
findnewer() {
    [ $# -ne 2 ] && { echo "Usage: findnewer DIR DATE (e.g., 2012-12-05)"; return 1; }
    local tmpfile=$(mktemp)
    touch -d "$2" "$tmpfile"
    find "$1" -newer "$tmpfile"
    rm -f "$tmpfile"
}

filegen() {
    [ $# -ne 3 ] && { echo "Usage: filegen FILE BS COUNT"; return 1; }
    dd if=/dev/zero of="$1" bs="$2" count="$3" 2>/dev/null
}

tarcp() {
    [ $# -ne 2 ] && { echo "Usage: tarcp SOURCE DEST"; return 1; }
    tar cpf - "$1" | (cd "$2" && tar xpf -)
}

tarscp() {
    [ $# -ne 3 ] && { echo "Usage: tarscp HOSTNAME SOURCE DEST"; return 1; }
    tar cpf - "$2" | ssh "$1" "cd '$3' && tar xpf -"
}

mktar() { tar cvf "${1%/}.tar" "${1%/}"; }
mkzip() { zip -r "${1%/}.zip" "$1"; }

msvcurl() {
    [ $# -ne 1 ] && { echo "Usage: msvcurl SERVICE_NAME"; return 1; }
    minikube service "$1" --url
}

kpod() {
    [ $# -ne 1 ] && { echo "Usage: kpod POD_NAME"; return 1; }
    kubectl get pod "$1" -o wide
}

checktools() {
    for tool in terraform kubectl minikube aws aws-vault; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "$tool: installed ($($tool --version 2>&1 | head -n 1))"
        else
            echo "$tool: not found"
        fi
    done
}

set_macos_bash() {
    if [ -f "/opt/homebrew/bin/bash" ]; then
        if ! grep -q "/opt/homebrew/bin/bash" /etc/shells; then
            echo "Adding /opt/homebrew/bin/bash to /etc/shells..."
            echo "/opt/homebrew/bin/bash" | sudo tee -a /etc/shells >/dev/null
        fi
        echo "Setting default shell to /opt/homebrew/bin/bash..."
        chsh -s /opt/homebrew/bin/bash
        echo "Default shell updated. Open a new terminal to apply."
    else
        echo "Error: /opt/homebrew/bin/bash not found. Install Bash via Homebrew first."
    fi
}

gh_add_repos_to_team() {
    local permission="${1:-pull}"
    local org="${2:-MyOrg}"
    local team_slug="${3:-read-only-all-repos}"
    if ! gh auth status >/dev/null 2>&1; then
        echo "Error: GitHub CLI not authenticated. Run 'gh auth login' first."
        return 1
    fi
    echo "Fetching repositories from $org..."
    local repos=$(gh repo list "$org" --limit 1000 --json nameWithOwner -q '.[] | .nameWithOwner') || {
        echo "Error: Failed to list repositories for $org."
        return 1
    }
    echo "Adding $team_slug to repositories with $permission permission..."
    echo "$repos" | while IFS= read -r repo; do
        if [ -z "$repo" ]; then
            continue
        fi
        echo "Processing $repo..."
        local response=$(gh api \
            --method PUT \
            -H "Accept: application/vnd.github+json" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            "/orgs/$org/teams/$team_slug/repos/$repo" \
            -f "permission=$permission" 2>&1)
        if [ $? -eq 0 ]; then
            echo "Successfully added $team_slug to $repo"
        else
            local status_code=$(echo "$response" | grep -o "HTTP/[0-9.]\+ [0-9]\+" | awk '{print $2}' || echo "Unknown")
            echo "Error: Failed to add $team_slug to $repo (HTTP $status_code)"
            echo "Response: $response"
        fi
    done
}

#=== macOS-Specific ===#
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias ls='ls -hF -G'  # macOS color support
    alias meminfo='vm_stat'
    alias cpuinfo='sysctl -n machdep.cpu.brand_string'
    maintenance() {
        sudo dscacheutil -flushcache
        sudo killall -HUP mDNSResponder
        rm -rf ~/Library/Caches/* ~/Library/Logs/* 2>/dev/null
        defaults write com.apple.dock ResetLaunchPad -bool true
        killall Dock
        echo "Running system diagnostics..."
        sudo sysdiagnose -u >/dev/null 2>&1 &
    }
    brewski() {
        brew update && brew upgrade
        brew cleanup
    }
fi

#=== Development Helpers ===#
alias virc='vim ~/.bashrc && . ~/.bashrc'
alias rpi='ssh rpi@raspberrypi.local'
whatsmyip() { curl -s ifconfig.me; }
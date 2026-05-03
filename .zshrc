# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export DISPLAY=:1

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Keybindings
bindkey -e
bindkey '^[[1;5A' history-search-backward # ctrl + up 
bindkey '^[[1;5B' history-search-forward  # ctrl + down
bindkey '^[w' kill-region

# History Configuration
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# ---- FZF Core Engine Configuration (Optimized with fd) ----
export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git --exclude node_modules"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --exclude .git --exclude node_modules"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"

# ---- Completion & fzf-tab styling (Optimized with eza) ----
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'

# Updating hosts file (DNS Blocklist)
update-hosts() {
    echo "🌐 Fetching latest adult blocklist from GitHub..."
    curl -s "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn-only/hosts" > /tmp/dl_hosts
    
    echo "🛠️ Prepending native loopback entries..."
    cat << 'EOF' > /tmp/custom_hosts
# Loopback entries; do not change.
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

# --- END NATIVE LOOPBACK / BEGIN FILTER LIST ---

EOF

    cat /tmp/dl_hosts >> /tmp/custom_hosts
    
    echo "🔒 Applying new configuration to /etc/hosts (Sudo required)..."
    sudo mv /tmp/custom_hosts /etc/hosts
    sudo chown root:root /etc/hosts
    sudo chmod 644 /etc/hosts
    
    echo "🧹 Flushing system DNS cache..."
    sudo resolvectl flush-caches
    
    rm -f /tmp/dl_hosts
    echo "✅ Hosts file successfully updated and secured!"
}

# Aliases
alias ls="eza --icons=always"
alias ll="eza -la --icons=always"
alias ocat="/usr/bin/cat"
alias cat="bat"
alias vim='nvim'
alias clr='clear'
alias zshconfig='nvim ~/.zshrc'
alias zshenvconfig='nvim ~/.zshenv'
alias apt="nala"
alias sudo="sudo "

# Shell Integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
[ -f ~/.config/fzf/fzf-git.sh ] && source ~/.config/fzf/fzf-git.sh

# ---- FNM (Fast Node Manager) ----
FNM_PATH="$HOME/.local/share/fnm"

# Auto-install fnm if the executable is missing
if [ ! -f "$FNM_PATH/fnm" ]; then
  echo "⚡ Fast Node Manager (fnm) not found. Initializing automated installation..."
  # Download and install silently, skipping automatic shell modifications
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "$FNM_PATH" --skip-shell
  echo "✅ fnm installed successfully."
fi

# Initialize fnm into the current session
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell zsh --use-on-cd)"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

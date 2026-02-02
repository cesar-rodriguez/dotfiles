# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# ===== PATH Configuration =====
export PATH="$HOME/.local/bin:$PATH"

# ===== Editor =====
export EDITOR="cursor"
export REACT_TERMINAL="iTerm.app"

# ===== Locale =====
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# ===== Version Managers =====

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
nvm use default --silent 2>/dev/null

# Pyenv (Python)
if command -v pyenv 1>/dev/null 2>&1; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

# uv (Fast Python package manager)
if command -v uv 1>/dev/null 2>&1; then
  eval "$(uv generate-shell-completion zsh)"
fi

# ===== Modern CLI Tools =====

# fzf - Fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zoxide - Smart cd
if command -v zoxide 1>/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# bat - Better cat
export BAT_THEME="TwoDark"

# eza - Better ls (aliased in .zsh_aliases)

# Go
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# Google Cloud SDK
if [ -f "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc" ]; then
  source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
  source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
fi

# ===== Aliases =====
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases

# ===== Environment Variables & Secrets =====
# Load local environment variables (API keys, etc.)
# This file is gitignored and machine-specific
[ -f ~/.env.local ] && source ~/.env.local

# ===== Tool-specific PATH & Config =====

# Amp CLI
export PATH="$HOME/.amp/bin:$PATH"

# Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export PATH="/usr/local/opt/trash/bin:$PATH"

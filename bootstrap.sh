#!/bin/bash
# Dotfiles Bootstrap Script
# Installs and configures development environment

set -e

DOTFILES_DIR="$HOME/GitHub/cesar-rodriguez/dotfiles"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

echo "Starting dotfiles setup..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_success() {
  echo -e "${GREEN}OK${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}WARN${NC} $1"
}

# Error helpers
print_error() {
  echo -e "${RED}ERR${NC} $1"
}

is_same_inode() {
  if [ ! -e "$1" ] || [ ! -e "$2" ]; then
    return 1
  fi
  [ "$(stat -f '%d:%i' "$1")" = "$(stat -f '%d:%i' "$2")" ]
}

# Backup existing files
backup_if_exists() {
  if [ -f "$1" ] || [ -d "$1" ] || [ -L "$1" ]; then
    mkdir -p "$BACKUP_DIR"
    dest="$BACKUP_DIR/$(basename "$1")"
    set +e
    mv "$1" "$BACKUP_DIR/"
    mv_status=$?
    set -e

    if [ "$mv_status" -ne 0 ]; then
      if [ -e "$dest" ] && is_same_inode "$1" "$dest"; then
        print_warning "Skipping backup for $1; identical to $dest"
      else
        print_error "Failed to back up $1 (mv exit $mv_status)"
        exit "$mv_status"
      fi
    else
      print_warning "Backed up $1 to $BACKUP_DIR"
    fi
  fi
}

# Create symlink
create_symlink() {
  local source=$1
  local target=$2

  backup_if_exists "$target"
  ln -sf "$source" "$target"
  print_success "Linked $target"
}

# ===== GitHub CLI Authentication =====
if ! command -v gh &> /dev/null; then
  print_error "GitHub CLI (gh) not found. Installing via Homebrew first..."
  if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  brew install gh
fi

if ! gh auth status &> /dev/null; then
  echo "Authenticating with GitHub..."
  gh auth login
  print_success "GitHub authenticated"
else
  print_success "GitHub already authenticated"
fi

# ===== Install Homebrew =====
if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  print_success "Homebrew installed"
else
  print_success "Homebrew already installed"
fi

# ===== Install Brew Packages =====
echo "Installing packages from Brewfile..."
cd "$DOTFILES_DIR"
brew bundle
print_success "Packages installed"

# ===== Setup fzf key bindings =====
if [ ! -f "$HOME/.fzf.zsh" ]; then
  echo "Setting up fzf key bindings..."
  "$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish
  print_success "fzf key bindings installed"
else
  print_success "fzf already configured"
fi

# ===== Setup Node via NVM =====
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"

if ! command -v node &> /dev/null; then
  echo "Installing Node LTS via nvm..."
  nvm install --lts
  nvm use --lts
  nvm alias default node
  print_success "Node installed: $(node --version)"
else
  print_success "Node already installed: $(node --version)"
fi

# ===== Setup Python via pyenv =====
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv &> /dev/null; then
  eval "$(pyenv init -)"
  if [ -z "$(pyenv versions --bare)" ]; then
    echo "Installing Python 3.12 via pyenv..."
    pyenv install 3.12
    pyenv global 3.12
    print_success "Python installed: $(python --version)"
  else
    print_success "Python already installed: $(python --version)"
  fi
fi

# ===== Setup Colima (Container Runtime) =====
if command -v colima &> /dev/null; then
  if ! colima status &> /dev/null; then
    echo "Starting Colima..."
    colima start --cpu 4 --memory 8 --disk 60
    print_success "Colima started"
  else
    print_success "Colima already running"
  fi
fi

# ===== Ensure Docker Desktop =====
if ! command -v docker &> /dev/null; then
  echo "Docker CLI not found; installing Docker Desktop..."
  if brew install --cask docker; then
    print_success "Docker Desktop installed"
    if ! open -a Docker &> /dev/null; then
      print_warning "Docker installed but could not be auto-started; launch Docker Desktop manually"
    else
      print_success "Docker Desktop launched"
    fi
  else
    print_error "Docker Desktop installation failed"
  fi
else
  print_success "Docker CLI already installed"
fi

# ===== Manage Terraform & OpenTofu via tenv =====
if command -v tenv &> /dev/null; then
  _tenv_tools=("tf:Terraform" "tofu:OpenTofu")

  for entry in "${_tenv_tools[@]}"; do
    tool="${entry%%:*}"
    display_name="${entry#*:}"

    if tenv "$tool" install latest; then
      if tenv "$tool" use latest; then
        print_success "$display_name switched to latest via tenv"
      else
        print_warning "tenv failed to use the latest $display_name release"
      fi
    else
      print_warning "tenv failed to install the latest $display_name release"
    fi
  done
else
  print_warning "tenv not installed (add it to the Brewfile to manage Terraform/OpenTofu)"
fi

# ===== Install AI CLI Tools (non-Homebrew) =====
# Amp CLI (curl-based, no npm needed)
if ! command -v amp &> /dev/null; then
  echo "Installing Amp CLI..."
  curl -fsSL https://ampcode.com/install.sh | bash
  print_success "Amp CLI installed"
else
  print_success "Amp CLI already installed"
fi

# Vercel agent-browser CLI
if ! command -v agent-browser &> /dev/null; then
  echo "Installing agent-browser CLI..."
  npm install -g agent-browser
  print_success "agent-browser CLI installed"
else
  print_success "agent-browser CLI already installed"
fi

echo "Installing agent-browser runtime (may prompt for input)..."
if agent-browser install; then
  print_success "agent-browser runtime setup complete"
else
  print_warning "agent-browser runtime setup failed; run 'agent-browser install' manually"
fi

# Claude CLI (requires npm)
if ! command -v claude &> /dev/null; then
  echo "Installing Claude CLI..."
  npm install -g @anthropic-ai/claude-code
  print_success "Claude CLI installed"
else
  print_success "Claude CLI already installed"
fi

# Antigravity CLI (install via shell command)
if ! command -v agy &> /dev/null; then
  echo "Installing Antigravity..."
  echo "Download from: https://antigravity.google/download"
  echo "After install, run 'agy' from Command Palette to enable CLI"
  print_warning "Antigravity requires manual download"
else
  print_success "Antigravity CLI already installed"
fi

# Skills CLI (Vercel agent skills ecosystem, requires npm)
if ! command -v skills &> /dev/null; then
  echo "Installing Skills CLI..."
  npm install -g skills
  print_success "Skills CLI installed"
else
  print_success "Skills CLI already installed"
fi

# ===== Install Oh My Zsh =====
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  print_success "Oh My Zsh installed"
else
  print_success "Oh My Zsh already installed"
fi

# Install zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  gh repo clone zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  print_success "zsh-autosuggestions installed"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  gh repo clone zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  print_success "zsh-syntax-highlighting installed"
fi

# ===== Symlink Dotfiles =====
echo "Creating symlinks..."

# Zsh
create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/zsh/.zsh_aliases" "$HOME/.zsh_aliases"

# Git
create_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
create_symlink "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore_global"

# Claude
mkdir -p "$HOME/.claude"
create_symlink "$DOTFILES_DIR/AGENTS.md" "$HOME/.claude/CLAUDE.md"
create_symlink "$DOTFILES_DIR/ai/commands" "$HOME/.claude/commands"
if [ -f "$DOTFILES_DIR/ai/claude-settings.json" ]; then
  create_symlink "$DOTFILES_DIR/ai/claude-settings.json" "$HOME/.claude/settings.json"
fi
if [ -f "$DOTFILES_DIR/ai/claude-mcp.json" ]; then
  create_symlink "$DOTFILES_DIR/ai/claude-mcp.json" "$HOME/.claude/mcp.json"
fi

# Codex
mkdir -p "$HOME/.codex"
create_symlink "$DOTFILES_DIR/AGENTS.md" "$HOME/.codex/AGENTS.md"
create_symlink "$DOTFILES_DIR/ai/commands" "$HOME/.codex/prompts"
if [ -f "$DOTFILES_DIR/ai/codex-config.toml" ]; then
  create_symlink "$DOTFILES_DIR/ai/codex-config.toml" "$HOME/.codex/config.toml"
fi

# Cursor
mkdir -p "$HOME/.cursor"
create_symlink "$DOTFILES_DIR/ai/commands" "$HOME/.cursor/commands"
if [ -f "$DOTFILES_DIR/ai/cursor-mcp.json" ]; then
  create_symlink "$DOTFILES_DIR/ai/cursor-mcp.json" "$HOME/.cursor/mcp.json"
fi
if [ -f "$DOTFILES_DIR/ai/cursor-cli-config.json" ]; then
  create_symlink "$DOTFILES_DIR/ai/cursor-cli-config.json" "$HOME/.cursor/cli-config.json"
fi

# Amp
mkdir -p "$HOME/.config/amp"
mkdir -p "$HOME/.config/agents"
if [ -f "$DOTFILES_DIR/ai/amp-settings.json" ]; then
  create_symlink "$DOTFILES_DIR/ai/amp-settings.json" "$HOME/.config/amp/settings.json"
fi
create_symlink "$DOTFILES_DIR/ai/commands" "$HOME/.config/agents/commands"
create_symlink "$DOTFILES_DIR/AGENTS.md" "$HOME/.config/agents/AGENTS.md"

# Antigravity (Google)
mkdir -p "$HOME/.gemini/antigravity"
create_symlink "$DOTFILES_DIR/AGENTS.md" "$HOME/.gemini/GEMINI.md"
if [ -f "$DOTFILES_DIR/ai/antigravity-mcp.json" ]; then
  create_symlink "$DOTFILES_DIR/ai/antigravity-mcp.json" "$HOME/.gemini/antigravity/mcp_config.json"
fi

# Shared scripts
mkdir -p "$HOME/.local/bin"
for script in committer nanobanana; do
  create_symlink "$DOTFILES_DIR/ai/scripts/$script" "$HOME/.local/bin/$script"
done

# ===== Install Agent Skills (global so all agents share them) =====
echo "Installing agent skills..."
npx skills add schpet/linear-cli --global -y
npx skills add anthropics/skills --skill pdf --skill docx --skill mcp-builder --skill pptx --skill skill-creator --skill xlsx --skill frontend-design --global -y
npx skills add vercel-labs/agent-browser --skill agent-browser --global -y
npx skills add snarktank/amp-skills --skill compound-engineering --global -y
npx skills add snarktank/ralph --skill prd --skill ralph --global -y
npx skills add vercel-labs/vercel-composition-patterns --skill vercel-react-best-practices --skill vercel-react-native-skills --skill web-design-guidelines --global -y
npx skills add steipete/agent-scripts --skill create-cli --skill brave-search --skill markdown-converter --skill openai-image-gen --skill video-transcript-downloader --global -y
npx skills add chrisrodz/dotfiles --skill polishing-issues --global -y
npx skills add hashicorp/agent-skills --skill terraform-style-guide --global -y
npx skills add antonbabenko/terraform-skill --skill terraform-skill --global -y
print_success "Agent skills installed globally"

# ===== Environment Setup =====
if [ ! -f "$HOME/.env.local" ]; then
  echo "Creating .env.local from template..."
  cp "$DOTFILES_DIR/.env.local.example" "$HOME/.env.local"
  print_warning "Edit ~/.env.local with your secrets and API keys"
else
  print_success ".env.local already exists"
fi

# Source env for validation and MCP generation
source "$HOME/.env.local"

# Validate required env vars for MCP servers
REQUIRED_ENV_VARS=(
  "GITHUB_TOKEN"
  "CONTEXT7_API_KEY"
  "STACKGEN_PAT"
)

MISSING_VARS=()
for var in "${REQUIRED_ENV_VARS[@]}"; do
  if [ -z "${!var}" ]; then
    MISSING_VARS+=("$var")
  fi
done

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
  print_warning "Missing required env vars in ~/.env.local:"
  for var in "${MISSING_VARS[@]}"; do
    echo "  - $var"
  done
  echo ""
  echo "Some MCP servers will not work until these are set."
else
  print_success "All required env vars present"
fi

# ===== Generate MCP Configs =====
if [ -f "$DOTFILES_DIR/ai/generate-mcp-configs.sh" ]; then
  if [ ${#MISSING_VARS[@]} -eq 0 ]; then
    echo "Generating MCP configs..."
    if (cd "$DOTFILES_DIR/ai" && ./generate-mcp-configs.sh); then
      print_success "MCP configs generated"
    else
      print_warning "MCP config generation failed; rerun ./ai/generate-mcp-configs.sh after fixing issues"
    fi
  else
    print_warning "Skipping MCP config generation (missing env vars: ${MISSING_VARS[*]}); update ~/.env.local and rerun ./ai/generate-mcp-configs.sh manually"
  fi
else
  print_warning "generate-mcp-configs.sh not found; skip MCP config generation"
fi

# ===== Configure Git User =====
CURRENT_NAME=$(git config --global user.name 2>/dev/null)
CURRENT_EMAIL=$(git config --global user.email 2>/dev/null)

if [ -n "$CURRENT_NAME" ] && [ -n "$CURRENT_EMAIL" ]; then
  print_success "Git already configured: $CURRENT_NAME <$CURRENT_EMAIL>"
else
  echo ""
  echo "Configure Git user info:"

  if [ -z "$CURRENT_NAME" ]; then
    read -p "Git name: " git_name
    [ -n "$git_name" ] && git config --global user.name "$git_name" && print_success "Git name set"
  fi

  if [ -z "$CURRENT_EMAIL" ]; then
    read -p "Git email: " git_email
    [ -n "$git_email" ] && git config --global user.email "$git_email" && print_success "Git email set"
  fi
fi

# ===== Post-install Instructions =====
echo ""
echo "Dotfiles setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit ~/.env.local with your secrets"
echo "2. Restart your terminal or run: source ~/.zshrc"
echo "3. Optional: Configure GPG signing (see git/.gitconfig)"
echo ""

if [ -d "$BACKUP_DIR" ]; then
  echo "Backups saved to: $BACKUP_DIR"
fi

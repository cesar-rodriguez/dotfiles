# Dotfiles

My personal dotfiles. Installs essential CLI tools, configures shell, git, and development workflows.

```bash
gh repo clone cesar-rodriguez/dotfiles ~/GitHub/cesar-rodriguez/dotfiles
cd ~/GitHub/cesar-rodriguez/dotfiles
./bootstrap.sh
```

## Installation & Setup

### On a New Machine

1. **Authenticate with GitHub**

   ```bash
   gh auth login
   ```

2. **Clone and run bootstrap**

   ```bash
   gh repo clone cesar-rodriguez/dotfiles ~/GitHub/cesar-rodriguez/dotfiles
   cd ~/GitHub/cesar-rodriguez/dotfiles
   ./bootstrap.sh
   ```

3. **Configure secrets and user info**

   ```bash
   # Git credentials (required for commits)
   cp ~/GitHub/cesar-rodriguez/dotfiles/git/.gitconfig.local.example ~/.gitconfig.local
   cursor ~/.gitconfig.local  # Add your name and email

   # Environment secrets (API keys, tokens, etc.)
   cursor ~/.env.local
   ```

### Is it Safe to Rerun?

**Yes.** The bootstrap script:

- Creates timestamped backups (`~/dotfiles-backup-YYYYMMDD-HHMMSS`) before overwriting any files
- Checks if tools are already installed before installing
- Prompts for git user.name and email (skip if already set)

Rerun anytime to update symlinks or install missing packages.

### Considerations

- **GitHub auth required first** - Script uses `gh` CLI for operations
- **Existing configs backed up** - Your current .zshrc, .gitconfig, etc. are saved
- **Prompts for git identity** - Asks for name/email if not configured
- **Creates `~/.env.local` and `~/.gitconfig.local`** - Templates for secrets (gitignored)
- **GPG signing optional** - Uncomment in `~/.gitconfig.local` if you use it

### Global AI CLI Dependencies

Bootstrap installs AI CLIs automatically:

```bash
# Codex & Claude desktop (via Homebrew cask)
brew install --cask codex claude cursor

# Claude CLI (via npm)
npm install -g @anthropic-ai/claude-code

# Amp CLI (via curl)
curl -fsSL https://ampcode.com/install.sh | bash

# Skills CLI (via npm)
npm install -g skills
```

The CLIs will then be available system-wide (`claude --help`, `codex --help`, `amp --help`).

## Customization

Common changes you might want to make:

| What                       | Where              | How                                                          |
| -------------------------- | ------------------ | ------------------------------------------------------------ |
| **Add CLI aliases**        | `zsh/.zsh_aliases` | Edit file, add alias lines                                   |
| **Add brew packages**      | `Brewfile`         | Add `brew "package-name"`, run `brew bundle`                 |
| **Change git settings**    | `git/.gitconfig`   | Modify aliases, behavior (user info in `~/.gitconfig.local`) |
| **Update agent rules**     | `AGENTS.md`        | Edit shared instructions (Codex/Claude/Cursor)               |
| **Add slash commands**     | `ai/commands/`     | Add `.md` files with prompts                                 |
| **Add skills**             | `ai/skills/`       | Add or edit skill folders                                    |
| **Modify shell behavior**  | `zsh/.zshrc`       | Edit PATH, themes, plugins                                   |

### Updating Other Machines

After making changes:

```bash
cd ~/GitHub/cesar-rodriguez/dotfiles
# Commit your changes with git/gh, then on other machines:
gh repo sync
./bootstrap.sh  # Refresh symlinks
```

## What Gets Installed

### CLI Tools (via Brewfile)

**Search & Navigation**

- `fzf` - Fuzzy finder for files/history
- `ripgrep` - Faster grep
- `fd` - Faster find
- `zoxide` - Smart cd with frecency

**Modern Replacements**

- `bat` - Better cat with syntax highlighting
- `eza` - Better ls with git status/icons
- `tldr` - Simplified man pages

**Dev Tools**

- `jq` / `yq` - JSON/YAML processors
- `httpie` - User-friendly HTTP client
- `gh` - GitHub CLI
- `vercel-cli` - Vercel CLI

**AI Tools**

- `codex` (cask) - OpenAI Codex CLI
- `claude` (cask) - Anthropic Claude desktop
- `cursor` (cask) - Cursor IDE
- `antigravity` - Google Antigravity (manual download)
- `amp` - Amp CLI (installed via curl)
- `claude` CLI - Claude Code CLI (installed via npm)

**Cloud & Infrastructure**

- `aws-cli` - AWS CLI v2
- `azure-cli` - Azure CLI
- `google-cloud-sdk` - GCP CLI (gcloud)
- `terraform` / `opentofu` - Infrastructure as Code

**Kubernetes & Containers**

- `colima` - Container runtime (Docker alternative)
- `docker` - Docker CLI
- `kubernetes-cli` - kubectl
- `helm` - Kubernetes package manager
- `eksctl` - EKS cluster management
- `k9s` - Kubernetes TUI
- `act` - Local GitHub Actions runner

**Languages & Tooling**

- `go` - Go programming language
- `golangci-lint` - Go linter aggregator
- `air` - Go hot reload
- `pyenv` - Python version manager
- `ruff` - Fast Python linter & formatter
- `pnpm` - Fast Node package manager

**Stacked PRs**

- `graphite` (gt) - Stacked PR workflow

**System Utils**

- `htop` - Process viewer
- `tree` - Directory visualization
- `trash` - Safe delete CLI
- `tmux` - Terminal multiplexer
- `iterm2` (cask) - Terminal emulator

**Version Managers**

- `nvm` - Node.js version management
- `uv` - Fast Python package installer & version manager
- `bun` - JS runtime for tools/scripts

**Git & Security**

- `git` - Latest version
- `gpg` - For commit signing
- `terrascan` - IaC security scanner

### Shell Configuration

**Oh My Zsh** with plugins:

- `zsh-autosuggestions` - Command suggestions
- `zsh-syntax-highlighting` - Syntax highlighting

**100+ Aliases** including:

- Modern CLI shortcuts (`ls` -> `eza`, `cat` -> `bat`, `cd` -> `zoxide`, `rm` -> `trash`)
- Git shortcuts (`gs`, `ga`, `gc`, `gp`, `gl`, `glog`)
- Python helpers (`venv`, `activate`, `pyclean`, `rf`, `rff`, `rfmt`)
- Node/pnpm shortcuts (`nr`, `nrd`, `pi`, `pa`, `pr`, `prd`, `px`)
- Docker & Colima (`d`, `dc`, `dcup`, `dcdown`, `colstart`, `colstop`)
- Kubernetes (`k`, `kgp`, `kgs`, `kga`, `klogs`, `kexec`, `k9`)
- Go development (`gol`, `golf`, `godev`, `got`, `gob`, `gor`)
- Terraform/OpenTofu (`tf`, `tfi`, `tfp`, `tfa`, `tfd`)
- Cloud CLIs (`awslogin`, `azlogin`, `gclogin`)
- Graphite stacked PRs (`gts`, `gtc`, `gtsub`, `gtsync`)
- AI tools (`cl`, `cx`, `am`)
- Search (`rg`, `rgf`, `fdf`, `fdd`)
- Utils (`mkcd`, `port`, `killport`, `serve`)

### Git Configuration

- **Privacy-first**: User info stored in `~/.gitconfig.local` (gitignored)
- Auto-setup remote on push
- GitHub credential helper via `gh` CLI
- Useful aliases (`lg`, `hist`, `unstage`)
- Optional GPG commit signing (configure in `~/.gitconfig.local`)
- Global ignores for Python/Node/macOS

**Setup**: Copy `git/.gitconfig.local.example` to `~/.gitconfig.local` and add your name/email

### Agent Instructions and Commands

| Tool | Rules File | Skills | Commands | MCP Config |
|------|------------|--------|----------|------------|
| **Claude** | `~/.claude/CLAUDE.md` | `~/.claude/skills` | `~/.claude/commands` | `~/.claude/mcp.json` |
| **Codex** | `~/.codex/AGENTS.md` | `~/.codex/skills` | `~/.codex/prompts` | `~/.codex/config.toml` |
| **Amp** | `~/.config/agents/AGENTS.md` | `~/.config/agents/skills` | `~/.config/agents/commands` | `~/.config/amp/settings.json` |
| **Cursor** | N/A | N/A | `~/.cursor/commands` | `~/.cursor/mcp.json` |
| **Antigravity** | `~/.gemini/GEMINI.md` | `~/.gemini/antigravity/global_skills` | Workflows (UI) | `~/.gemini/antigravity/mcp_config.json` |

All symlinked from `AGENTS.md`, `ai/skills/`, `ai/commands/`, and tool-specific MCP configs in `ai/`.

### AI Coding Assistants

- `claude` - Claude Code CLI (installed via npm)
- `codex` - OpenAI Codex CLI (installed via Homebrew cask)
- `amp` - Amp CLI (installed via curl)
- `cursor` - Cursor IDE with CLI (installed via Homebrew cask)
- `antigravity` - Google Antigravity IDE (manual download from https://antigravity.google/download)
- `skills` - Vercel agent skills CLI (installed via npm)

Bootstrap sets up MCP configs, skills, and rules for all AI tools from templates in `ai/`.

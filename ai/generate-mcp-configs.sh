#!/bin/bash
# Generate tool-specific MCP configs from mcp-servers.json
# Substitutes ${VAR} placeholders with actual env values

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MCP_SOURCE="$SCRIPT_DIR/mcp-servers.json"

# Load env if available
[ -f "$HOME/.env.local" ] && source "$HOME/.env.local"

# Check if jq is available
if ! command -v jq &> /dev/null; then
  echo "Error: jq is required but not installed"
  exit 1
fi

# Substitute env vars in a string
substitute_env() {
  local str="$1"
  # Replace ${VAR} patterns with actual values
  while [[ "$str" =~ \$\{([A-Za-z_][A-Za-z0-9_]*)\} ]]; do
    local var_name="${BASH_REMATCH[1]}"
    local var_value="${!var_name}"
    str="${str//\$\{$var_name\}/$var_value}"
  done
  echo "$str"
}

replace_if_changed() {
  local tmp=$1
  local output=$2

  if [ -f "$output" ] && cmp -s "$output" "$tmp"; then
    rm -f "$tmp"
    echo "  -> $output (unchanged)"
  else
    mv "$tmp" "$output"
    echo "  -> $output"
  fi
}

# Generate Cursor MCP config
generate_cursor() {
  local output="$SCRIPT_DIR/cursor-mcp.json"
  echo "Generating Cursor MCP config..."
  local tmp
  tmp=$(mktemp)
  trap 'rm -f "$tmp"' RETURN

  jq -r '.servers | to_entries | map(select(.value.type == "http")) | 
    reduce .[] as $s ({}; 
      .[$s.key] = {
        url: $s.value.url,
        headers: $s.value.headers
      }
    ) | {mcpServers: .}' "$MCP_SOURCE" > "$tmp"

  trap - RETURN
  replace_if_changed "$tmp" "$output"
}

# Generate Amp MCP config (merges into amp-settings.json)
generate_amp() {
  local output="$SCRIPT_DIR/amp-settings.json"
  local existing_settings
  echo "Generating Amp MCP config..."
  
  # Read existing settings (non-MCP)
  if [ -f "$output" ]; then
    existing_settings=$(jq 'del(.["amp.mcpServers"])' "$output")
  else
    existing_settings="{}"
  fi
  
  # Generate MCP servers section
  local mcp_servers
  mcp_servers=$(jq -r '.servers | to_entries | 
    reduce .[] as $s ({}; 
      if $s.value.type == "command" then
        .[$s.key] = {command: $s.value.command, args: $s.value.args}
      else
        .[$s.key] = {url: $s.value.url}
      end
    )' "$MCP_SOURCE")

  # Merge
  local tmp
  tmp=$(mktemp)
  trap 'rm -f "$tmp"' RETURN

  echo "$existing_settings" | jq --argjson mcp "$mcp_servers" '. + {"amp.mcpServers": $mcp}' > "$tmp"

  trap - RETURN
  replace_if_changed "$tmp" "$output"
}

# Generate Claude MCP config (claude_desktop_config.json format)
generate_claude() {
  local output="$SCRIPT_DIR/claude-mcp.json"
  echo "Generating Claude MCP config..."
  
  local tmp
  tmp=$(mktemp)
  trap 'rm -f "$tmp"' RETURN

  jq -r '.servers | to_entries | 
    reduce .[] as $s ({}; 
      if $s.value.type == "command" then
        .[$s.key] = {command: $s.value.command, args: $s.value.args}
      else
        .[$s.key] = {url: $s.value.url, headers: $s.value.headers}
      end
    ) | {mcpServers: .}' "$MCP_SOURCE" > "$tmp"

  trap - RETURN
  replace_if_changed "$tmp" "$output"
}

# Validate required env vars
validate_env() {
  local missing=()
  local required
  required=$(jq -r '.requiredEnvVars[]' "$MCP_SOURCE")
  
  while IFS= read -r var; do
    if [ -z "${!var}" ]; then
      missing+=("$var")
    fi
  done <<< "$required"
  
  if [ ${#missing[@]} -gt 0 ]; then
    echo "Warning: Missing env vars (MCPs may not work):"
    for var in "${missing[@]}"; do
      echo "  - $var"
    done
    return 1
  fi
  return 0
}

# Main
echo "MCP Config Generator"
echo "===================="

if ! validate_env; then
  echo ""
  echo "Set missing vars in ~/.env.local and re-run"
  echo ""
fi

generate_cursor
generate_amp
generate_claude

echo ""
echo "Done! Configs generated from $MCP_SOURCE"

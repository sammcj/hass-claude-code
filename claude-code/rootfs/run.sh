#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Claude Code Terminal - Home Assistant Addon Entrypoint
# =============================================================================

# Read configuration from HA addon options
OPTIONS_FILE="/data/options.json"
if [[ -f "$OPTIONS_FILE" ]]; then
    SESSION_TIMEOUT=$(jq -r '.session_timeout // 1800' "$OPTIONS_FILE")
    AUTO_LAUNCH=$(jq -r '.auto_launch_claude // true' "$OPTIONS_FILE")
    TMUX_ENABLED=$(jq -r '.tmux_enabled // true' "$OPTIONS_FILE")
else
    SESSION_TIMEOUT=1800
    AUTO_LAUNCH=true
    TMUX_ENABLED=true
fi

# -----------------------------------------------------------------------------
# Setup default CLAUDE.md if not present
# -----------------------------------------------------------------------------
setup_claude_md() {
    if [[ ! -f /config/CLAUDE.md ]]; then
        if [[ -f /usr/share/claude-code/default_CLAUDE.md ]]; then
            cp /usr/share/claude-code/default_CLAUDE.md /config/CLAUDE.md
            echo "[INFO] Created default /config/CLAUDE.md"
        fi
    else
        echo "[INFO] Using existing /config/CLAUDE.md"
    fi
}

# -----------------------------------------------------------------------------
# Setup persistent directories for OAuth tokens
# -----------------------------------------------------------------------------
setup_persistence() {
    # Create persistent storage directories
    # Note: Binary is at /root/.local/bin/claude, config is in /root/.claude/
    mkdir -p /data/.claude /data/.config/claude /data/.anthropic
    chmod 700 /data/.claude /data/.config/claude /data/.anthropic

    # Ensure parent directories exist in container
    mkdir -p /root/.config

    # Migrate any existing config from container to persistent storage
    if [[ -d /root/.claude ]] && [[ ! -L /root/.claude ]]; then
        cp -an /root/.claude/. /data/.claude/ 2>/dev/null || true
        rm -rf /root/.claude
    fi

    # Symlink entire config directories to persistent storage
    rm -rf /root/.claude /root/.anthropic /root/.config/claude
    ln -sfn /data/.claude /root/.claude
    ln -sfn /data/.anthropic /root/.anthropic
    ln -sfn /data/.config/claude /root/.config/claude

    # Set HOME explicitly for Claude Code
    export HOME=/root

    echo "[INFO] Persistence configured: /data/.claude, /data/.anthropic"
}

# -----------------------------------------------------------------------------
# Launch with tmux (session survives browser disconnect)
# -----------------------------------------------------------------------------
launch_with_tmux() {
    # Kill any stale session
    tmux kill-session -t claude 2>/dev/null || true

    # Create new detached session in /config directory
    tmux new-session -d -s claude -c /config

    # Configure session timeout (lock-after-time locks after idle)
    tmux set-option -t claude lock-after-time "$SESSION_TIMEOUT" 2>/dev/null || true

    # Verify session exists
    if ! tmux has-session -t claude 2>/dev/null; then
        echo "[ERROR] Failed to create tmux session"
        exit 1
    fi

    echo "[INFO] tmux session 'claude' created (timeout: ${SESSION_TIMEOUT}s)"

    # Launch claude via wrapper script (handles errors gracefully, exits on success)
    if [[ "$AUTO_LAUNCH" == "true" ]]; then
        echo "[INFO] Auto-launching Claude Code..."
        tmux send-keys -t claude "exec claude-session" Enter
    else
        # Manual mode: give shell access, session ends when shell exits
        echo "[INFO] Shell mode - run 'claude' to start, 'exit' to close session"
    fi

    # Launch ttyd connecting to tmux session
    exec ttyd -W -p 7681 tmux attach -t claude
}

# -----------------------------------------------------------------------------
# Launch without tmux (direct terminal)
# -----------------------------------------------------------------------------
launch_direct() {
    if [[ "$AUTO_LAUNCH" == "true" ]]; then
        echo "[INFO] Launching Claude Code directly"
        exec ttyd -W -p 7681 claude
    else
        echo "[INFO] Launching bash shell"
        exec ttyd -W -p 7681 bash
    fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo "=============================================="
    echo "  Claude Code Terminal for Home Assistant"
    echo "=============================================="
    echo ""

    setup_claude_md
    setup_persistence

    if [[ "$TMUX_ENABLED" == "true" ]]; then
        echo "[INFO] tmux mode enabled"
        launch_with_tmux
    else
        echo "[INFO] Direct mode (no tmux)"
        launch_direct
    fi
}

main "$@"

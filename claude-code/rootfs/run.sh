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
# Setup persistent directories for OAuth tokens
# -----------------------------------------------------------------------------
setup_persistence() {
    local dirs=(
        "/data/.claude"
        "/data/.config/claude"
        "/data/.anthropic"
        "/data/.config"
        "/data/.local/share"
    )

    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        chmod 700 "$dir"
    done

    # Create symlinks for OAuth token persistence
    # Claude Code may store tokens in various locations
    ln -sfn /data/.claude /root/.claude
    ln -sfn /data/.config/claude /root/.config/claude
    ln -sfn /data/.anthropic /root/.anthropic

    echo "[INFO] Persistence directories configured"
}

# -----------------------------------------------------------------------------
# Launch with tmux (session survives browser disconnect)
# -----------------------------------------------------------------------------
launch_with_tmux() {
    # Kill any stale session
    tmux kill-session -t claude 2>/dev/null || true

    # Create new detached session running bash (more reliable than direct command)
    tmux new-session -d -s claude

    # Configure session timeout (lock-after-time locks after idle)
    tmux set-option -t claude lock-after-time "$SESSION_TIMEOUT" 2>/dev/null || true

    # Verify session exists
    if ! tmux has-session -t claude 2>/dev/null; then
        echo "[ERROR] Failed to create tmux session"
        exit 1
    fi

    echo "[INFO] tmux session 'claude' created (timeout: ${SESSION_TIMEOUT}s)"

    # If auto-launch, send claude command to the session
    if [[ "$AUTO_LAUNCH" == "true" ]]; then
        echo "[INFO] Auto-launching Claude Code..."
        tmux send-keys -t claude "claude" Enter
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

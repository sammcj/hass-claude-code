#!/usr/bin/env bash
# Claude Code Terminal environment

# Source environment variables
if [[ -f /etc/claude-env.sh ]]; then
    source /etc/claude-env.sh
fi

# Add Claude's install location to PATH
export PATH="$HOME/.local/bin:$PATH"

# Custom prompt
export PS1='\[\033[1;36m\]claude\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\$ '

# Aliases
alias ll='ls -la'
alias la='ls -A'
alias ha='ha-api'

# Welcome message (only in interactive shells)
if [[ $- == *i* ]] && [[ -z "$CLAUDE_WELCOME_SHOWN" ]]; then
    export CLAUDE_WELCOME_SHOWN=1
    echo ""
    echo "==========================================="
    echo "  Claude Code Terminal for Home Assistant"
    echo "==========================================="
    echo ""
    echo "Commands:"
    echo "  claude         - Start Claude Code CLI"
    echo "  ha-states      - Query entity states"
    echo "  ha-call        - Call HA services"
    echo "  ha-history     - Query entity history"
    echo "  ha-api         - Raw HA API access"
    echo "  ha-backup      - Backup files before editing"
    echo "  ha-auth-helper - Auth troubleshooting"
    echo "  ha-health      - System health check"
    echo ""
    echo "Working directory: /config"
    echo ""
fi

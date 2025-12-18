# Claude Code Terminal for Home Assistant

A Home Assistant addon that provides Claude Code CLI with persistent tmux sessions.

## Features

- **Persistent Sessions**: tmux keeps your Claude session alive even if you close the browser
- **OAuth Persistence**: Credentials survive container restarts
- **Home Assistant Integration**: CLI tools to query entities and call services
- **Configurable Timeouts**: Set how long idle sessions remain active
- **Multi-Architecture**: Runs on amd64, aarch64 (Pi 4/5)

## Installation

1. Add this repository to your Home Assistant addon store
2. Install "Claude Code Terminal"
3. Start the addon
4. Open the web UI from the sidebar

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `session_timeout` | 1800 | Idle timeout in seconds (default 30 minutes) |
| `auto_launch_claude` | true | Start Claude automatically when terminal opens |
| `tmux_enabled` | true | Use tmux for session persistence |

## Home Assistant CLI Tools

The addon includes helper scripts to interact with Home Assistant:

```bash
# Query entity states
ha-states                           # List all entities
ha-states light                     # Filter by domain
ha-states sensor.temperature        # Get specific entity

# Call services
ha-call light turn_on light.living_room
ha-call switch toggle switch.desk_lamp
ha-call climate set_temperature climate.lounge '{"temperature": 22}'

# Query history
ha-history sensor.temperature       # Last 24 hours
ha-history sensor.temperature 7d    # Last 7 days

# Raw API access
ha-api states
ha-api config
ha-api services/light/turn_on POST '{"entity_id":"light.kitchen"}'
```

## tmux Usage

When `tmux_enabled` is true (default), your session runs inside tmux:

- Session survives browser tab close - just reopen the addon
- Use standard tmux keys (prefix is `Ctrl+b` by default)
- Create new windows: `Ctrl+b c`
- Switch windows: `Ctrl+b n` / `Ctrl+b p`
- Detach manually: `Ctrl+b d`

## Authentication

On first launch, Claude Code will prompt you to authenticate via browser. The OAuth tokens are stored persistently in `/data/.claude/` and will survive container restarts.

If authentication is lost, run `claude` again to re-authenticate.

## Development

Build locally with Docker:

```bash
docker build -t claude-code-terminal .
docker run -it -p 7681:7681 claude-code-terminal
```

## Licence

MIT

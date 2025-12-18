# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Home Assistant addon providing Claude Code CLI with persistent tmux sessions. Exposes ttyd web terminal at port 7681 via HA ingress.

## Build and Lint

```bash
# Build Docker image locally
docker build -t claude-code-terminal .

# Run locally for testing
docker run -it -p 7681:7681 claude-code-terminal

# Lint Dockerfile
hadolint Dockerfile

# Lint shell scripts
shellcheck rootfs/run.sh rootfs/usr/local/bin/*
```

## Architecture

```
Dockerfile           # Alpine-based, installs Claude Code via official installer
config.yaml          # HA addon manifest (version, arch, ingress, options schema)
build.yaml           # Multi-arch base image definitions
rootfs/
  run.sh             # Entrypoint: reads options, sets up persistence, launches ttyd+tmux
  usr/local/bin/     # HA API helper scripts (ha-api, ha-states, ha-call, ha-history)
```

**Entry flow**: `run.sh` reads `/data/options.json`, creates symlinks for OAuth persistence in `/data/.claude/`, then launches ttyd connected to a tmux session running Claude Code.

**HA integration**: Scripts use `$SUPERVISOR_TOKEN` (auto-provided by HA) to call `http://supervisor/core/api/` endpoints.

## Conventions

- All shell scripts use `set -euo pipefail`
- OAuth tokens persist in `/data/.claude/` (symlinked to `/root/.claude`)
- Config options defined in `config.yaml` schema, read from `/data/options.json` at runtime
- Multi-arch builds: amd64, aarch64, armv7 via GitHub Actions matrix

## Gotchas

- `ha-history` date parsing differs between GNU and BSD date - uses fallback syntax for both
- ttyd `-W` flag enables write access to the terminal
- Addon requires `hassio_api`, `homeassistant_api`, and `auth_api` permissions in config.yaml

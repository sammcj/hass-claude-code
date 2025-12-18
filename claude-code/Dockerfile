# hadolint global ignore=DL3018,DL3016,DL4006
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM}

ENV LANG=C.UTF-8 \
    HOME=/root \
    USE_BUILTIN_RIPGREP=0

# Install dependencies
# - coreutils: sha256sum for installer
# - libgcc/libstdc++/ripgrep: required for Claude Code native binary on Alpine
RUN apk add --no-cache \
        bash \
        tmux \
        ttyd \
        curl \
        jq \
        git \
        coreutils \
        libgcc \
        libstdc++ \
        ripgrep \
    && mkdir -p /root/.config /root/.local/share /root/.claude/bin

# Install Claude Code via native installer
# https://docs.anthropic.com/en/docs/claude-code/setup
# Installer updates ~/.bashrc with PATH, source it to find the binary
SHELL ["/bin/bash", "-c"]
RUN curl -fsSL https://claude.ai/install.sh | bash \
    && source /root/.bashrc || true \
    && CLAUDE_BIN=$(find /root -name "claude" -type f -executable 2>/dev/null | grep -v node_modules | head -1) \
    && echo "Found claude at: $CLAUDE_BIN" \
    && ln -sf "$CLAUDE_BIN" /usr/local/bin/claude \
    && /usr/local/bin/claude --version
SHELL ["/bin/ash", "-o", "pipefail", "-c"]

# Set XDG paths for runtime persistence (after install completes)
ENV XDG_CONFIG_HOME=/data/.config \
    XDG_DATA_HOME=/data/.local/share

# Copy rootfs and set permissions
COPY rootfs /
RUN chmod +x /run.sh /usr/local/bin/*

EXPOSE 7681
CMD ["/run.sh"]

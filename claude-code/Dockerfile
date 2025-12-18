# hadolint global ignore=DL3018,DL3016
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM}

ENV LANG=C.UTF-8 \
    XDG_CONFIG_HOME=/data/.config \
    XDG_DATA_HOME=/data/.local/share \
    HOME=/root

# Install dependencies (coreutils provides sha256sum for the installer)
RUN apk add --no-cache \
        bash \
        tmux \
        ttyd \
        curl \
        jq \
        coreutils \
    && mkdir -p /root/.config /root/.local/share /root/.claude

# Install Claude Code via native installer
# https://docs.anthropic.com/en/docs/claude-code/getting-started
RUN curl -fsSL https://claude.ai/install.sh | bash 2>&1 \
    && echo "=== Finding claude binary ===" \
    && find /root -name "claude" -type f 2>/dev/null \
    && find /usr -name "claude" -type f 2>/dev/null \
    && ls -laR /root/.claude/ 2>/dev/null || true \
    && ls -laR /root/.local/ 2>/dev/null || true \
    && CLAUDE_PATH=$(find /root -name "claude" -type f -executable 2>/dev/null | grep -v downloads | head -1) \
    && echo "Found claude at: $CLAUDE_PATH" \
    && ln -sf "$CLAUDE_PATH" /usr/local/bin/claude \
    && claude --version

# Copy rootfs and set permissions
COPY rootfs /
RUN chmod +x /run.sh /usr/local/bin/*

EXPOSE 7681
CMD ["/run.sh"]

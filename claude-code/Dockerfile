# hadolint global ignore=DL3018,DL3016
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM}

ENV LANG=C.UTF-8 \
    XDG_CONFIG_HOME=/data/.config \
    XDG_DATA_HOME=/data/.local/share \
    HOME=/root \
    PATH="/root/.claude/local/bin:${PATH}"

# Install dependencies and Claude Code
RUN apk add --no-cache \
        bash \
        tmux \
        ttyd \
        curl \
        jq \
    && mkdir -p /root/.config /root/.local/share

# https://docs.anthropic.com/en/docs/claude-code/getting-started
# hadolint ignore=DL3008,DL4006
RUN curl -fsSL https://claude.ai/install.sh | bash \
    && CLAUDE_BIN=$(find /root -name "claude" -type f -executable 2>/dev/null | head -1) \
    && echo "Claude installed at: $CLAUDE_BIN" \
    && ln -sf "$CLAUDE_BIN" /usr/local/bin/claude \
    && claude --version

# Copy rootfs and set permissions
COPY rootfs /
RUN chmod +x /run.sh /usr/local/bin/*

EXPOSE 7681
CMD ["/run.sh"]

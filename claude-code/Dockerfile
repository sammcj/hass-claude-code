# hadolint global ignore=DL3006,DL3016,DL3018,DL4006
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
# Installer puts binary at ~/.local/bin/claude
RUN curl -fsSL https://claude.ai/install.sh | bash \
    && ls -la /root/.local/bin/ \
    && ln -sf /root/.local/bin/claude /usr/local/bin/claude \
    && /usr/local/bin/claude --version

# Set XDG paths for runtime persistence (after install completes)
ENV XDG_CONFIG_HOME=/data/.config \
    XDG_DATA_HOME=/data/.local/share

# Copy rootfs and default config files
COPY rootfs /
COPY default_CLAUDE.md /usr/share/claude-code/default_CLAUDE.md
RUN chmod +x /run.sh /usr/local/bin/*

EXPOSE 7681
CMD ["/run.sh"]

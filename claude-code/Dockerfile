# hadolint global ignore=DL3018,DL3016
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM}

ENV LANG=C.UTF-8 \
    HOME=/root

# Install dependencies (coreutils provides sha256sum for the installer)
RUN apk add --no-cache \
        bash \
        tmux \
        ttyd \
        curl \
        jq \
        git \
        coreutils \
    && mkdir -p /root/.config /root/.local/share /root/.claude

# Install Claude Code via native installer (don't set XDG paths - they break the build)
# https://docs.anthropic.com/en/docs/claude-code/getting-started
RUN curl -fsSL https://claude.ai/install.sh | bash \
    && ln -sf /root/.local/bin/claude /usr/local/bin/claude \
    && claude --version

# Set XDG paths for runtime persistence (after install completes)
ENV XDG_CONFIG_HOME=/data/.config \
    XDG_DATA_HOME=/data/.local/share

# Copy rootfs and set permissions
COPY rootfs /
RUN chmod +x /run.sh /usr/local/bin/*

EXPOSE 7681
CMD ["/run.sh"]

# hadolint global ignore=DL3018,DL3016
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM}

ENV LANG=C.UTF-8 \
    XDG_CONFIG_HOME=/data/.config \
    XDG_DATA_HOME=/data/.local/share \
    HOME=/root

# Install dependencies
RUN apk add --no-cache \
        bash \
        tmux \
        ttyd \
        curl \
        jq \
        nodejs \
        npm \
    && mkdir -p /root/.config /root/.local/share

# Install Claude Code via npm (more reliable in containers)
# https://www.npmjs.com/package/@anthropic-ai/claude-code
RUN npm install -g @anthropic-ai/claude-code \
    && claude --version

# Copy rootfs and set permissions
COPY rootfs /
RUN chmod +x /run.sh /usr/local/bin/*

EXPOSE 7681
CMD ["/run.sh"]

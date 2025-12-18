# hadolint global ignore=DL3018,DL3016
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM}

ENV LANG=C.UTF-8 \
    XDG_CONFIG_HOME=/data/.config \
    XDG_DATA_HOME=/data/.local/share \
    HOME=/root

# Install dependencies and Claude Code
RUN apk add --no-cache \
        bash \
        tmux \
        ttyd \
        curl \
        jq \
    && mkdir -p /root/.config /root/.local/share

# https://code.claude.com/docs/en/setup#standard-installation
# hadolint ignore=DL3008,DL4006
RUN curl -fsSL https://claude.ai/install.sh | bash

# Copy rootfs and set permissions
COPY rootfs /
RUN chmod +x /run.sh /usr/local/bin/*

EXPOSE 7681
CMD ["/run.sh"]

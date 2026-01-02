FROM lscr.io/linuxserver/webtop:ubuntu-xfce

LABEL maintainer="你的GitHub用户名 <你的邮箱>"
LABEL description="Antigravity Manager - 一键部署版"

ENV TITLE="Antigravity Tools"
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# 构建时自动获取最新版本
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl jq wget ca-certificates && \
    LATEST_URL=$(curl -fsSL "https://api.github.com/repos/lbjlaq/Antigravity-Manager/releases/latest" | jq -r '.assets[] | select(.name | contains("amd64.deb")) | .browser_download_url') && \
    echo "📦 Downloading: $LATEST_URL" && \
    wget -q -O /tmp/install.deb "$LATEST_URL" && \
    apt-get install -y /tmp/install.deb fonts-wqy-zenhei fonts-wqy-microhei mousepad && \
    apt-get purge -y curl jq wget && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

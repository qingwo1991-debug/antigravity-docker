FROM lscr.io/linuxserver/webtop:ubuntu-xfce

LABEL maintainer="你的GitHub用户名 <你的邮箱>"
LABEL description="Antigravity Manager - 一键部署版"

ENV TITLE="Antigravity Tools"
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# 1. 安装基础工具
# 2. 安装 Antigravity 主程序（从官方仓库）
# 3. 安装 Antigravity-Manager（从 GitHub Release）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        jq \
        wget \
        ca-certificates \
        gnupg \
        fonts-wqy-zenhei \
        fonts-wqy-microhei \
        mousepad && \
    \
    # ====== 安装 Antigravity 主程序 ======
    echo "📦 Installing Antigravity from official repo..." && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | \
        gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | \
        tee /etc/apt/sources.list.d/antigravity.list > /dev/null && \
    apt-get update && \
    apt-get install -y antigravity && \
    \
    # ====== 安装 Antigravity-Manager ======
    echo "📦 Installing Antigravity-Manager from GitHub..." && \
    LATEST_URL=$(curl -fsSL "https://api.github.com/repos/lbjlaq/Antigravity-Manager/releases/latest" | \
        jq -r '.assets[] | select(.name | contains("amd64.deb")) | .browser_download_url') && \
    echo "📦 Downloading: $LATEST_URL" && \
    wget -q -O /tmp/install.deb "$LATEST_URL" && \
    apt-get install -y /tmp/install.deb && \
    \
    # ====== 清理 ======
    apt-get purge -y curl jq wget gnupg && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 创建符号链接确保程序能找到（如果需要）
RUN ln -sf /usr/bin/antigravity /usr/local/bin/antigravity 2>/dev/null || true

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

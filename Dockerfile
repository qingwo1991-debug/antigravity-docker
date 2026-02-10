# ------------------------------------------------------------------------------
# Dockerfile - Antigravity Manager (Multi-Arch Supported)
# ------------------------------------------------------------------------------
FROM lscr.io/linuxserver/webtop:ubuntu-xfce

LABEL maintainer="你的GitHub用户名 <你的邮箱>"
LABEL description="Antigravity Manager - 一键部署版"

ENV TITLE="Antigravity Tools"
ENV DEBIAN_FRONTEND=noninteractive

# 接收从 GitHub Actions 传入的下载链接
ARG DEB_URL_AMD64
ARG DEB_URL_ARM64
# Docker Buildx 会自动填充当前构建的架构 (amd64 或 arm64)
ARG TARGETARCH

WORKDIR /app

# 1. 安装基础工具、图形界面库依赖、以及 gdebi (关键)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        wget \
        jq \
        ca-certificates \
        gnupg \
        fonts-wqy-zenhei \
        fonts-wqy-microhei \
        mousepad \
        gdebi-core \
        libnss3 \
        libatk1.0-0 \
        libatk-bridge2.0-0 \
        libcups2 \
        libdrm2 \
        libgtk-3-0 \
        libgbm1 \
        libasound2 && \
    \
    # 2. ====== 安装 Antigravity 主程序 (官方源) ======
    echo "📦 [Base] Installing Antigravity from official repo..." && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | \
        gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | \
        tee /etc/apt/sources.list.d/antigravity.list > /dev/null && \
    apt-get update && \
    apt-get install -y antigravity && \
    \
    # 3. ====== 安装 Antigravity-Manager (根据架构选择链接) ======
    echo "🏗️ [Manager] Building for architecture: $TARGETARCH" && \
    if [ "$TARGETARCH" = "amd64" ]; then \
        DOWNLOAD_URL="$DEB_URL_AMD64"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        DOWNLOAD_URL="$DEB_URL_ARM64"; \
    else \
        echo "❌ Error: Unsupported architecture: $TARGETARCH"; exit 1; \
    fi && \
    \
    # 检查链接是否为空 (防止上游没有 ARM 版本导致构建假死)
    if [ -z "$DOWNLOAD_URL" ]; then \
        echo "❌ Error: No download URL provided for $TARGETARCH. (Upstream might lack this arch)"; \
        exit 1; \
    fi && \
    \
    echo "⬇️ [Manager] Downloading from: $DOWNLOAD_URL" && \
    wget -q --show-progress -O /tmp/install.deb "$DOWNLOAD_URL" && \
    \
    # 使用 gdebi 安装，自动解决依赖地狱
    echo "📦 [Manager] Installing via gdebi..." && \
    gdebi -n /tmp/install.deb && \
    \
    # 4. ====== 清理工作 (保留 curl 用于健康检查) ======
    apt-get purge -y wget gnupg gdebi-core && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 创建符号链接确保路径正确
RUN ln -sf /usr/bin/antigravity /usr/local/bin/antigravity 2>/dev/null || true

# 健康检查 (Webtop 默认端口 3000)
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1
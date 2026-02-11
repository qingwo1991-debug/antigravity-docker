# ------------------------------------------------------------------------------
# Dockerfile - Antigravity Manager (Final Fixed Version)
# ------------------------------------------------------------------------------
# 使用 IceWM 版本，体积比 XFCE 小很多，启动更快，且包含完整界面
FROM lscr.io/linuxserver/webtop:ubuntu-icewm

LABEL maintainer="你的GitHub用户名 <你的邮箱>"
LABEL description="Antigravity Manager - 极速精简版"

ENV TITLE="Antigravity Tools"
ENV DEBIAN_FRONTEND=noninteractive

# 接收构建参数
ARG DEB_URL_AMD64
ARG DEB_URL_ARM64
ARG TARGETARCH

WORKDIR /app

# 1. 安装基础工具
# 🔴 关键修复：移除了所有手动指定的 libxxx 库 (如 libasound2)
# 让后续的 install.deb 步骤自动去仓库里拉取正确版本的依赖 (libasound2t64)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        wget \
        jq \
        ca-certificates \
        gnupg \
        fonts-wqy-zenhei \
        fonts-wqy-microhei && \
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
    # 3. ====== 下载 Manager ======
    echo "🏗️ [Manager] Processing for architecture: $TARGETARCH" && \
    if [ "$TARGETARCH" = "amd64" ]; then \
        DOWNLOAD_URL="$DEB_URL_AMD64"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        DOWNLOAD_URL="$DEB_URL_ARM64"; \
    else \
        echo "❌ Error: Unsupported architecture: $TARGETARCH"; exit 1; \
    fi && \
    \
    if [ -z "$DOWNLOAD_URL" ]; then \
        echo "❌ Error: No download URL provided for $TARGETARCH."; exit 1; \
    fi && \
    \
    echo "⬇️ Downloading from: $DOWNLOAD_URL" && \
    wget -q --show-progress -O /tmp/install.deb "$DOWNLOAD_URL" && \
    \
    # 4. ====== 安装 Manager (自动解决依赖) ======
    # 🔴 关键点：使用 apt-get install ./xxx.deb
    # 它会自动发现系统需要 libasound2t64 而不是 libasound2，并自动安装，不会报错
    echo "📦 [Manager] Installing via apt (auto-resolve dependencies)..." && \
    apt-get install -y /tmp/install.deb && \
    \
    # 5. ====== 清理 ======
    apt-get purge -y wget gnupg && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 符号链接
RUN ln -sf /usr/bin/antigravity /usr/local/bin/antigravity 2>/dev/null || true

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# ------------------------------------------------------------------------------
# Dockerfile
# ------------------------------------------------------------------------------
FROM lscr.io/linuxserver/webtop:ubuntu-xfce

LABEL maintainer="你的GitHub用户名 <你的邮箱>"
LABEL description="Antigravity Manager - 一键部署版"

ENV TITLE="Antigravity Tools"
ENV DEBIAN_FRONTEND=noninteractive

# 接收构建参数（由 GitHub Actions 传入）
ARG DEB_URL

WORKDIR /app

# 1. 安装基础工具
# 2. 安装 gdebi-core (关键！用于自动解决本地 .deb 的依赖问题)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        wget \
        ca-certificates \
        gnupg \
        fonts-wqy-zenhei \
        fonts-wqy-microhei \
        mousepad \
        gdebi-core && \
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
    echo "📦 Downloading Manager from: $DEB_URL" && \
    if [ -z "$DEB_URL" ]; then echo "❌ Error: DEB_URL is empty" && exit 1; fi && \
    \
    # 下载并重命名
    wget -q --show-progress -O /tmp/install.deb "$DEB_URL" && \
    \
    # 使用 gdebi 安装 (它会自动补全 libnss3, libgtk-3 等缺失的依赖)
    gdebi -n /tmp/install.deb && \
    \
    # ====== 清理 ======
    apt-get purge -y wget gnupg gdebi-core && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 创建符号链接
RUN ln -sf /usr/bin/antigravity /usr/local/bin/antigravity 2>/dev/null || true

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1
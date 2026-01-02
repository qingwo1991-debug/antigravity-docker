# antigravity-docker
antigravity-docker
https://github.com/lbjlaq/Antigravity-Manager
非官方的docker


📖 访问方式
| 方式 | 地址 | 说明 |
|------|------|------|
| Web 桌面 | `http://你的IP:5800` | 浏览器远程桌面 |
| HTTPS | `https://你的IP:3011` | 加密连接 |


🔧 高级配置
📡 配置代理（网络环境需要）
environment:
  - HTTP_PROXY=http://代理IP:端口
  - HTTPS_PROXY=http://代理IP:端口
🖥️ 自定义分辨率
environment:
  - DISPLAY_WIDTH=1920
  - DISPLAY_HEIGHT=1080


🙏 鸣谢
lbjlaq/Antigravity-Manager - 原项目（https://github.com/lbjlaq/Antigravity-Manager）

linuxserver/webtop - 基础镜像（https://github.com/linuxserver/docker-webtop）

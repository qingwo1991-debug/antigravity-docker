#antigravity-docker
antigravity-docker
数据来源https://github.com/lbjlaq/Antigravity-Manager
只做docker打包，需要的朋友可以试试

如果这个项目帮到了你，请给个 Star ⭐


📖 访问方式
| 方式 | 地址 | 说明 |
|------|------|------|
| Web 桌面 | `http://你的IP:5800` | 浏览器远程桌面 |
| HTTPS | `https://你的IP:3011` | 加密连接，没有加证书不建议暴露公网，最好加个ng做下反代|


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

记得右键打开terminal
然后执行

<img width="3840" height="2160" alt="image" src="https://github.com/user-attachments/assets/7ad1b619-c3b6-4913-8734-28c4c3cf5f4b" />

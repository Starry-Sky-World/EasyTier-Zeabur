# 第一阶段：使用 Debian 作为基础镜像
FROM debian:bookworm-slim

# 设置工作目录
WORKDIR /app

# 1. 安装下载和运行所需的工具
# 2. 从 GitHub API 获取最新的 linux-x86_64 zip 包链接
# 3. 下载、解压、赋权并清理临时文件
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && LATEST_URL=$(curl -s https://api.github.com/repos/EasyTier/EasyTier/releases/latest | \
       jq -r '.assets[] | select(.name | contains("linux-x86_64")) | .browser_download_url' | grep ".zip") \
    && echo "Downloading from: $LATEST_URL" \
    && curl -L -o easytier.zip "$LATEST_URL" \
    && unzip easytier.zip \
    && rm easytier.zip \
    && chmod +x easytier-web-embed

# 设置默认环境变量（对应你要求的默认值）
ENV PORT=11211
ENV HOST=127.0.0.1
ENV CONFIG_PORT=22020

# 暴露常用的 Web 和配置端口
EXPOSE 11211 22020

# 使用 sh -c 来确保环境变量被正确解析并注入到启动参数中
ENTRYPOINT ["sh", "-c", "./easytier-web-embed --api-server-port ${PORT} --api-host http://${HOST}:${PORT} --config-server-port ${CONFIG_PORT} --config-server-protocol tcp"]

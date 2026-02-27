FROM debian:bookworm-slim

# 安装必要依赖
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 1. 下载最新版
# 2. 解压 (使用 -j 参数把文件直接解压到当前目录，不保留压缩包内的子文件夹结构)
# 3. 赋权
RUN LATEST_URL=$(curl -s https://api.github.com/repos/EasyTier/EasyTier/releases/latest | \
    jq -r '.assets[] | select(.name | contains("linux-x86_64")) | .browser_download_url' | grep ".zip") && \
    echo "Downloading from: $LATEST_URL" && \
    curl -L -o easytier.zip "$LATEST_URL" && \
    unzip -j easytier.zip && \
    rm easytier.zip && \
    chmod +x easytier-web-embed

# 设置默认环境变量
ENV PORT=11211
ENV HOST=127.0.0.1
ENV CONFIG_PORT=22020

# 暴露端口
EXPOSE 11211 22020

# 启动命令
ENTRYPOINT ["sh", "-c", "./easytier-web-embed --api-server-port ${PORT} --api-host http://${HOST}:${PORT} --config-server-port ${CONFIG_PORT} --config-server-protocol tcp"]

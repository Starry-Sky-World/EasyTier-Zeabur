FROM debian:bookworm-slim

# 安装必要依赖
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 自动获取最新版本并下载解压
RUN export LATEST_URL=$(curl -s https://api.github.com/repos/EasyTier/EasyTier/releases/latest | \
    jq -r '.assets[] | select(.name | contains("linux-x86_64")) | .browser_download_url' | grep ".zip") && \
    curl -L -o easytier.zip "$LATEST_URL" && \
    unzip easytier.zip && \
    rm easytier.zip && \
    chmod +x easytier-web-embed

# 设置默认环境变量
ENV PORT=11211
ENV HOST=127.0.0.1
ENV CONFIG_PORT=22020

# 使用 sh -c 这种方式可以完美处理环境变量替换，且不会产生解析错误
ENTRYPOINT ["sh", "-c", "./easytier-web-embed --api-server-port ${PORT} --api-host http://${HOST}:${PORT} --config-server-port ${CONFIG_PORT} --config-server-protocol tcp"]

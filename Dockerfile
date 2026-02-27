# 使用轻量级的 Debian 镜像，确保 glibc 环境兼容性
FROM debian:bookworm-slim

# 安装必要的依赖：curl(下载), jq(解析JSON), unzip(解压), ca-certificates(HTTPS支持)
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 1. 自动获取 GitHub 最新 Release 的下载链接
# 2. 下载、解压并赋予执行权限
RUN export LATEST_URL=$(curl -s https://api.github.com/repos/EasyTier/EasyTier/releases/latest | \
    jq -r '.assets[] | select(.name | contains("linux-x86_64")) | .browser_download_url' | grep ".zip") && \
    echo "Downloading from: $LATEST_URL" && \
    curl -L -o easytier.zip "$LATEST_URL" && \
    unzip easytier.zip && \
    rm easytier.zip && \
    chmod +x easytier-web-embed

# 创建 entrypoint.sh 脚本
RUN echo '#!/bin/sh\n\
./easytier-web-embed \\\
    --api-server-port "${PORT:-11211}" \\\
    --api-host "http://${HOST:-127.0.0.1}:${PORT:-11211}" \\\
    --config-server-port "${CONFIG_PORT:-22020}" \\\
    --config-server-protocol tcp' > /app/entrypoint.sh && \
    chmod +x /app/entrypoint.sh

# 设置默认环境变量
ENV PORT=11211
ENV HOST=127.0.0.1
ENV CONFIG_PORT=22020

# 暴露端口（可选，根据需要调整）
EXPOSE 11211 22020

ENTRYPOINT ["/app/entrypoint.sh"]

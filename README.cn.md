[English](README.md)

# Tailscale IP Derper

适用于无域名的服务器的 [Tailscale](https://github.com/tailscale/tailscale) DERP 服务器 Docker 镜像，使用自签名证书实现。

<p align="center">
  <a href="https://github.com/GT-610/ip-derper/actions/workflows/docker-publish.yml"><img src="https://github.com/GT-610/ip-derper/actions/workflows/docker-publish.yml/badge.svg" alt="Docker"></a>
  <img src="https://img.shields.io/github/license/GT-610/ip-derper" alt="GitHub License">
</p>

## 功能

- 使用最新的 Tailscale 代码滚动发布
- 自动生成自签名证书（或使用您自己的证书）
- 配置简单

## 环境要求

- Docker / Podman
- 手动编译需要 Go 1.21+

## 安装

### 使用 Docker / Podman（推荐）

```bash
# 拉取最新镜像
docker pull ghcr.io/gt-610/ip-derper:latest

# 运行容器
docker run -d --name ip-derper -p 443:443 -p 3478:3478/udp ghcr.io/gt-610/ip-derper:latest
```

### 使用 Docker Compose / Podman Compose

示例 `docker-compose.yml` 如下：

```yaml
services:
  derper:
    image: ghcr.io/gt-610/ip-derper:latest
    container_name: derper # 容器名称任意
    restart: unless-stopped
    ports:
      - "443:443" # DERP 服务器端口
      - "3478:3478/udp" # STUN 端口
    environment:
      - DERP_HOST=127.0.0.1 # 改成服务器公网 IP
      - DERP_VERIFY_CLIENTS=false # 如果你不希望其他人使用此 DERP 服务器，将其设置为 true 并把你的服务器添加到你的 Tailscale 网络中
```

### 使用您自己的 SSL 证书

Let's Encrypt 现在 [支持 IP 证书](https://letsencrypt.org/2025/07/01/issuing-our-first-ip-address-certificate)，因此你也可以使用它们的证书而不是自签名。

1. 设置 `DERP_SELF_CERT=false`
2. 将证书挂载到 `/app/certs/<DERP_HOST>.crt`
3. 将私钥挂载到 `/app/certs/<DERP_HOST>.key`

`<DERP_HOST>` 指你配置的 `DERP_HOST` 的值。

（例如，如果你设置 `DERP_HOST=192.168.1.100`，你需要挂载到 `/app/certs/192.168.1.100.crt` 和 `/app/certs/192.168.1.100.key`）。

示例：

```yaml
services:
  derper:
    image: ghcr.io/gt-610/ip-derper:latest
    container_name: derper
    restart: unless-stopped
    ports:
      - "443:443"
      - "3478:3478/udp"
    environment:
      - DERP_HOST=127.0.0.1 # 服务器公网 IP
      - DERP_SELF_CERT=false
    volumes:
      - /path/to/your/cert.crt:/app/certs/127.0.0.1.crt # CER 文件 (/path/to/your/cert.cer) 需要挂载为 /app/certs/127.0.0.1.cer
      - /path/to/your/key.key:/app/certs/127.0.0.1.key
```

### 手动构建

```bash
# 克隆仓库
git clone https://github.com/gt-610/ip-derper.git
cd ip-derper

docker build -t ip-derper .
```

## 配置

| 环境变量 | 描述 | 可选/必需 | 允许值 |
| --- | --- | --- | --- |
| `DERP_HOST` | DERP 服务器的主机名（可选，IP 或域名） | 可选 | 有效的 IP 地址或域名（例如，`192.168.1.100` 或 `example.com`） |
| `DERP_STUN` | 启用 STUN 服务 | **必需** | `true` 或 `false` |
| `DERP_VERIFY_CLIENTS` | 是否允许其他客户端使用此 DERP 服务器 | **必需** | `true` 或 `false` |
| `DERP_SELF_CERT` | 是否自动生成自签名证书 | 可选 | `true`（默认）或 `false` |

## 技术细节

### Dockerfile

Dockerfile 会在 Alpine Linux 基础上构建一个最小镜像。执行步骤包括：

- 从 GitHub 下载 Tailscale DERP 服务器代码并编译二进制文件
- 使用内置的 `build_cert.sh` 脚本生成自签名证书
- 优化体积和性能

### 证书构建脚本

`build_cert.sh` 脚本在容器启动时自动生成自签名证书。它会创建：

- 一个 2048 位 RSA 私钥
- 一个使用 ECDSA secp384r1 曲线和 SHA-384 签名的证书
- 配置主机名的主题备用名称 (SAN)
- 适用于 Web 服务器使用的适当证书扩展

### GitHub Actions 工作流

仓库包含一个用于自动 Docker 镜像发布的 GitHub Actions 工作流。它会：

- 为 main 分支构建并推送 `latest` 标签镜像
- 使用 cosign 签署镜像以确保安全性

## 贡献

fork 改完然后开 PR 即可。我们欢迎任何积极贡献。

## 许可证

本项目使用 [Apache License 2.0](LICENSE) 许可证。

[Tailscale 代码](https://github.com/tailscale/tailscale) 的使用根据其自己的许可证。
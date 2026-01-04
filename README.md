# Tailscale IP Derper

A [Tailscale](https://github.com/tailscale/tailscale) DERP server docker image, using self-signed certificates for servers without domains.

<p align="center">
  <a href="https://github.com/GT-610/ip-derper/actions/workflows/docker-publish.yml"><img src="https://github.com/GT-610/ip-derper/actions/workflows/docker-publish.yml/badge.svg" alt="Docker"></a>
  <img src="https://img.shields.io/github/license/GT-610/ip-derper" alt="GitHub License">
</p>


## Features

- Rolling release with latest Tailscale code
- Automatic self-signed certificate generation
- Easy to configure

## Prerequisites

- Docker / Podman
- Or Go 1.21+ for manual compilation

## Installation

### Use with Docker / Podman (Recommended)

```bash
# Pull the latest image
docker pull ghcr.io/gt-610/ip-derper:latest

# Run the container
docker run -d --name ip-derper -p 443:443 -p 3478:3478/udp ghcr.io/gt-610/ip-derper:latest
```

### Use with Docker Compose / Podman Compose
An example `docker-compose.yml` file should look like this:

```yaml
services:
  derper:
    image: ghcr.io/gt-610/ip-derper:latest
    container_name: derper # Or your favorite
    restart: unless-stopped
    ports:
      - "443:443" # DERP server port
      - "3478:3478/udp" # STUN port
    environment:
      - DERP_HOST=127.0.0.1 # Change this to your server's public internet IP
      - DERP_ADDR=:443 # No need to modify
      - DERP_CERTS=/app/certs # No need to modify
      - DERP_VERIFY_CLIENTS=false # If you don't want other clients to use this DERP, add your server to your Tailnet and set it to true
```

### Manual Compilation

```bash
# Clone the repository
git clone https://github.com/gt-610/ip-derper.git
cd ip-derper

docker build -t ip-derper .
```

## Configuration

The DERP server can be configured through environment variables:

| Environment Variable | Description | Optional/Required | Allowed Values |
| --- | --- | --- | --- |
| `DERP_ADDR` | Advertised port for the DERP server | **Required** | port with a colon (e.g., `:443`) |
| `DERP_HOST` | The hostname for the DERP server (optional, IP or domain) | Optional | Valid IP address or domain name (e.g., `192.168.1.100` or `example.com`) |
| `DERP_STUN` | Enable STUN service | **Required** | `true` or `false` |
| `DERP_VERIFY_CLIENTS` | Whether to allow other clients to use this DERP server | **Required** | `true` or `false` |

## Technical Details

### Dockerfile

The included Dockerfile builds a minimal image based on Alpine Linux. It will:

- Download Tailscale DERP server code from GitHub and compile DERP server binary
- Automatically generate self-signed certificates using the included `build_cert.sh` script
- Optimize for size and performance

### Certificate build script

The `build_cert.sh` script automatically generates self-signed certificates when the container starts. It creates:

- A 2048-bit RSA private key
- A certificate with ECDSA secp384r1 curve and SHA-384 signature
- Subject Alternative Name (SAN) for the configured hostname
- Proper certificate extensions for web server usage

### GitHub Actions Workflow

The repository includes a GitHub Actions workflow for automatic Docker image publishing. It:

- Builds and pushes a `latest` tag image for the main branch
- Signs images using cosign for security

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your changes.

## License

This project is licensed under the [Apache License 2.0](LICENSE).

Usage of [Tailscale code](https://github.com/tailscale/tailscale) is licensed under its respective license.

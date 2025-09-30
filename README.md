# IP Derper

A Tailscale DERP server docker image, using self-signed certificates for servers without domains.

## Features

- Sync up with latest official code
- Automatic self-signed certificate generation
- Ready for Docker
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


### Manual Compilation

```bash
# Clone the repository
git clone https://github.com/gt-610/ip-derper.git
cd ip-derper

docker build -t ip-derper .
```

## Configuration

The DERP server can be configured through environment variables or command-line arguments:

### Environment Variables

| Environment Variable | Description | Optional/Required | Allowed Values |
| --- | --- | --- | --- |
| `DERP_ADDR` | Advertised port for the DERP server | **Required** | port with a colon (e.g., `:443`) |
| `DERP_HOST` | The hostname for the DERP server (optional, IP or domain) | Optional | Valid IP address or domain name (e.g., `192.168.1.100` or `example.com`) |
| `DERP_STUN` | Enable STUN service | **Required** | `true` or `false` |
| `DERP_VERIFY_CLIENTS` | Verify client certificates | **Required** | `true` or `false` |

## Technical Details

### Dockerfile

The included Dockerfile builds a minimal image based on Alpine Linux. Key features:

- Automatic certificate generation using the included `build_cert.sh` script
- Optimized for size and performance

### Certificate build script

The `build_cert.sh` script automatically generates self-signed certificates when the container starts. It creates:

- A 2048-bit RSA private key
- A certificate with ECDSA secp384r1 curve and SHA-384 signature
- Subject Alternative Name (SAN) for the configured hostname
- Proper certificate extensions for web server usage

### GitHub Actions Workflow

The repository includes a GitHub Actions workflow for automatic Docker image publishing. It:

- Builds and pushes images on pushes to the main branch
- Creates versioned tags for semver tags (e.g., v1.2.3)
- Pushes a `latest` tag for the main branch
- Signs images using cosign for security

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your changes.

## License

This project is licensed under the [Apache License 2.0](LICENSE).
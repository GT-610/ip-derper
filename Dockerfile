FROM golang:latest AS builder
# Build stage with latest Go version

LABEL org.opencontainers.image.source https://github.com/GT-610/ip-derper

# Set environment variables for build
ENV CGO_ENABLED=0 \
    GOOS=linux

WORKDIR /app

# Install git needed for cloning

# Only for China mainland users: Use mirror to download
# RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clone the latest tailscale repository

# Only for China mainland users: Use mirror to download
# RUN go env -w GO111MODULE=on && \
#     go env -w GOPROXY=https://goproxy.cn,direct

# Only for China mainland users: Use mirror to download
# RUN git clone https://gh.llkk.cc/https://github.com/tailscale/tailscale.git

RUN git clone https://github.com/tailscale/tailscale.git
RUN cd tailscale/cmd/derper && \
    go build -buildvcs=false -ldflags "-s -w" -o /app/derper

# Runtime stage with minimal Alpine image
FROM alpine:latest

WORKDIR /app

# ========= CONFIG =========
# - derper args
ENV DERP_ADDR :443
ENV DERP_HTTP_PORT 80
ENV DERP_HOST=127.0.0.1
ENV DERP_CERTS=/app/certs
ENV DERP_STUN true
ENV DERP_VERIFY_CLIENTS false
# ==========================

# Install only necessary packages

# Only for China mainland users: Use mirror to download
# RUN sed -i 's#https\?://dl-cdn.alpinelinux.org/alpine#https://mirrors.aliyun.com/alpine#g' /etc/apk/repositories

RUN apk --no-cache add openssl \
    && rm -rf /var/cache/apk/*

# Create certs directory
RUN mkdir -p $DERP_CERTS && \
    chmod 700 $DERP_CERTS

# Copy necessary files
COPY build_cert.sh /app/
COPY --from=builder /app/derper /app/derper

# Set executable permissions
RUN chmod +x /app/derper /app/build_cert.sh

# Build self-signed certs && start derper with enhanced security
CMD /app/build_cert.sh $DERP_HOST $DERP_CERTS /app/cert.conf && \
    /app/derper --hostname=$DERP_HOST \
    --certmode=manual \
    --certdir=$DERP_CERTS \
    --stun=$DERP_STUN \
    --a=$DERP_ADDR \
    --http-port=$DERP_HTTP_PORT \
    --verify-clients=$DERP_VERIFY_CLIENTS

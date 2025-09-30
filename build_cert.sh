#!/bin/sh
# Enhanced security certificate generation script

# Set strict shell options for better error handling
set -eu

# Validate input parameters
if [ $# -ne 3 ]; then
    echo "Usage: $0 <cert_host> <cert_dir> <conf_file>" >&2
    exit 1
fi

CERT_HOST=$1
CERT_DIR=$2
CONF_FILE=$3

# Create cert directory with secure permissions
mkdir -p "$CERT_DIR" && chmod 700 "$CERT_DIR"

# Generate openssl configuration with enhanced security settings
echo "[req]
default_bits = 2048
distinguished_name = req_distinguished_name
req_extensions = req_ext
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
countryName = XX
stateOrProvinceName = N/A
localityName = N/A
organizationName = Self-signed certificate
commonName = $CERT_HOST: Self-signed certificate

[req_ext]
subjectAltName = @alt_names
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = critical, serverAuth

[v3_req]
subjectAltName = @alt_names
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = critical, serverAuth
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer:always

[alt_names]
DNS.1 = $CERT_HOST
IP.1 = $CERT_HOST
" > "$CONF_FILE"

# Set secure permissions for config file
chmod 600 "$CONF_FILE"

# Generate certificate with highest security settings
# - Using ECDSA with secp384r1 curve for strong encryption
# - Using SHA-384 for secure hashing
# - Setting certificate validity to 365 days (industry best practice)
# - Removing passphrase for automated operation
openssl req -x509 -nodes -days 365 -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 \
    -keyout "$CERT_DIR/$CERT_HOST.key" -out "$CERT_DIR/$CERT_HOST.crt" \
    -config "$CONF_FILE" -sha384

# Set secure permissions for certificate files
chmod 600 "$CERT_DIR/$CERT_HOST.key"
chmod 644 "$CERT_DIR/$CERT_HOST.crt"

# Clean up temporary config file
rm -f "$CONF_FILE"

# Print success message
if [ -f "$CERT_DIR/$CERT_HOST.key" ] && [ -f "$CERT_DIR/$CERT_HOST.crt" ]; then
    echo "Successfully generated self-signed certificate for $CERT_HOST"
    echo "Certificate path: $CERT_DIR/$CERT_HOST.crt"
    echo "Private key path: $CERT_DIR/$CERT_HOST.key"
else
    echo "Failed to generate certificate" >&2
    exit 1
fi

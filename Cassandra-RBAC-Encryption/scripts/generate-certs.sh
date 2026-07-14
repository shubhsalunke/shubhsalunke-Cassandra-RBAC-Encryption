#!/bin/bash
# Certificate generator for Cassandra Client-to-Node SSL (Linux/macOS)
set -e

# Change directory to project root if script is run from within scripts/
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

CERTS_DIR="certs"
KEYSTORE_PATH="$CERTS_DIR/cassandra.keystore"
CERT_PATH="$CERTS_DIR/cassandra.crt"
PASSWORD="cassandra123"
ALIAS="cassandra"

# Allow passing external IP or hostname as argument, default to localhost
HOST_IP=${1:-"localhost"}

echo "=========================================================="
echo " Cassandra SSL Keystore & Certificate Generator"
echo "=========================================================="

# Ensure certs directory exists
mkdir -p "$CERTS_DIR"

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
    echo "[!] Error: 'keytool' is not installed or not in PATH. Please install Java JDK."
    exit 1
fi

# Remove existing keystore if exists to avoid conflicts
if [ -f "$KEYSTORE_PATH" ]; then
    echo "[-] Removing existing keystore at $KEYSTORE_PATH..."
    rm "$KEYSTORE_PATH"
fi

echo "[*] Generating Java Keystore for host/IP: $HOST_IP..."
keytool -genkeypair \
  -alias "$ALIAS" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 3650 \
  -keystore "$KEYSTORE_PATH" \
  -storepass "$PASSWORD" \
  -keypass "$PASSWORD" \
  -dname "CN=$HOST_IP, OU=DevOps, O=Demo, L=Pune, ST=MH, C=IN"

echo "[+] Keystore successfully generated at $KEYSTORE_PATH"

# Remove existing cert if exists
if [ -f "$CERT_PATH" ]; then
    echo "[-] Removing existing certificate at $CERT_PATH..."
    rm "$CERT_PATH"
fi

echo "[*] Exporting public certificate..."
keytool -exportcert \
  -alias "$ALIAS" \
  -keystore "$KEYSTORE_PATH" \
  -storepass "$PASSWORD" \
  -rfc \
  -file "$CERT_PATH"

echo "[+] Certificate successfully exported to $CERT_PATH"
echo "=========================================================="
echo " Certificates setup complete!"
echo "=========================================================="

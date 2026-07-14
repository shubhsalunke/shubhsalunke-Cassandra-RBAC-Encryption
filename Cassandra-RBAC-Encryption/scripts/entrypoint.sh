#!/bin/bash
set -e

CONFIG_FILE="/etc/cassandra/cassandra.yaml"

echo "=========================================================="
echo " Starting Custom Cassandra Security Bootstrapper"
echo "=========================================================="

if [ -f "$CONFIG_FILE" ]; then
    echo "[*] Configuring authentication & authorization in $CONFIG_FILE..."
    
    # 1. Enable Password Authentication
    sed -i 's/authenticator: AllowAllAuthenticator/authenticator: PasswordAuthenticator/' "$CONFIG_FILE"
    
    # 2. Enable Cassandra Authorization (RBAC)
    sed -i 's/authorizer: AllowAllAuthorizer/authorizer: CassandraAuthorizer/' "$CONFIG_FILE"
    
    echo "[*] Configuring Client-to-Node SSL Encryption..."
    
    # 3. Enable encryption under client_encryption_options block
    sed -i '/client_encryption_options:/,/^[a-z_]/ s/enabled: false/enabled: true/' "$CONFIG_FILE"
    
    # Disable optional SSL (force all client traffic to use SSL)
    sed -i '/client_encryption_options:/,/^[a-z_]/ s/# optional: true/optional: false/' "$CONFIG_FILE"
    sed -i '/client_encryption_options:/,/^[a-z_]/ s/optional: true/optional: false/' "$CONFIG_FILE"
    
    # Point to the generated keystore and set the password
    sed -i '/client_encryption_options:/,/^[a-z_]/ s#keystore: conf/.keystore#keystore: /certs/cassandra.keystore#' "$CONFIG_FILE"
    sed -i '/client_encryption_options:/,/^[a-z_]/ s#keystore_password: .*#keystore_password: cassandra123#' "$CONFIG_FILE"
    
    # Ensure client authentication is disabled (not requiring client certificates for mTLS, only one-way SSL)
    sed -i '/client_encryption_options:/,/^[a-z_]/ s/require_client_auth: true/require_client_auth: false/' "$CONFIG_FILE"
    
    # Secure and set permissions on certificate files so the 'cassandra' user can read them
    echo "[*] Adjusting certificates directory permissions..."
    chmod 755 /certs || true
    chmod 644 /certs/cassandra.keystore 2>/dev/null || true
    chmod 644 /certs/cassandra.crt 2>/dev/null || true
    chown -R 999:999 /certs 2>/dev/null || true
    
    echo "[+] Configuration successfully injected."
else
    echo "[!] Cassandra configuration file not found at $CONFIG_FILE"
fi

echo "=========================================================="
echo " Handing execution over to official docker-entrypoint.sh"
echo "=========================================================="
exec /docker-entrypoint.sh "$@"

#!/bin/bash
# Cassandra Database & RBAC Bootstrapper
set -e

export SSL_CERTFILE="/certs/cassandra.crt"

echo "=========================================================="
echo " Starting Cassandra DB & RBAC Schema Initializer"
echo "=========================================================="

echo "[*] Waiting for Cassandra CQL service to accept SSL connections..."
MAX_ATTEMPTS=30
ATTEMPT=1

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
    if cqlsh --ssl -u cassandra -p cassandra -e "DESCRIBE KEYSPACES" > /dev/null 2>&1; then
        echo "[+] Cassandra is online and accepting SSL connections!"
        break
    fi
    echo "[-] Attempt $ATTEMPT/$MAX_ATTEMPTS: Cassandra is not ready yet. Retrying in 5 seconds..."
    sleep 5
    ATTEMPT=$((ATTEMPT + 1))
done

if [ $ATTEMPT -gt $MAX_ATTEMPTS ]; then
    echo "[!] Error: Cassandra did not become ready within the timeout period."
    exit 1
fi

echo "[*] Applying schema and roles configuration from /scripts/schema.cql..."
if cqlsh --ssl -u cassandra -p cassandra -f /scripts/schema.cql; then
    echo "[+] Schema and Roles applied successfully!"
else
    echo "[!] Error: Failed to apply CQL schema."
    exit 1
fi

echo "=========================================================="
echo " Database Initialization Completed Successfully"
echo "=========================================================="

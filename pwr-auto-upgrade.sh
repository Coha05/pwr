#!/bin/bash

set -euo pipefail

echo "Select mode:"
select MODE in "Upgrade" "Full Reset"; do
  case $MODE in
    "Upgrade") break ;;
    "Full Reset") break ;;
    *) echo "Invalid option. Choose 1 or 2."; continue ;;
  esac
done

# === Ask for validator version ===
read -rp "Enter the validator version to install (e.g., 15.63.5): " VERSION
JAR_URL="https://github.com/pwrlabs/PWR-Validator/releases/download/${VERSION}/validator.jar"
CONFIG_URL="https://github.com/pwrlabs/PWR-Validator/raw/refs/heads/main/config.json"

echo "[INFO] Selected version: $VERSION"
read -rp "Proceed with $MODE to version $VERSION? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "[ABORTED] Cancelled by user."
  exit 1
fi

# === Detect public IPv4 ===
echo "[INFO] Detecting public IPv4..."
IP=$(curl -s ipinfo.io/ip | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
if [[ -z "$IP" ]]; then
  echo "[WARN] ipinfo.io failed, trying fallback..."
  IP=$(curl -s ifconfig.me | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
fi
if [[ -z "$IP" ]]; then
  echo "[ERROR] Failed to detect public IPv4 address."
  exit 1
fi
echo "[INFO] Detected IP: $IP"

# === Stop validator ===
echo "[1/6] Stopping existing validator..."
sudo pkill java || true
sleep 5
sudo pkill -9 java || true

# === Cleanup ===
echo "[2/6] Cleaning old files..."
rm -f validator.jar config.json nohup.out

if [[ "$MODE" == "Full Reset" ]]; then
  echo "[INFO] Performing full reset. Removing blocks/, merkleTree/, rpcdata/..."
  rm -rf blocks merkleTree rpcdata
fi

# === Download files ===
echo "[3/6] Downloading validator.jar and config.json..."
wget -q "$JAR_URL" -O validator.jar || { echo "[ERROR] Failed to download validator.jar"; exit 1; }
wget -q "$CONFIG_URL" -O config.json || { echo "[ERROR] Failed to download config.json"; exit 1; }

# === Ensure password file ===
echo "[4/6] Checking for password file..."
if [ ! -f password ]; then
  echo "your password here" > password
  echo "[INFO] Created new password file. Edit it if needed."
else
  echo "[INFO] Password file exists."
fi

# === Start validator ===
echo "[5/6] Starting validator on $IP..."
nohup sudo java --enable-native-access=ALL-UNNAMED -Xms1g -Xmx6g -jar validator.jar --ip "$IP" --password password &

# === Finish and verify version ===
echo "[6/6] Validator started. Waiting 5 seconds for startup..."
sleep 5

echo -n "[INFO] Verifying running validator version... "
VERSION_CHECK=$(curl -s localhost:8085/version || echo "Unavailable")

if [[ "$VERSION_CHECK" == "$VERSION" ]]; then
  echo "✅ Version $VERSION is running successfully."
else
  echo "⚠️  Expected $VERSION but got: $VERSION_CHECK"
  echo "      - The validator may still be starting or failed to launch."
  echo "      - Check logs: tail -n 1000 -f nohup.out"
fi

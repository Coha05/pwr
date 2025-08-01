# PWR Auto Upgrade Script

This script automates upgrading or resetting your PWR validator node.

It:
- Stops the running validator
- Cleans up files (based on upgrade or reset mode)
- Downloads the latest validator binary and config
- Ensures your password file is present
- Auto-detects your public IP
- Opens TCP port 9864 if needed
- Restarts the validator with correct flags

---

## ✅ Requirements

- Ubuntu or Debian-based server
- Run as **root** (or with full `sudo` privileges)
- Internet access
- Open TCP port `9864` for inbound connections

---

## 🚀 First-Time Setup

### 1. Download the script

```bash
curl -sSL https://raw.githubusercontent.com/Coha05/pwr/refs/heads/main/pwr-auto-upgrade.sh -o pwr-auto-upgrade.sh
```

**### 2. Make the script executable**

```
chmod +x pwr-auto-upgrade.sh
```
### 3. Usage (Upgrade or Reset)
```
./pwr-auto-upgrade.sh
```

**You will be prompted to:**
- Choose Upgrade or Full Reset
- Enter the desired validator version (e.g. 15.63.5)
- Confirm before continuing

***Note: Make sure your `password` and `wallet` file exist

**You can monitor your validator after launch with:**
```
tail -n 1000 -f nohup.out
```

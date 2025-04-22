#!/bin/bash

# Paths
RULES_FILE="/etc/iptables/rules.v4"
TMP_CLEANED="/tmp/rules_cleaned.v4"

# SSH Targets
NODES=("nl" "uk")  # Hostnames defined in ~/.ssh/config

# Initial hash
LAST_HASH=""

echo "[WATCHER] Starting iptables watcher..."

while true; do
    # Get current iptables rules and normalize
    CURRENT_RULES=$(iptables-save | grep -v '^#' | \
        sed -E 's/\[[0-9]+:[0-9]+\]//g' | \
        sed -E 's/^:([A-Z0-9_\-]+)[[:space:]]+-+$/:\1/' | \
        sed '/^[[:space:]]*$/d')

    # Hash the normalized rules
    CURRENT_HASH=$(echo "$CURRENT_RULES" | md5sum | awk '{print $1}')

    if [[ "$CURRENT_HASH" != "$LAST_HASH" ]]; then
        echo "$CURRENT_RULES" > "$RULES_FILE"
        echo "$CURRENT_RULES" > "$TMP_CLEANED"
        LAST_HASH="$CURRENT_HASH"

        # Timestamp for log
        NOW=$(date '+%Y-%m-%d %H:%M:%S')
        echo "[$NOW] Detected iptables change, syncing to nodes..."

        for NODE in "${NODES[@]}"; do
            rsync "$TMP_CLEANED" "$NODE:$RULES_FILE" && \
            ssh "$NODE" "iptables-restore < $RULES_FILE" && \
            echo "[$NOW] Synced with $NODE"
        done

        echo "[$NOW] Sync complete."
    fi

    sleep 1
done

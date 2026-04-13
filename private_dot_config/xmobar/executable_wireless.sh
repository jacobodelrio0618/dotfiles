#!/bin/sh

# Interface check is fine, but we can simplify the output for wired status
# If the interface exists but is not connected, the script will output "Wifi: 0/5"
# If you prefer "wired" output, keep the original block, but for simplicity, 
# let's rely on nmcli being empty for non-connected states.

# Use a single nmcli call to get the signal strength (0-100)
# -t (terse), -f (fields), grep 'yes' for active connection, then cut out the signal field (3rd field from the output)
STRENGTH_PERCENT=$(nmcli -t -f active,signal dev wifi | grep '^yes' | cut -d: -f2)

# Check if a connection is active (STRENGTH_PERCENT will be empty if not connected)
if [ -z "$STRENGTH_PERCENT" ]; then
    # No active Wi-Fi connection
    # You can change this to "Wifi: 0/5" or "Wifi: Down"
    echo "Wifi: --"
    exit 0
fi

# Map the 0-100 percentage to a 1-5 scale.
# Formula: (Strength / 20) + 1. The 'bc' command handles floating-point math.

# 1. Divide strength by 20 to get 0.0 to 5.0
# 2. Add 0.5 for rounding (e.g., 3.4 + 0.5 = 3.9 -> 3; 3.6 + 0.5 = 4.1 -> 4)
# 3. Use 'scale=0' to ensure the result is an integer (truncating the decimals after adding 0.5)

STRENGTH_SCALE=$(echo "scale=0; ($STRENGTH_PERCENT / 20) + 0.5" | bc)

# Ensure the scale is at least 1 (unless 0% strength) and does not exceed 5.
# If strength is 0%, scale is 0.5 -> 0. We'll set the minimum to 1 for anything connected.
if [ "$STRENGTH_SCALE" -eq 0 ] && [ "$STRENGTH_PERCENT" -gt 0 ]; then
    STRENGTH_SCALE=1
elif [ "$STRENGTH_SCALE" -gt 5 ]; then
    STRENGTH_SCALE=5
fi

# Final output: "Wifi: X/5"
echo "Wifi: $STRENGTH_SCALE/5"

exit 0

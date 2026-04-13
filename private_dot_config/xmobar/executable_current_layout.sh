
#!/bin/bash

# get current workspace number (0-indexed)
CURRENT=$(wmctrl -d | awk '/\*/ {print $1}')

# count total workspaces
TOTAL=$(wmctrl -d | wc -l)

# convert to 1-indexed
CURRENT=$((CURRENT + 1))

echo "Workspace ${CURRENT}/${TOTAL}"

#!/bin/bash
# Entrypoint: persist Docker env vars so SSH sessions can access them
# Write all env vars to a file that bash sources on login

# Save tokens to profile so SSH sessions inherit them
env | grep -E "^(CLICKUP_|GITHUB_|GH_)" >> /etc/environment 2>/dev/null

# Also write to vscode's bashrc for interactive shells
for var in CLICKUP_API_TOKEN GITHUB_TOKEN GH_TOKEN; do
    val="${!var}"
    if [ -n "$val" ]; then
        echo "export ${var}=\"${val}\"" >> /home/vscode/.bashrc
    fi
done
chown vscode:vscode /home/vscode/.bashrc

# Sync Concierge Path hooks into ~/.claude (volume mount overwrites build)
mkdir -p /home/vscode/.claude/hooks
cp /opt/hooks/*.sh /home/vscode/.claude/hooks/ 2>/dev/null
cp /opt/hooks/settings.json /home/vscode/.claude/settings.json 2>/dev/null
chown -R vscode:vscode /home/vscode/.claude/

# Start sshd
exec /usr/sbin/sshd -D

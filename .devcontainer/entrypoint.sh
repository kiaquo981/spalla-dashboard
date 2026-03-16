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

# Start sshd
exec /usr/sbin/sshd -D

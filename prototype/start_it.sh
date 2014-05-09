#!/bin/bash

set -eux
HOST=0.0.0.0
PORT=4343
SSH_USER="root"

# Create a working directory
DIR=$(mktemp -d)
function finish() {
    rm -rf $DIR
}
trap finish EXIT

echo "SSH HOMEDIR: $DIR"

(
    cd "$DIR"

    # Generate a host key
    ssh-keygen -f "$DIR/key_host" -N "" -C "hostkey"

    # Create a directory for the user
    mkdir -p "$SSH_USER/.ssh"

    # Create a user key
    ssh-keygen -f "$DIR/key_$SSH_USER" -N "" -C "$SSH_USER"

    cp key_$USER.pub $SSH_USER/.ssh/authorized_keys

    # Generate config file
    cat > sshd_config << EOF
UsePrivilegeSeparation no
AuthorizedKeysFile $DIR/%u/.ssh/authorized_keys
AllowUsers $SSH_USER
ListenAddress $HOST:$PORT
StrictModes no
EOF

    cat << EOF
About to start sshd server. Connect to it with:

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $DIR/key_$SSH_USER -p $PORT $SSH_USER@localhost

EOF
    # Start sshd server
    fakeroot $(which sshd) -d -D -h "$DIR/key_host" -f "$DIR/sshd_config"
)

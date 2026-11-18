#!/usr/bin/env bash
set -euo pipefail

password_file=/run/ngs-credentials/password
umask 077
if [[ -n ${SSH_PASSWORD:-} || ! -s $password_file ]]; then
  password=${SSH_PASSWORD:-$(od -An -N24 -tx1 /dev/urandom | tr -d '[:space:]')}
  temporary_file=$(mktemp "${password_file}.XXXXXX")
  printf '%s\n' "$password" > "$temporary_file"
  mv -f "$temporary_file" "$password_file"
fi
# The n8n image runs as node (GID 1000).
chgrp 1000 "$password_file"
chmod 0640 "$password_file"
printf 'root:%s\n' "$(cat "$password_file")" | chpasswd
unset SSH_PASSWORD
ssh-keygen -A
/usr/sbin/sshd -t -f /usr/local/etc/sshd_config
exec /usr/sbin/sshd -D -e -f /usr/local/etc/sshd_config

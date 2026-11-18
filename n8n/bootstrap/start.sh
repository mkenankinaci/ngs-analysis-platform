#!/bin/sh
set -eu

data_dir=/home/node/.n8n
pending="$data_dir/.ngs-bootstrap-v1.pending"
done_file="$data_dir/.ngs-bootstrap-v1.done"

if [ ! -e "$done_file" ] && { [ -e "$pending" ] || [ ! -e "$data_dir/database.sqlite" ]; }; then
  umask 077
  touch "$pending"
  temporary_dir=$(mktemp -d)
  trap 'rm -rf "$temporary_dir"' EXIT
  node /opt/ngs-bootstrap/prepare.cjs "$temporary_dir"

  n8n import:credentials --input="$temporary_dir/credentials.json"
  n8n import:workflow --input="$temporary_dir/workflow.json"
  n8n publish:workflow --id=ngsProjectAutoV1

  # Some CLI versions log import errors without returning a nonzero status.
  n8n export:credentials --id=ngsSshPasswordV1 --output="$temporary_dir/check-credential.json"
  n8n export:workflow --id=ngsProjectAutoV1 --published --output="$temporary_dir/check-workflow.json"
  node /opt/ngs-bootstrap/prepare.cjs "$temporary_dir" verify

  mv "$pending" "$done_file"
  rm -rf "$temporary_dir"
  trap - EXIT
fi

exec /docker-entrypoint.sh "$@"

#!/bin/bash

if [[ -n "$USER_ID" ]]; then
  useradd -s /bin/bash -u "$USER_ID" -o -d "$PWD" user
  usermod -aG sudo user
  chown user $(tty)
  exec /usr/local/bin/gosu user "$@"
else
  exec "$@"
fi

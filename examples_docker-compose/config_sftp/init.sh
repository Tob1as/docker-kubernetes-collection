#!/bin/sh

# https://github.com/atmoz/sftp/issues/16#issuecomment-203876715

for user_home in /home/* ; do
  if [ -d "$user_home" ]; then
    username=`basename $user_home`
    echo "Setup $user_home/ folder for $username"
    chown -R $username:users $user_home/
  fi
done
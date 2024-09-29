#!/bin/bash

# clean exit
trap "exit" SIGTERM

# set password
if [ $PASS ]; then
  echo kladmin:$PASS | chpasswd

  # enable root
  if [ $ROOT ]; then
    echo root:$PASS | chpasswd
    usermod -a -G sudo kladmin
  fi
fi

# launch services
if [ $SSH ]; then
  install -m 755 -d /var/run/sshd
  /usr/sbin/sshd -D &
fi

# see you at the restaurant at the end of the universe
sleep infinity &
wait

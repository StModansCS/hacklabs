#!/bin/bash

# clean exit
trap "exit" SIGTERM

# create user
if [ $USER ]; then
  useradd $USER

  # set password
  if [ $PASS ]; then
    echo $USER:$PASS | chpasswd
  else
    echo $USER:password1 | chpasswd
  fi
else
  useradd user1

  # set password
  if [ $PASS ]; then
    echo user1:$PASS | chpasswd
  else
    echo user1:password1 | chpasswd
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

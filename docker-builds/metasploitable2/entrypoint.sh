#!/bin/bash

# clean exit
trap "exit" SIGTERM

# set password
if [ $PASS ]; then
  echo msfadmin:$PASS | chpasswd

  # enable root
  if [ $ROOT ]; then
    echo root:$PASS | chpasswd
  fi
fi

# launch services
if [ $SSH ]; then
  /usr/sbin/sshd -D &
fi

if [ $CUPS ]; then
  /usr/sbin/cups-browsed &
  /usr/sbin/cupsd -f &
fi

if [ $FTP ]; then
  /opt/proftpd/sbin/proftpd &
fi

if [ $HTTP ]; then
  install -m 1777 -d /run/lock
  apachectl start &
fi

if [ $IRC ]; then
  /opt/unrealircd/Unreal3.2/unreal start &
fi

if [ $SMB ]; then
  /usr/sbin/nmbd -D &
  /usr/sbin/smbd -D &
fi

if [ $SQL ]; then
  install -o mysql -g mysql -m 755 -d /run/mysql-default
  /usr/sbin/mysqld --defaults-file=/etc/mysql-default/my.cnf &
fi

# see you at the restaurant at the end of the universe
sleep infinity &
wait

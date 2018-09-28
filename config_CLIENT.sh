#!/usr/bin/env bash

echo -e "---CLIENT CONFIGURATION---\n"
#LOGIN AS SUPERUSER
sudo -i

sed -i "s/nameserver.*/nameserver 172.16.0.30/" /etc/resolv.conf
hostname local.jaramillogarcia.com

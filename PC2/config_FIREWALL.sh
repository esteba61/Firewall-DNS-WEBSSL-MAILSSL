#!/usr/bin/env bash

echo -e "---FIREWALL CONFIGURATION---\n"
#LOGIN AS SUPERUSER
sudo -i

echo -e "---START CONFIGURATION---\n"

service NetworkManager stop
chkconfig NetworkManager off
service firewalld start
chkconfig firewalld on

echo -e "---SETUP RULES---\n"

firewall-cmd --zone=public --remove-interface=enp0s8 --permanent
firewall-cmd --zone=public --remove-interface=enp0s3 --permanent
firewall-cmd --zone=internal --add-interface=enp0s8 --permanent
firewall-cmd --zone=internal --add-service=https --permanent
firewall-cmd --zone=internal --add-service=imaps --permanent
firewall-cmd --zone=internal --add-service=pop3s --permanent
firewall-cmd --zone=internal --add-service=smtps --permanent
firewall-cmd --zone=internal --add-service=dns --permanent
firewall-cmd --zone=public --add-icmp-block=echo-reply --permanent
firewall-cmd --zone=public --add-icmp-block=echo-request --permanent
firewall-cmd --zone=public --add-masquerade --permanent
firewall-cmd --zone=internal --add-masquerade --permanent
firewall-cmd --zone="public" --add-forward-port=port=53:proto=tcp:toport=53:toaddr=172.16.0.30 --permanent
firewall-cmd --zone="public" --add-forward-port=port=443:proto=tcp:toport=443:toaddr=172.16.0.31 --permanent
firewall-cmd --zone="public" --add-forward-port=port=993:proto=tcp:toport=993:toaddr=172.16.0.32 --permanent
firewall-cmd --zone="public" --add-forward-port=port=995:proto=tcp:toport=995:toaddr=172.16.0.32 --permanent
firewall-cmd --zone="public" --add-forward-port=port=465:proto=tcp:toport=465:toaddr=172.16.0.32 --permanent
firewall-cmd --reload

sed -i "s/nameserver.*/nameserver 172.16.0.30/" /etc/resolv.conf
hostname frontedn.jaramillogarcia.com

echo -e "-- END SERVER CONFIGURATION --\n"
#END OF THE CONFIGURATION
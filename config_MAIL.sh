#!/usr/bin/env bash

echo -e "---SERVER-MAIL CONFIGURATION---\n"
#LOGIN AS SUPERUSER
sudo -i

echo -e "---INSTALL SENDMAIL AND DOVECOT---\n"
yum install vim sendmail sendmail-cf telnet telnet-server dovecot -y

echo -e "---ADDUSERS---"
useradd -p $(echo Esteban | openssl passwd -1 -stdin) Esteban
useradd -p $(echo Paola | openssl passwd -1 -stdin) Paola

echo -e "----CREATION CERTIFICATES FILES---"

openssl genrsa -out /etc/pki/tls/private/ca.key 1024
openssl req -new -key /etc/pki/tls/certs/ca.key -out /etc/pki/tls/private/ca.csr -subj "/C=Co/ST=Valle del Cauca/L=Cali/O=UAO/CN=jaramillogarcia.com"
openssl x509 -req -days 365 -in /etc/pki/tls/private/ca.csr -signkey /etc/pki/tls/private/ca.key -out /etc/pki/tls/certs/ca.crt

chmod 600 /etc/pki/tls/certs/ca.crt
chmod 600 /etc/pki/tls/private/ca.key
chmod 600 /etc/pki/tls/private/ca.csr

echo -e "----SENDMAIL CONFIGURATION---"

sed -i "s/DAEMON_OPTIONS(\`Port=smtp,Addr=127.0.0.1, Name=MTA')dnl.*/DAEMON_OPTIONS(\`Port=smtp, Name=MTA')dnl/" /etc/mail/sendmail.mc
sed -i "/dnl define(\`confCACERT_PATH',.*/define(\`confCACERT_PATH' \`\/etc\/pki\/tls\/certs')dnl/" /etc/mail/sendmail.mc
sed -i "/dnl define(\`confCACERT'.*/define(\`confCACERT', \`\/etc\/pki\/tls\/certs\/ca.crt')dnl/" /etc/mail/sendmail.mc
sed -i "/dnl define(\`confSERVER_CERT'.*/define(\`confSERVER_CERT', \`\/etc\/pki\/tls\/certs\/ca.crt')dnl/" /etc/mail/sendmail.mc
sed -i "/dnl define(\`confSERVER_KEY'.*/define(\`confSERVER_KEY', \`\/etc\/pki\/tls\/private\/ca.key')dnl/" /etc/mail/sendmail.mc
sed -i "/dnl DAEMON_OPTIONS(\`Port=smtps, Name=TLSMTA, M=s')dnl.*/DAEMON_OPTIONS(\`Port=smtps, Name=TLSMTA, M=s')dnl/" /etc/mail/sendmail.mc


m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf

echo "jaramillogarcia.com
emails.jaramillogarcia.com" >> /etc/mail/local-host-name

echo "Connect:192.168.1                       RELAY" >> /etc/mail/access
makemap hash /etc/mail/access.db < /etc/mail/access



echo -e "----DOVECOT CONFIGURATION ---"

sed -i "/#protocols = imap pop3 lmtp.*/protocols = imap pop3 lmtp/" /etc/dovecot/dovecot.conf
sed -i "/#   mail_location = mbox:~/mail:INBOX=/var/mail/%u.*/mail_location = mbox:~\/mail:INBOX=\/var\/mail\/%u/" /etc/dovecot/10-mail.conf
sed -i "/#mail_privileged_group =.*/mail_privileged_group = mail/" /etc/dovecot/10-mail.conf
sed -i "/#disable_plaintext_auth =.*/disable_plaintext_auth = no/" /etc/dovecot/conf.d/10-auth.conf
sed -i "/ssl = required.*/ssl = yes/" /etc/dovecot/conf.d/10-ssl.conf

sed -i "/ssl_cert.*/ssl_cert = <\/etc\/pki\/tls\/certs\/ca.crt/" /etc/dovecot/conf.d/10-ssl.conf
sed -i "/ssl_key.*/ssl_key = <\/etc\/pki\/tls\/private\/ca.crt/" /etc/dovecot/conf.d/10-ssl.conf

echo -e "----CONFIGURATION OF resolv.conf file AND hostname---"
sed -i "s/nameserver.*/nameserver 172.16.0.30/" /etc/resolv.conf
hostname emails.jaramillogarcia.com

echo -e "----ENABLE AND START sendmail & dovecot---"

systemctl disable postfix
systemctl stop postfix
systemctl enable sendmail
systemctl start sendmail

systemctl enable dovecot
systemctl start dovecot

echo -e "-- END SERVER CONFIGURATION --\n"
#END OF THE CONFIGURATION
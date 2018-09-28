#!/usr/bin/env bash

echo -e "---SERVER-DNS CONFIGURATION---\n"
#LOGIN AS SUPERUSER
sudo -i

echo -e "---INSTALL HTTPD---\n"
yum install vim http -y

echo -e "----CREATION inex.html---"

touch /var/www/html/index.html
cat > /var/www/html/index.html <<EOF
PARCIAL 2 TELECO 3<br/>
HTTPS CON FIREWALL ACTIVO
EOF

echo -e "----CREATION CERTIFICATES FILES---"

openssl genrsa -out /etc/pki/tls/private/ca.key 1024
openssl req -new -key /etc/pki/tls/certs/ca.key -out /etc/pki/tls/private/ca.csr -subj "/C=Co/ST=Valle del Cauca/L=Cali/O=UAO/CN=jaramillogarcia.com"
openssl x509 -req -days 365 -in /etc/pki/tls/private/ca.csr -signkey /etc/pki/tls/private/ca.key -out /etc/pki/tls/certs/ca.crt

chmod 600 /etc/pki/tls/certs/ca.crt
chmod 600 /etc/pki/tls/private/ca.key
chmod 600 /etc/pki/tls/private/ca.csr

yum install mod_ssl -y

echo -e "----CONFIGURATION HTTPD FILES---"

sed -i "s/SSLCertificateFile.*/SSLCertificateFile \/etc\/pki\/tls\/certs\/ca.crt/" /etc/httpd/conf.d/ssl.conf
sed -i "s/SSLCertificateKeyFile.*/SSLCertificateKeyFile \/etc\/pki\/tls\/private\/ca.key/" /etc/httpd/conf.d/ssl.conf

echo "NameVirtualHost *:443
NameVirtualHost *:80

<VirtualHost *:443>
        SSLEngine On
        SSLCertificateFile /etc/pki/tls/certs/ca.crt
        SSLCertificateKeyFile /etc/pki/tls/private/ca.key
        DocumentRoot /var/www/html/
        ServerName webs.jaramillogarcia.com
</VirtualHost>

<VirtualHost *:80>
        SSLEngine Off
        DocumentRoot /var/www/html/
        ServerName webs.jaramillogarcia.com
</VirtualHost>" >> /etc/http/conf/http.conf

echo -e "----ENABLE AND START named---"

systemctl enable httpd
systemctl start httpd

echo -e "----CONFIGURATION OF resolv.conf file AND hostname---"

sed -i "s/nameserver.*/nameserver 172.16.0.30/" /etc/resolv.conf
hostname webs.jaramillogarcia.com

echo -e "-- END SERVER CONFIGURATION --\n"
#END OF THE CONFIGURATION
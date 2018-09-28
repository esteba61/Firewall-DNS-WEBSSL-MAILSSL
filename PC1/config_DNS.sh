#!/usr/bin/env bash

echo -e "---SERVER-DNS CONFIGURATION---\n"
#LOGIN AS SUPERUSER
sudo -i

echo -e "---INSTALL BIND AND VIM---\n"
yum install bind-utils bind-libs bind-* -y
yum install vim -y

echo -e "----CONFIGURATION named.conf---"

sed -i "s/listen-on port 53.*/listen-on port 53 { 127.0.0.1; 172.16.0.30; };/" /etc/named.conf

#sed -i "s/nameserver.*/nameserver 8.8.8.8/" /etc/resolv.conf

sed -i "s/allow-query.*/allow-query     { localhost; 172.16.0.0\/24; };/" /etc/named.conf
echo '/*Forward Zone JaramilloGarcia*/

zone "jaramillogarcia.com" IN {
        type master;
        file "jaramillogarcia.com.fwd";
};

/*Reverse Zone*/

zone "0.16.172.in-addr.arpa" IN {
        type master;
        file "jaramillogarcia.com.rev";
};' >> /etc/named.conf

echo -e "----CREATION jaramillogarcia.com.fwd---"

touch /var/named/jaramillogarcia.com.fwd
cat > /var/named/jaramillogarcia.com.fwd <<EOF
\$ORIGIN jaramillogarcia.com.
\$TTL 3H

@       IN      SOA     dns.jaramillogarcia.com.        root@jaramillogarcia.com. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
@       IN      NS      dns.jaramillogarcia.com.
@       IN      MX      10      emails.jaramillogarcia.com.
;RR hosts en la zona

dns             IN      A       172.16.0.30
webs            IN      A       172.16.0.31
emails          IN      A       172.16.0.32
frontend        IN      A       192.168.56.10
local           IN      A       192.168.56.11
EOF

echo -e "----CREATION jaramillogarcia.com.rev---"

touch /var/named/jaramillogarcia.com.rev
cat > /var/named/jaramillogarcia.com.rev <<EOF
\$ORIGIN 0.16.172.in-addr.arpa.
\$TTL 3H
@       IN SOA  dns.jaramillogarcia.com. root@jaramillogarcia.com. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
@       IN      NS      dns.jaramillogarcia.com.

;Hosts en la zona

30      IN      PTR     dns.jaramillogarcia.com.
31      IN      PTR     webs.jaramillogarcia.com.
32      IN      PTR     emails.jaramillogarcia.com.
EOF

echo -e "----chmod FOR jaramillogarcia.com.fwd AND jaramillogarcia.com.rev---"

chmod 644 /var/named/jaramillogarcia.com.fwd
chmod 644 /var/named/jaramillogarcia.com.rev

echo -e "----ENABLE AND START named---"

systemctl enable named
systemctl start named

echo -e "----CONFIGURATION OF resolv.conf file AND hostname---"

#sed -i "s/nameserver.*/nameserver 172.16.0.30/" /etc/resolv.conf
hostname dns.jaramillogarcia.com

echo -e "-- END SERVER CONFIGURATION --\n"
#END OF THE CONFIGURATION
# Firewall-DNS-WEBSSL-MAILSSL

When you clone this repository you need.
  1. See the Archic.png file to understand what is the architecture.
  2. cd PC1
  3. vagrant up
  4. cd ..
  5. cd PC1
  6. vagrant up
  
The DNS is jaramillogarcia.com and the host zone is:
  dns       172.16.0.30
  webs      172.16.0.31
  emails    172.16.0.32
  frontend  192.168.56.10
  local     192.168.56.11
  
Test the conectivity whit ping in local / Client host: ping 192.168.56.10 or 172.16.0.32.

Test the webSSL: curl https.webs.jaramillogarcia.com

Test de mailSSL: the tools used is Sendmail and Dovecot, write and send a email.

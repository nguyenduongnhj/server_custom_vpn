cd /root/openvpn/openvpn-2.5.8/ccgost && pwd &&  make
cd /root/openvpn && gcc test.c ./gost.a -lssl -o test -lcrypto


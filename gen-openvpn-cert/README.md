# gen-openvpn-cert

Self-signed OpenVPN TLS certificate generator script. Quickly generate a certificate authority, server, and client keys and certificates.

Generated are `secp384r1` ECC keys, Diffie-Hellman parameters (`dh[dh keysize].pem`), OpenVPN v1 tls-crypt (`ta.key`) and tls-crypt-v2 (`[server|client]-tlsv2.key`) symmetric keys. `rsa` and `secp256k1` keys are also supported.

# Requirements

Required dependencies:

- openvpn
- openssl

# Usage

`gen-server-cert.sh` needs a number of positional arguments:

```
    Usage: ./gen-server-cert.sh [options] <ca_cn> <server_cn>

        Options:
          -k    diffie-hellman parameter and rsa key size, default 2048 bits
          -l    certificate lifetimes, default 365 days
          -o    output directory, default <server_cn>
          -t    key type (rsa, secp256k1 or secp384r1), default secp384r1

    > ./gen-server-cert.sh rootCA example.com
    > ls example.com

    01.pem  ca.crt  ca.key  dh2048.pem  example.com.crt  example.com.csr  example.com.key 
    index.txt  index.txt.attr  index.txt.old  serial  serial.old  server-tlsv2.key  ta.key
```

Create client keys and certificates using `gen-client-cert.sh`: 

```
    Usage: ./gen-client-cert.sh [options] <server_directory> <client_cn>

        Options:
          -k    rsa key size, default 2048 bits
          -l    certificate lifetimes, default 365 days
          -o    output directory, default <client_cn>
          -t    key type (rsa, secp256k1 or secp384r1), default secp384r1

    > ./gen-client-cert.sh example.com client01
    > ls client01

    ca.crt  client01.crt  client01.csr  client01.key  client01-tlsv2.key    
```

See [dotfiles/openvpn/etc/openvpn](https://github.com/gnortt/dotfiles/tree/master/openvpn/etc/openvpn) for compatible OpenVPN server and client configs.
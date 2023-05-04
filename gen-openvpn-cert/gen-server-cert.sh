#!/usr/bin/env bash

set -e

usage() {
    echo "Usage: $0 [options] <ca_cn> <server_cn>

    Options:
      -k    diffie-hellman parameter and rsa key size, default 2048 bits
      -l    certificate lifetimes, default 365 days
      -o    output directory, default <server_cn>
      -t    key type (rsa, secp256k1 or secp384r1), default secp384r1"
    exit 1
}

while getopts "k:l:o:t:" flag; do
    case "$flag" in
        k)  KEY_SIZE=$OPTARG;;
        l)  DAYS=$OPTARG;;
        o)  OUT_DIR=$OPTARG;;
        t)  TYPE=$OPTARG;;
        \?) usage;;
    esac
done

shift $((OPTIND - 1))

if [ $# -le 1 ]; then
    usage
fi

CA_CN=$1
SERVER_CN=$2

: "${KEY_SIZE:=2048}"
: "${DAYS:=365}"
: "${OUT_DIR:=$SERVER_CN}"
: "${TYPE:=secp384r1}"

mkdir "$OUT_DIR"
OUT_DIR="$(pwd)/$OUT_DIR"
touch "$OUT_DIR"/index.txt

export KEY_DIR="$OUT_DIR"
export KEY_SIZE=$KEY_SIZE
export KEY_CN="$CA_CN"

case "$TYPE" in
    rsa)
        openssl genrsa -out "$OUT_DIR/ca.key" $KEY_SIZE
        openssl genrsa -out "$OUT_DIR/$SERVER_CN.key" $KEY_SIZE
        ;;
    secp384r1|secp256k1) 
        openssl ecparam -genkey -name $TYPE -noout -out "$OUT_DIR/ca.key"
        openssl ecparam -genkey -name $TYPE -noout -out "$OUT_DIR/$SERVER_CN.key"
        ;; 
    *)
        echo "Invalid key type: choose one of rsa, secp256k1 or secp384r1";
        exit 1;;
esac

openssl req \
    -config "openssl.cnf" \
    -batch \
    -nodes \
    -x509 \
    -utf8 \
    -sha384 \
    -days $DAYS \
    -new \
    -key "$OUT_DIR"/ca.key \
    -out "$OUT_DIR"/ca.crt

export KEY_CN="$SERVER_CN"

openssl req \
    -config "openssl.cnf" \
    -batch \
    -nodes \
    -extensions server \
    -utf8 \
    -sha384 \
    -new \
    -key "$OUT_DIR/$SERVER_CN.key" \
    -out "$OUT_DIR/$SERVER_CN.csr"

openssl ca \
    -config "openssl.cnf" \
    -batch \
    -notext \
    -create_serial \
    -extensions server \
    -days $DAYS \
    -in "$OUT_DIR/$SERVER_CN.csr" \
    -out "$OUT_DIR/$SERVER_CN.crt"

openssl dhparam \
    -out "$OUT_DIR/dh$KEY_SIZE.pem" $KEY_SIZE

openvpn --genkey tls-crypt "$OUT_DIR"/ta.key
openvpn --genkey tls-crypt-server "$OUT_DIR"/server-tls.key

chmod 0600 "$OUT_DIR"/*.key

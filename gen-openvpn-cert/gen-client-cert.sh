#!/usr/bin/env bash

set -e

usage() {
    echo "Usage: $0 [options] <server_directory> <client_cn>

    Options:
      -k    rsa key size, default 2048 bits
      -l    certificate lifetimes, default 365 days
      -o    output directory, default <client_cn>
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

IN_DIR=$1
CLIENT_CN=$2

: "${KEY_SIZE:=2048}"
: "${DAYS:=365}"
: "${OUT_DIR:=$CLIENT_CN}"
: "${TYPE:=secp384r1}"

mkdir "$OUT_DIR"
OUT_DIR="$(pwd)/$OUT_DIR"

export KEY_DIR="$IN_DIR"
export KEY_SIZE=$KEY_SIZE
export KEY_CN="$CLIENT_CN"

case "$TYPE" in
    rsa)    openssl genrsa -out "$OUT_DIR/$CLIENT_CN.key" $KEY_SIZE;;
    secp384r1|secp256k1) 
            openssl ecparam -genkey -name $TYPE -noout -out "$OUT_DIR/$CLIENT_CN.key";; 
    *)
        echo "Invalid key type: choose one of rsa, secp256k1 or secp384r1";
        exit 1;;
esac

openssl req \
    -config "openssl.cnf" \
    -batch \
    -nodes \
    -utf8 \
    -sha384 \
    -new \
    -key "$OUT_DIR/$CLIENT_CN.key" \
    -out "$OUT_DIR/$CLIENT_CN.csr" \

openssl ca \
    -config "openssl.cnf" \
    -batch \
    -notext \
    -days $DAYS \
    -in "$OUT_DIR/$CLIENT_CN.csr" \
    -out "$OUT_DIR/$CLIENT_CN.crt" \

#openvpn \
#    --tls-crypt "$IN_DIR"/server-tlsv2.key \
#    --genkey tls-crypt-client "$OUT_DIR/$CLIENT_CN"-tls.key

cp "$IN_DIR/ca.crt" "$OUT_DIR/"
cp "$IN_DIR/ta.key" "$OUT_DIR/ta.key"

chmod 0600 "$OUT_DIR"/*.key

#!/bin/bash

# Default Variable Declarations

DEFAULT="inline_client.conf"
FILEEXT=".ovpn"
CRT=".crt"
KEY=".key"
CA="ca.crt"
TA="ta.key"
kPath="./keys/"


#Ask for a Client name
echo "Please enter an existing Client Name:"
read NAME

echo "Please enter an Name for the output file"
read ovpnName

#1st Verify that client's Public Key Exists
if [ ! -f $kPath$NAME$CRT ]; then
   echo "[ERROR]: Client Public Key Certificate not found: $kPath$NAME$CRT"
   exit
fi
echo "Client's cert found: $kPath$NAME$CRT"

#Then, verify that there is a private key for that client
if [ ! -f $kPath$NAME$KEY ]; then
   echo "[ERROR]: Client 3des Private Key not found: $kPath$NAME$KEY"
   exit
fi
echo "Client's Private Key found: $kPath$NAME$KEY"

#Confirm the CA public key exists
if [ ! -f $kPath$CA ]; then
   echo "[ERROR]: CA Public Key not found: $kPath$CA"
   exit
fi
echo "CA public Key found: $kPath$CA"

#Confirm the tls-auth ta key file exists
if [ ! -f $kPath$TA ]; then
   echo "[ERROR]: tls-auth Key not found: $kPath$TA"
   exit
fi
echo "tls-auth Private Key found: $kPath$TA"

#Ready to make a new .opvn file - Start by populating with the

cat $DEFAULT > $ovpnName$FILEEXT

#Now, append the CA Public Cert
echo "<ca>" >> $ovpnName$FILEEXT
cat $kPath$CA | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' >> $ovpnName$FILEEXT
echo "</ca>" >> $ovpnName$FILEEXT

#Next append the client Public Cert
echo "<cert>" >> $ovpnName$FILEEXT
cat $kPath$NAME$CRT | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' >> $ovpnName$FILEEXT
echo "</cert>" >> $ovpnName$FILEEXT

#Then, append the client Private Key
echo "<key>" >> $ovpnName$FILEEXT
cat $kPath$NAME$KEY >> $ovpnName$FILEEXT
echo "</key>" >> $ovpnName$FILEEXT

#Finally, append the TA Private Key
echo "<tls-auth>" >> $ovpnName$FILEEXT
cat $kPath$TA >> $ovpnName$FILEEXT
echo "</tls-auth>" >> $ovpnName$FILEEXT

echo "Done! $ovpnName$FILEEXT Successfully Created."

#Script written by Eric Jodoin
#Update by Eric Maasdorp 2017-12-16

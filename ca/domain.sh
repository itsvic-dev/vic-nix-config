#!/usr/bin/env nix-shell
#!nix-shell -i bash -p openssl

set -eu

FQDN="$1"
MACHINE="$2"
mkdir "$FQDN" -p

openssl req -new -newkey rsa:4096 \
  -keyout "../secrets/$MACHINE/$FQDN.key" \
  -out "$FQDN/cert.csr" \
  -nodes \
  -subj "/C=PL/CN=$FQDN" \
  -addext "keyUsage = critical,digitalSignature,keyEncipherment" \
  -addext "extendedKeyUsage = serverAuth,clientAuth" \
  -addext "subjectAltName=DNS:$FQDN,DNS:*.$FQDN"

openssl x509 -req -in "$FQDN/cert.csr" \
  -CA ca-cert.pem \
  -CAkey ca-key.pem \
  -out "$FQDN/cert.pem" \
  -days 365 -sha256 \
  -copy_extensions copy

sops encrypt -i "../secrets/$MACHINE/$FQDN.key"

# rm "$FQDN/cert.csr"

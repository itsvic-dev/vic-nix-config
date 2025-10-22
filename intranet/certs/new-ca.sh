#!/usr/bin/env nix-shell
#!nix-shell -i bash -p openssl

openssl req -x509 -newkey rsa:4096 \
  -keyout ca-key.pem \
  -out ca-cert.pem \
  -sha256 \
  -days $((365*2)) \
  -nodes \
  -subj "/C=PL/L=Warsaw/O=it's vic!/OU=vic!Intranet/CN=vic!Intranet" \
  -addext "keyUsage = critical, cRLSign, digitalSignature, keyCertSign"

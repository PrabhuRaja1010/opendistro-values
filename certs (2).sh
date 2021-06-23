#!/bin/bash
mkdir certs
echo "******creating root CA **************\n"
openssl genrsa -out certs/root-ca-key.pem 2048
openssl req -new -x509 -sha256 -key certs/root-ca-key.pem -out certs/root-ca.pem -subj "/C=US/ST=Arizona/L=Phoenix/O=Amex/OU=AppSec/CN=localhost"
                                                                                                                                                                  
echo "******creating root CA **************\n"
openssl genrsa -out certs/kibana-root-ca-key.pem 2048
openssl req -new -x509 -sha256 -key certs/kibana-root-ca-key.pem -out certs/kibana-root-ca.pem -subj "/C=US/ST=Arizona/L=Phoenix/O=Amex/OU=AppSec/CN=localhost"


#admin cert

echo "******creating admin CA **************\n"
openssl genrsa -out certs/admin-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in certs/admin-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out certs/admin-key.pem
openssl req -new -key certs/admin-key.pem -out certs/admin.csr -subj "/C=US/ST=Arizona/L=Phoenix/O=Amex/OU=AppSec/CN=admin"
openssl x509 -req -in certs/admin.csr -CA certs/root-ca.pem -CAkey certs/root-ca-key.pem -CAcreateserial -sha256 -out certs/admin-crt.pem -days 720

echo "******creating NODE CA **************\n"
openssl genrsa -out certs/node-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in certs/node-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out certs/node-key.pem
openssl req -new -key certs/node-key.pem -out certs/node.csr -subj "/C=US/ST=Arizona/L=Phoenix/O=Amex/OU=AppSec/CN=localhost"
openssl x509 -req -in certs/node.csr -CA certs/root-ca.pem -CAkey certs/root-ca-key.pem -CAcreateserial -sha256 -out certs/node.pem -days 720

echo "******creating KIBANA CA **************\n"
openssl genrsa -out certs/kibana-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in certs/kibana-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out certs/kibana-key.pem
openssl req -new -key certs/kibana-key.pem -out certs/kibana.csr -subj "/C=US/ST=Arizona/L=Phoenix/O=Amex/OU=AppSec/CN=localhost"
openssl x509 -req -in certs/kibana.csr -CA certs/kibana-root-ca.pem -CAkey certs/kibana-root-ca-key.pem -CAcreateserial -sha256 -out certs/kibana-crt.pem -days 720

#Cleanup    
echo "cleaning"
rm certs/admin-key-temp.pem
rm certs/admin.csr
rm certs/node-key-temp.pem
rm certs/node.csr

cp certs/root-ca.pem certs/elk-transport-root-ca.pem
cp certs/node.pem  certs/elk-transport-crt.pem
cp certs/node-key.pem certs/elk-transport-key.pem

kubectl create secret generic -n default trans1-secret --from-file=certs/elk-transport-root-ca.pem --from-file=certs/elk-transport-crt.pem --from-file=certs/elk-transport-key.pem

cp certs/root-ca.pem certs/elk-rest-root-ca.pem
cp certs/node.pem  certs/elk-rest-crt.pem
cp certs/node-key.pem certs/elk-rest-key.pem
 
kubectl create secret generic -n default rest1-secret --from-file=certs/elk-rest-root-ca.pem --from-file=certs/elk-rest-crt.pem --from-file=certs/elk-rest-key.pem

cp certs/root-ca.pem certs/admin-root-ca.pem

kubectl create secret generic -n default admin1-secret --from-file=certs/admin-crt.pem --from-file=certs/admin-key.pem --from-file=certs/admin-root-ca.pem

#cp certs/root-ca.pem certs/kibana-root-ca.pem
#cp certs/node.pem  certs/kibana-crt.pem
#cp certs/node-key.pem certs/kibana-key.pem

kubectl create secret generic -n default kibana1-secret --from-file=certs/kibana-crt.pem --from-file=certs/kibana-key.pem --from-file=certs/kibana-root-ca.pem

kubectl create secret generic -n default kibanarest1-secret --from-file=certs/elk-rest-root-ca.pem --from-file=certs/elk-rest-crt.pem --from-file=certs/elk-rest-key.pem



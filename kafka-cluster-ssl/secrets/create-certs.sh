#!/bin/bash

set -o nounset \
    -o errexit \
    -o verbose \
    -o xtrace

# Generate CA key
openssl req -new -x509 -keyout snakeoil-ca-1.key -out snakeoil-ca-1.crt -days 9999 -subj '/CN=ca1.test.gpswv.com/OU=WW/O=WW/L=Shanghai/S=Sh/C=CN' -passin pass:7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW -passout pass:7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW
# openssl req -new -x509 -keyout snakeoil-ca-2.key -out snakeoil-ca-2.crt -days 9999 -subj '/CN=ca1.test.gpswv.com/OU=WW/O=WW/L=Shanghai/S=Sh/C=CN' -passin pass:7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW -passout pass:7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW

# Kafkacat
openssl genrsa -des3 -passout "pass:7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW" -out kafkacat.client.key 1024
openssl req -passin "pass:7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW" -passout "pass:7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW" -key kafkacat.client.key -new -out kafkacat.client.req -subj '/CN=kafkacat.test.gpswv.com/OU=WW/O=WW/L=Shanghai/S=Sh/C=CN'
openssl x509 -req -CA snakeoil-ca-1.crt -CAkey snakeoil-ca-1.key -in kafkacat.client.req -out kafkacat-ca1-signed.pem -days 9999 -CAcreateserial -passin "pass:7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW"



for i in broker1 broker2 broker3 producer consumer
do
	echo $i
	# Create keystores
	keytool -genkey -noprompt \
				 -alias $i \
				 -dname "CN=$i.test.gpswv.com, OU=WW, O=WW, L=Shanghai, S=Sh, C=CN" \
				 -keystore kafka.$i.keystore.jks \
				 -keyalg RSA \
				 -storepass 7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW \
				 -keypass 7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW

	# Create CSR, sign the key and import back into keystore
	keytool -keystore kafka.$i.keystore.jks -alias $i -certreq -file $i.csr -storepass 7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW -keypass 7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW

	openssl x509 -req -CA snakeoil-ca-1.crt -CAkey snakeoil-ca-1.key -in $i.csr -out $i-ca1-signed.crt -days 9999 -CAcreateserial -passin pass:7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW

	keytool -keystore kafka.$i.keystore.jks -alias CARoot -import -file snakeoil-ca-1.crt -storepass 7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW -keypass 7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW

	keytool -keystore kafka.$i.keystore.jks -alias $i -import -file $i-ca1-signed.crt -storepass 7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW -keypass 7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW

	# Create truststore and import the CA cert.
	keytool -keystore kafka.$i.truststore.jks -alias CARoot -import -file snakeoil-ca-1.crt -storepass 7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW -keypass 7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW

  echo "7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW" > ${i}_sslkey_creds
  echo "7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW" > ${i}_keystore_creds
  echo "7WjCvXcv@!trK@2jPUr@H%RhqkdO3OoW" > ${i}_truststore_creds
done

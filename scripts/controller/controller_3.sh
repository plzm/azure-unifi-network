#!/bin/bash

touch ~/controller_3.txt

# CONFIGURATION OPTIONS
UNIFI_HOSTNAME={{VM_FQDN}}

UNIFI_SERVICE=unifi
UNIFI_DIR=/var/lib/unifi
JAVA_DIR=/usr/lib/unifi
KEYSTORE=${UNIFI_DIR}/keystore
LE_MODE=true
LE_LIVE_DIR=/etc/letsencrypt/live
ALIAS=unifi
PASSWORD=aircontrolenterprise

PRIV_KEY=${LE_LIVE_DIR}/${UNIFI_HOSTNAME}/privkey.pem
CHAIN_FILE=${LE_LIVE_DIR}/${UNIFI_HOSTNAME}/fullchain.pem
P12_TEMP=$(mktemp)

printf "\nStarting UniFi Controller SSL Import...\n"

printf "\nInspecting current SSL certificate...\n"
if md5sum -c "${LE_LIVE_DIR}/${UNIFI_HOSTNAME}/privkey.pem.md5" &>/dev/null; then
  # MD5 remains unchanged, exit the script
  printf "\nCertificate is unchanged, no update is necessary.\n"
  exit 0
else
  # MD5 is different, so it's time to get busy!
  printf "\nUpdated SSL certificate available. Proceeding with import...\n"
fi


echo "Debug: listing required files"
ls -la ${PRIV_KEY}
ls -la ${CHAIN_FILE}

# Verify required files exist
if (! test -e ${PRIV_KEY}) || (! test -e ${CHAIN_FILE}); then
  printf "\nMissing one or more required files. Check your settings.\n"
  exit 1
else
  # Everything looks OK to proceed
  printf "\nImporting the following files:\n"
  printf "Private Key: %s\n" "$PRIV_KEY"
  printf "CA File: %s\n" "$CHAIN_FILE"
fi

# Stop the UniFi Controller
printf "\nStopping UniFi Controller...\n"
systemctl stop "${UNIFI_SERVICE}"

# Write a new MD5 checksum based on the updated certificate	
printf "\nUpdating certificate MD5 checksum...\n"

MD5SUM=$(sudo md5sum "${PRIV_KEY}")
CMD="echo ${MD5SUM} >> ~/privkey.pem.md5"
eval $CMD
CMD="mv ~/privkey.pem.md5 ${LE_LIVE_DIR}/${UNIFI_HOSTNAME}/privkey.pem.md5"
eval $CMD

# Create double-safe keystore backup
if (test -e $KEYSTORE.orig); then
  printf "\nBackup of original keystore exists!\n"
  printf "\nCreating non-destructive backup as keystore.bak...\n"
  CMD="cp ${KEYSTORE} ${KEYSTORE}.bak"
  eval $CMD
else
  printf "\nNo original keystore backup found.\n"
  printf "\nCreating backup as keystore.orig...\n"
  CMD="cp ${KEYSTORE} ${KEYSTORE}.orig"
  eval $CMD
fi

# Export your existing SSL key, cert, and CA data to a PKCS12 file
printf "\nExporting SSL certificate and key data into temporary PKCS12 file...\n"

# sudo?
CMD="openssl pkcs12 -export -in ${CHAIN_FILE} -inkey ${PRIV_KEY} -out ${P12_TEMP} -passout pass:${PASSWORD} -name ${ALIAS}"
eval $CMD
CMD="chmod 744 ${P12_TEMP}"
eval $CMD

# Delete the previous certificate data from keystore to avoid "already exists" message
printf "\nRemoving previous certificate data from UniFi keystore...\n"
keytool -delete -alias "${ALIAS}" -keystore "${KEYSTORE}" -deststorepass "${PASSWORD}"

# Import the temp PKCS12 file into the UniFi keystore
printf "\nImporting SSL certificate into UniFi keystore...\n"
CMD="keytool -importkeystore \
-srckeystore ${P12_TEMP} \
-srcstoretype PKCS12 \
-srcstorepass ${PASSWORD} \
-destkeystore ${KEYSTORE} \
-deststorepass ${PASSWORD} \
-destkeypass ${PASSWORD} \
-alias ${ALIAS} \
-trustcacerts"
eval $CMD

# Clean up temp files
printf "\nRemoving temporary files...\n"
CMD="rm -f ${P12_TEMP}"
eval $CMD

# Restart the UniFi Controller to pick up the updated keystore
printf "\nRestarting UniFi Controller to apply new Let's Encrypt SSL certificate...\n"
systemctl restart "${UNIFI_SERVICE}"

# That's all, folks!
printf "\nDone!\n"

exit 0

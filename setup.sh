#!/bin/bash

GPGTEMPDIR=`mktemp -d`

if [ ${#} -gt 0 ]
then
	KEYID="${1}"
else
	KEYID="temp"
fi

### Prompts for password
### This is to encrypt the private key in the temporary directory.
gpg --homedir="${GPGTEMPDIR}" --trustdb-name="${KEYID}" --no-default-keyring --pinentry-mode=loopback --yes --quick-gen-key "${KEYID}"
gpg --homedir="${GPGTEMPDIR}" --trustdb-name="${KEYID}" --no-default-keyring --pinentry-mode=loopback --export -o "${KEYID}".pubkey
### Prompts for password
### This is to decrypt the private key in the temporary directory.  Not clear whether it encrypts the private key exported also?
### WARNING: For some reason if the user does not respond with the correct password to the first prompt, this fails to work properly?
###   Needs testing!!!
gpg --homedir="${GPGTEMPDIR}" --trustdb-name="${KEYID}" --no-default-keyring --pinentry-mode=loopback --export-secret-keys -o "${KEYID}".privkey
rm -rf "${GPGTEMPDIR}"

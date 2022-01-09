#!/bin/bash

if [ ${#} -ne 1 ]
then
	echo "Wrong # arguments.  FIXME"
	exit 1
fi

GPGTEMPDIR=`mktemp -d`
KEYID="${1}"

### Prompts for password
### This is to encrypt the private key in the temporary directory.
echo "Generating public and private key pair.  You will need to enter a password for gpg to protect it on-disk temporarily"
gpg --homedir="${GPGTEMPDIR}" --trustdb-name="${KEYID}" --no-default-keyring --pinentry-mode=loopback --yes --quick-gen-key "${KEYID}"
gpg --homedir="${GPGTEMPDIR}" --trustdb-name="${KEYID}" --no-default-keyring --pinentry-mode=loopback --export -o "${KEYID}".pubkey
### Prompts for password
### This is to decrypt the private key in the temporary directory.  Not clear whether it encrypts the private key exported also?
### WARNING: For some reason if the user does not respond with the correct password to the first prompt, this fails to work properly?
###   Needs testing!!!
echo
echo "Exporting private key.  You will need to enter a password for gpg to export"
echo "the key from the temporary local keyring.  If you don't enter the correct"
echo "password the second time and are propmted again, the private key generation"
echo "probably failed."
echo
gpg --homedir="${GPGTEMPDIR}" --trustdb-name="${KEYID}" --no-default-keyring --pinentry-mode=loopback --export-secret-keys -o "${KEYID}".privkey
rm -rf "${GPGTEMPDIR}"

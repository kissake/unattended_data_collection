#!/bin/bash

GPGTEMPDIR=`mktemp -d`
KEYID="temp"

if [ ${#} -eq 0 ]
then
	echo "Usage: ${0} FILENAME [FILENAME]..."
	echo "Decrypt the files passed on the commandline (filenames ending in .gpg) using ${KEYID}.privkey."
	echo
	exit 1 ### Error: incorrect number of arguments.
fi

### if [ ${#} -gt 0 ]
### then
	### KEYID="${1}"
### else
	### KEYID="temp"
### fi

gpg --homedir="${GPGTEMPDIR}" --trustdb-name="${KEYID}" --no-default-keyring --pinentry-mode=loopback --import "${KEYID}".privkey
gpg --homedir="${GPGTEMPDIR}" --trustdb-name="${KEYID}" --no-default-keyring --pinentry-mode=loopback --decrypt-files -r "${KEYID}" "${@}"
rm -rf "${GPGTEMPDIR}"


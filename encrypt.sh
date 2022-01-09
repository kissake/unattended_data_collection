#!/bin/bash

GPGTEMPDIR=`mktemp -d`
KEYID="temp"

if [ ${#} -eq 0 ] || [ ${#} -gt 1 ]
then
	echo "Usage: ${0} FILENAME"
	echo "Take data on stdin and encrypt it using ${KEYID}.pubkey. to the filename provided on the commandline."
	echo
	exit 1 ### Error: incorrect number of arguments.
fi
	### KEYID="${1}"
### else
	### KEYID="temp"
### fi

OUTPUTFILE="${1}"

rm -rf "${GPGTEMPDIR}" ; mkdir "${GPGTEMPDIR}" ; chmod 700 "${GPGTEMPDIR}"
gpg --homedir="${GPGTEMPDIR}" --trustdb-name="${KEYID}" --no-default-keyring --pinentry-mode=loopback --import "${KEYID}".pubkey
gpg --homedir="${GPGTEMPDIR}" --trustdb-name="${KEYID}" --no-default-keyring --pinentry-mode=loopback --always-trust --encrypt -r "${KEYID}" -o "${OUTPUTFILE}"
rm -rf "${GPGTEMPDIR}"


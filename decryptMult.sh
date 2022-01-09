#!/bin/bash

if [ ${#} -lt 2 ]
then
	echo "Usage: ${0} KEYID FILENAME [FILENAME]..."
	echo "Decrypt the files passed on the commandline (filenames ending in .gpg) using ${KEYID}.privkey."
	echo
	exit 1 ### Error: incorrect number of arguments.
fi

GPGTEMPDIR=`mktemp -d`

# First argument is the identifier for the key.  Once collected, shift it away;
# remaining arguments are files to decrypt.
KEYID="${1}"
shift

gpg --homedir="${GPGTEMPDIR}" --trustdb-name="${KEYID}" --no-default-keyring --pinentry-mode=loopback --import "${KEYID}".privkey
gpg --homedir="${GPGTEMPDIR}" --trustdb-name="${KEYID}" --no-default-keyring --pinentry-mode=loopback --decrypt-files -r "${KEYID}" "${@}"
rm -rf "${GPGTEMPDIR}"


#!/bin/bash

GPGTEMPDIR=`mktemp -d`
KEYID="temp"

### if [ ${#} -gt 0 ]
### then
	### KEYID="${1}"
### else
	### KEYID="temp"
### fi

gpg --homedir="${GPGTEMPDIR}" --trustdb-name="${KEYID}" --no-default-keyring --pinentry-mode=loopback --import "${KEYID}".privkey
gpg --homedir="${GPGTEMPDIR}" --trustdb-name="${KEYID}" --no-default-keyring --pinentry-mode=loopback --decrypt-files -r "${KEYID}" "${@}"
rm -rf "${GPGTEMPDIR}"


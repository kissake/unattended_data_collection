#!/bin/bash

GPGTEMPDIR=tempdir/
KEYID=temp
OUTPUTFILE="${1}"

rm -rf "${GPGTEMPDIR}" ; mkdir "${GPGTEMPDIR}" ; chmod 700 "${GPGTEMPDIR}"
gpg --homedir="${GPGTEMPDIR}" --trustdb-name="${KEYID}" --no-default-keyring --pinentry-mode=loopback --import "${KEYID}".pubkey
gpg --homedir="${GPGTEMPDIR}" --trustdb-name="${KEYID}" --no-default-keyring --pinentry-mode=loopback --always-trust --encrypt -r "${KEYID}" -o "${OUTPUTFILE}"
rm -rf "${GPGTEMPDIR}"


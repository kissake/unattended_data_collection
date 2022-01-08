#!/bin/bash

GPGTEMPDIR=tempdir/
KEYID=temp

rm -rf "${GPGTEMPDIR}" ; mkdir "${GPGTEMPDIR}" ; chmod 700 "${GPGTEMPDIR}"
gpg --homedir="${GPGTEMPDIR}" --trustdb-name="${KEYID}" --no-default-keyring --pinentry-mode=loopback --import "${KEYID}".privkey
gpg --homedir="${GPGTEMPDIR}" --trustdb-name="${KEYID}" --no-default-keyring --pinentry-mode=loopback --decrypt-files -r "${KEYID}" "${@}"
rm -rf "${GPGTEMPDIR}"


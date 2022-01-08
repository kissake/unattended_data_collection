#!/bin/bash

GPGTEMPDIR=tempdir/
KEYID=temp

rm -rf "${GPGTEMPDIR}" ; mkdir "${GPGTEMPDIR}" ; chmod 700 "${GPGTEMPDIR}"
gpg --homedir="${GPGTEMPDIR}" --trustdb-name="${KEYID}" --no-default-keyring --pinentry-mode=loopback --yes --quick-gen-key "${KEYID}"
gpg --homedir="${GPGTEMPDIR}" --trustdb-name="${KEYID}" --no-default-keyring --pinentry-mode=loopback --export -o "${KEYID}".pubkey
gpg --homedir="${GPGTEMPDIR}" --trustdb-name="${KEYID}" --no-default-keyring --pinentry-mode=loopback --export-secret-keys -o "${KEYID}".privkey
rm -rf "${GPGTEMPDIR}"


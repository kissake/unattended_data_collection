#!/bin/bash

INSTALLHOST="${1}"

DEFAULTKEYID="audio"
CRONTAB=crontab

INSTALLFILES="RecordMp3.sh encrypt.sh ${DEFAULTKEYID}.pubkey ${CRONTAB} autoExport.sh CleanupOldWAVs.sh lighttpd.conf"

if [ ! -f "${DEFAULTKEYID}.pubkey" -o ! -f "${DEFAULTKEYID}.privkey" ]
then
	# If the public and private keys aren't generated yet, generate them
	./setup.sh "${DEFAULTKEYID}"
fi

tar -czf install.tgz ${INSTALLFILES}

scp install.tgz ${INSTALLHOST}:
ssh ${INSTALLHOST} "tar -xzf install.tgz && crontab ${CRONTAB}"

#!/bin/bash

# Copyright (C) 2015-2018 Fortishield, Inc. All rights reserved.
# Fortishield.com
# This program is a free software; you can redistribute it
# and/or modify it under the terms of the GNU General Public
# License (version 2) as published by the FSF - Free Software
# Foundation.

# Installer for Fortishield API daemon
# Fortishield Inc.


I_OWNER="root"
I_GROUP="root"
I_XMODE="755"
I_FMODE="644"
I_SYSTEMD="/etc/systemd/system"
I_SYSVINIT="/etc/init.d"

OSSEC_CONF="/etc/ossec-init.conf"
DEF_OSSDIR="/var/ossec"

# Test root permissions

if [ "$EUID" -ne 0 ]; then
    echo "Warning: Please run this script with root permissions."
fi

# Directory where OSSEC is installed

if ! [ -f $OSSEC_CONF ]; then
    echo "Can't find $OSSEC_CONF. Is OSSEC installed?"
    exit 1
fi

. $OSSEC_CONF

if [ -z "$DIRECTORY" ]; then
    DIRECTORY=$DEF_OSSDIR
fi

APP_PATH="${DIRECTORY}/api/app.js"
SCRIPTS_PATH="${DIRECTORY}/api/scripts"

if ! [ -f $APP_PATH ]; then
    echo "Can't find $APP_PATH. Is Fortishield API installed?"
    exit 1
fi

# Binary name for NodeJS

BIN_DIR=$(command -v nodejs 2> /dev/null)

if [ "X$BIN_DIR" = "X" ]; then
    BIN_DIR=$(command -v node 2> /dev/null)

    if [ "X$BIN_DIR" = "X" ]; then
        echo "NodeJS binaries not found. Is NodeJS installed?"
        exit 1
    fi
fi

# Install for systemd

if command -v systemctl > /dev/null 2>&1 && systemctl > /dev/null 2>&1; then
    echo "Installing for systemd"

    sed "s:^ExecStart=.*:ExecStart=$BIN_DIR $APP_PATH:g" $SCRIPTS_PATH/fortishield-api.service > $SCRIPTS_PATH/fortishield-api.service.tmp
    install -m $I_FMODE -o $I_OWNER -g $I_GROUP $SCRIPTS_PATH/fortishield-api.service.tmp $I_SYSTEMD/fortishield-api.service
    rm $SCRIPTS_PATH/fortishield-api.service.tmp
    systemctl daemon-reload
    systemctl enable fortishield-api
    systemctl restart fortishield-api


# Install for SysVinit / Upstart

elif command -v service > /dev/null 2>&1; then
    echo "Installing for SysVinit"

    sed "s:^BIN_DIR=.*:BIN_DIR=\"$BIN_DIR\":g" $SCRIPTS_PATH/fortishield-api > $SCRIPTS_PATH/fortishield-api.tmp
    sed -i "s:^APP_PATH=.*:APP_PATH=\"$APP_PATH\":g" $SCRIPTS_PATH/fortishield-api.tmp
    sed -i "s:^OSSEC_PATH=.*:OSSEC_PATH=\"${DIRECTORY}\":g" $SCRIPTS_PATH/fortishield-api.tmp
    install -m $I_XMODE -o $I_OWNER -g $I_GROUP $SCRIPTS_PATH/fortishield-api.tmp $I_SYSVINIT/fortishield-api
    rm $SCRIPTS_PATH/fortishield-api.tmp

    enabled=true
    if command -v chkconfig > /dev/null 2>&1; then
        /sbin/chkconfig --add fortishield-api > /dev/null 2>&1
    elif [ -f "/usr/sbin/update-rc.d" ] || [ -n "$(ps -e | egrep upstart)" ]; then
        update-rc.d fortishield-api defaults
    elif [ -r "/etc/gentoo-release" ]; then
        rc-update add fortishield-api default
    else
        echo "init script installed in $I_SYSVINIT/fortishield-api"
        echo "We could not enable it. Please enable the service manually."
        enabled=false
    fi

    if [ "$enabled" = true ]; then
        service fortishield-api restart
    fi
else
    echo "Warning: Unknown init system. Please run the API with:"
    echo "$BIN_DIR $APP_PATH > /dev/null 2>&1 < /dev/null &"
fi

#!/bin/sh

opkg remove uhttpd --force-removal-of-dependent-packages
rm /etc/uci-defaults/99-remove-uhttpd.sh
exit 0

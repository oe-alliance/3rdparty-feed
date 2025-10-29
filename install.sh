#!/bin/bash

export D=${D}

rm $D/etc/opkg/oe-alliance-3rdparty-feed.conf >/dev/null 2>&1 || true
echo src/gz oe-alliance-3rdparty-feed https://raw.githubusercontent.com/oe-alliance/3rdparty-feed/gh-pages > $D/etc/opkg/oe-alliance-3rdparty-feed.conf
opkg update
echo " "
echo "oe-alliance-3rdparty-feed succesfully installed"
echo " "
exit 0
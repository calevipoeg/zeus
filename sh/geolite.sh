#!/bin/bash

# export MAXMIND_KEY=foo
# bin/geolite.sh ./tmp

if [ -z "$MAXMIND_KEY" ]
then
  echo "MAXMIND_KEY is undefined"
  exit
fi

DESTINATION=$1
TMP_DIR=$(mktemp -d -t maxmind)

cd $TMP_DIR
wget "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=$MAXMIND_KEY&suffix=tar.gz" -O ./GeoLite2-City.tar.gz
tar --strip=1 -zxvf GeoLite2-City.tar.gz `tar -tzf GeoLite2-City.tar.gz | grep GeoLite2-City.mmdb`
cd -
mv $TMP_DIR/GeoLite2-City.mmdb $DESTINATION/

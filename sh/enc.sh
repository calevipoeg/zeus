#!/bin/bash
# @example:
#   bin/enc.sh .env.production password
#   bin/enc.sh .env.production $(cat gpg.key | xargs)
echo $2 | gpg --batch --yes --passphrase-fd 0 -c $1

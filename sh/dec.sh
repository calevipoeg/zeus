#!/bin/bash
# @example:
#   bin/dec.sh .env.production.gpg password
#   bin/dec.sh .env.production.gpg $(cat gpg.key | xargs)
echo $2 | gpg --batch --yes --passphrase-fd 0 $1

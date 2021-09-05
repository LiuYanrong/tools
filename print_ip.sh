#!/bin/bash

curl icanhazip.com || curl ident.me 2&>/dev/null | xargs | sed 's/#//g' \
    || curl whatismyip.akamai.com 2&>/dev/null | xargs | sed 's/#//g' \
    || curl myip.dnsomatic.com 2&>/dev/null | xargs | sed 's/#//g'

# or1. curl ident.me 2&>/dev/null | xargs | sed 's/#//g'
# or2. curl whatismyip.akamai.com 2&>/dev/null | xargs | sed 's/#//g'
# or3. curl myip.dnsomatic.com 2&>/dev/null | xargs | sed 's/#//g'

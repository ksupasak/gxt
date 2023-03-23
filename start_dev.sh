#!/bin/sh
bundle exec thin start --ssl --port 1792 --ssl-disable-verify --ssl-key-file private.key --ssl-cert-file server.crt

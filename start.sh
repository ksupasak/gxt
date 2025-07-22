#!/bin/sh
rerun "bundle exec thin start --ssl --port 1792 --ssl-disable-verify"

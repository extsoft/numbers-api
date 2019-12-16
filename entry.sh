#!/usr/bin/env sh
cat <<MESSAGE
Current environment
===================
$(env)

Running "thenumbers"
====================
MESSAGE
exec python -m thenumbers

#!/usr/bin/env bash
set -e

#Required for using non-ancient sqlite on mac with homebrew:
export PATH="/usr/local/opt/sqlite/bin:$PATH"

sqlite3 < day3b.sql
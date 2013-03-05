#!/bin/sh

# call with a commit range as argument
#

set -e

Q="${0%/*}/queue"
C="${0%/*}/current"

cat /dev/null > $C
cat /dev/null > $Q.done
git rev-list "$@" | tac > $Q

exec ${0%/*}/re_next.sh

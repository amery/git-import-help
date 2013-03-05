#!/bin/sh

. "${0%/*}/common.in"

C="$BASE/x_file.sh"

set -e
[ $# -gt 0 ] || set -- .
for d; do
	git ls -omz "$d" | xargs -r0 -- "$C"
	git ls -iz --exclude-standard "$d" | xargs -r0 -- "$C"
	git ls -dz "$d" | xargs -r0 git rm
done

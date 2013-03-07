#!/bin/sh

. "${0%/*}/common.in"

C="$BASE/x_file.sh"

set -e
[ $# -gt 0 ] || set -- .
for d; do
	git ls-files -omz "$d" | xargs -r0 -- "$C"
	git ls-files -iz --exclude-standard "$d" | xargs -r0 -- "$C"
	git ls-files -dz "$d" | xargs -r0 git rm
done

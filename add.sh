#!/bin/sh

err() {
	echo "$@" >&2
}

B="${0%/*}"

[ $# -gt 0 ] || set -- .

set -e
for d; do
	git ls-files -omiz --exclude-standard "$d" |
		xargs -r0 git add -f --
	git ls-files -dz "$d" |
		xargs -r0 git rm
done

exec git status --porcelain "$@"

#!/bin/sh

err() {
	echo "$@" >&2
}

B="${0%/*}"

[ $# -gt 0 ] || set -- .

set -e
for d; do
	(git ls -iz --exclude-standard "$d"; git ls -omz "$d") |
		xargs -r0 git add -f --
	git ls -dz "$d" |
		xargs -r0 git rm
done

exec git st --porcelain "$@"

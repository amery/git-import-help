#!/bin/sh

. "${0%/*}/common.in"

set -e
P="$BASE/x.$$.patch"
for f; do
	[ ! -L "$f" -a -f "$f" ] || continue

	git status --porcelain -- "$f"
	"$BASE/sanitize_file.sh" "$f"

	if [ -n "$(textfile "$f")" ]; then
		git add -f "$f"
		git diff HEAD -- "$f" > "$P"
		[ -s "$P" ] || continue

		git reset -q HEAD -- "$f"
		st="$(git status --ignored --porcelain -- "$f" | cut -c1-2)"
		if [ "$st" = "??" -o "$st" = "!!" ]; then
			rm -- "$f"
		else
			git checkout -- "$f"
		fi
		git apply --whitespace=fix < "$P"
		rm -f "$P"
	fi
	git add -f "$f"
done

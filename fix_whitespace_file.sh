#!/bin/sh

. "${0%/*}/common.in"

P="$BASE/whitespace_fix.diff"

set -e
whitespace_fix() {
	local f= st=
	for f; do
		git status --porcelain -- "$f"

#		whitespace "$f"
		git add -f "$f"
		git diff HEAD -- "$f" > "$P"
		[ -s "$P" ] || continue

		git reset -q HEAD -- "$f"
		st="$(git status --ignored --porcelain -- "$f" | cut -c1-2)"
		if [ "$st" = "??" -o "$st" = "!!" ]; then
			rm -- "$f"
		else
			git co -- "$f"
		fi
		git apply --whitespace=fix < "$P"
		rm -f "$P"
		git add -f "$f"
	done
}

for f; do
	resetmode=
	s="$(git status --ignored --porcelain -- "$f" | cut -c1-2)"
	case "$s" in
	D\ )
		continue
		;;
	MM|M\ )
		resetmode=yes
		;;
	A\ |AM|\?\?)
		;;
#	R)	f="$f2"
#		;;
	*)	err "E: s:$s f:$f x:$x f2:$f2"
		false
		continue
		;;
	esac
	git reset -q HEAD -- "$f"
	if [ "$resetmode" = yes ]; then
		mode=$(git diff HEAD -- "$f" | sed -n 's/^old mode 1\(.*\)/\1/p; /^---/Q;')
		[ -z "$mode" ] || chmod "0$mode" "$f"
	fi

	[ -z "$(textfile "$f")" ] || whitespace_fix "$f"
	git add -f "$f"
done
echo "Done."

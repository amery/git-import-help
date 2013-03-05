#!/bin/sh

set -e
Q="${0%/*}/queue"
C="${0%/*}/current"

REF=$(cd "${0%/*}/reconstruct-ref"; pwd -P)

dirt() {
	git ls -io --exclude-standard
	git ls -m -o -d
}

if [ -s "$C" -a "$(git status --porcelain | wc -l)" -gt 0 ]; then
	read c < "$C"
	echo "current: $c"
	if [ "$(dirt | wc -l)" -gt 0 ]; then
		dirt | sort -u | while read f; do
			git st --ignored --porcelain -- "$f"
		done
		exit
	else
		git ci -C "$c"
	fi
fi

# take next
head -n1 "$Q" > "$C"
read c < "$C"
echo "next: $c queue:$(wc -l $Q | cut -d' ' -f1)"

# and remove it from queue
tail -n+2 "$Q" > "$Q~"
mv "$Q~" "$Q"

(
cd "$REF"
git reset --hard "$c" >&2
git show --pretty="format:" --name-only "$c" | sed '/^$/d;'
) | while read f; do
	d="./$f"
	d=${d%/*}
	mkdir -p "$d"
	if [ -L "$REF/$f" ]; then
		fl=$(readlink "$REF/$f")
		rm -rf "$f"
		ln -snf "$fl" "$f"
		git add -f "$f"
	elif [ -e "$REF/$f" ]; then
		rm -rf "$f"
		cp "$REF/$f" "$f"
		git add -f "$f"
		case "$f" in
		*sun?i*)	force="-f" ;;
		*)		force=
		esac
		"${0%/*}/sanitize_file.sh" $force "$f"
	else
		rm -f "$f"
		git rm --ignore-unmatch -q -f "$f"
	fi
done

git ls -d | xargs -r git rm -q --
git ls -m -o | xargs -r git add -f --
"${0%/*}/fix_whitespace_st.sh"
#git st
exec "${0%/*}/re_next.sh"

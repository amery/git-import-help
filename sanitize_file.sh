#!/bin/sh

. "${0%/*}/common.in"

set -e

utf8() {
	local enc="$1" f="$2"

	rm -f "$f~"
	if iconv -f "$enc" -t "utf8" -o "$f~" "$f" 2> /dev/null; then
		if [ -s "$f~" ]; then
			echo "iconv: $f: $enc -> UTF-8"
			mv "$f~" "$f"
			return 0
		fi
	fi
	# echo "E: iconv: $f: not $enc!" >&2
	rm -f "$f~"
	return 1
}

sanitize_text_file() {
	local f="$f" ok=
	local enc=$(file --mime-encoding "$f" | cut -d: -f2 | cut -c2-) enca=

	cp "$f" "$f.orig"

	# encoding
	case "$enc" in
	us-ascii|utf-8) ;;
	*)
		enca=$(enca -L zh -i -- "$f") || true
		case "$enca" in
		GBK|BIG5)
			utf8 "$enca" "$f"
			;;
		*)
			ok=
			for x in GBK GB18030 GB2312; do
				if utf8 "$x" "$f"; then
					ok=1; break;
				fi
			done
			if [ -z "$ok" ]; then
				err "E: $f: unrecognized ($enc:$enca)"
			fi
		;;
		esac
	esac

	fromdos "$f"
	if $force || ! cmp "$f" "$f.orig" > /dev/null; then
		sed -i 's,[ \t]\+$,,' "$f"
	fi
	rm "$f.orig"
}

sanitize() {
	local f="$1"
	if [ -L "$f" -o ! -e "$f" ]; then
		return
	fi

	case "$f" in
	build*.sh|*/build*.sh)
		chmod 0755 "$f" ;;
	*)
		chmod 0644 "$f" ;;
	esac

	if [ -n "$(textfile "$f")" ]; then
		sanitize_text_file  "$f"
	else
		type="$(file -i "$f" | cut -d: -f2 | cut -c2-)"
		err "E: $f: $type"
	fi
}

if [ "x$1" = "x-f" ]; then
	force=true
	shift
else
	force=false
fi
if [ $# -eq 0 ]; then
	while read f; do
		sanitize "$f"
	done
else
	for f; do
		sanitize "$f"
	done
fi

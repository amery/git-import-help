#!/bin/sh

D="${0%/*}/undo.diff"
DW="${0%/*}/undo_w.diff"

set -e
git status --ignored --porcelain -- "$@"
git diff HEAD -- "$@" > "$D"
git diff -w HEAD -- "$@" > "$DW"

git reset -q HEAD -- "$@"
git checkout -- "$@"

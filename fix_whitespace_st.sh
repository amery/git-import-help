#!/bin/sh

git diff-index --name-only -z HEAD -- "$@" | xargs -r0 "${0%/*}/fix_whitespace_file.sh"

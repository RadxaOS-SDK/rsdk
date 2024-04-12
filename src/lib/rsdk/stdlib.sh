#!/usr/bin/env bash

printf_array() {
	local FORMAT="$1"
	shift
	local ARRAY=("$@")

	if [[ $FORMAT == "json" ]]; then
		jq --compact-output --null-input '$ARGS.positional' --args -- "${ARRAY[@]}"
	else
		for i in "${ARRAY[@]}"; do
			# shellcheck disable=SC2059
			printf "$FORMAT" "$i"
		done
	fi
}

in_array() {
	local item="$1"
	shift
	[[ $* =~ $item ]]
}

array_remove() {
	local array_name="$1" item="$2" old_array=() new_array=()
	eval "old_array=( \"\${${array_name}[@]}\" )"
	for i in "${!old_array[@]}"; do
		if [[ $item != "${old_array[i]}" ]]; then
			new_array+=("${old_array[i]}")
		fi
	done
	eval "$array_name=( \"\${new_array[@]}\" )"
}

request_parallel() {
	local nproc
	nproc=$(($(nproc)))

	while (($(jobs -r | wc -l) > nproc)); do
		sleep 0.1
	done
}

wait_parallel() {
	# An error aware wait
	# Subshell inherits set -e so they will report error code correctly
	# https://stackoverflow.com/a/43776775
	while true; do
		wait -n || {
			local code="$?"
			([[ $code == "127" ]] && exit 0 || exit "$code")
			break
		}
	done
}

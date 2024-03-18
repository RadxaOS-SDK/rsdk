#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob

LC_ALL="C.UTF-8"
LANG="C.UTF-8"
LANGUAGE="C.UTF-8"

EXIT_SUCCESS=0
EXIT_UNKNOWN_OPTION=1
EXIT_TOO_FEW_ARGUMENTS=2
EXIT_UNSUPPORTED_OPTION=3
EXIT_SUDO_PERMISSION=4
EXIT_SHRINK_NO_ROOTDEV=5
EXIT_DEV_SHM_TOO_SMALL=6
EXIT_RUNNING_AS_ROOT=7
EXIT_MISSING_SUBCOMMAND=8
EXIT_FILE_NOT_EXIST=9
EXIT_AUTHENTICATION_FAILED=10

error() {
	case "$1" in
	"$EXIT_SUCCESS") ;;
	"$EXIT_UNKNOWN_OPTION")
		echo "Unknown option: '$2'." >&2
		;;
	"$EXIT_TOO_FEW_ARGUMENTS")
		echo "Too few arguments." >&2
		;;
	"$EXIT_UNSUPPORTED_OPTION")
		echo "Option '$2' is not supported." >&2
		;;
	"$EXIT_SUDO_PERMISSION")
		echo "'$2' requires either passwordless sudo, or running in an interactive shell." >&2
		;;
	"$EXIT_SHRINK_NO_ROOTDEV")
		echo "Unable to access loop device '$2' for shrinking." >&2
		;;
	"$EXIT_DEV_SHM_TOO_SMALL")
		echo "Your /dev/shm is too small. Current '$2', require '$3'." >&2
		;;
	"$EXIT_RUNNING_AS_ROOT")
		cat <<EOF >&2
You are running $(basename "$0") with root permission, which is not recommended for normal development.
If you need root permission to run docker, please add your account to docker group, reboot, and try again.
EOF
		;;
	"$EXIT_MISSING_SUBCOMMAND")
		echo "'$2' is not a valid subcommand." >&2
		;;
	"$EXIT_FILE_NOT_EXIST")
		echo "File '$2' does not exist." >&2
		;;
	"$EXIT_AUTHENTICATION_FAILED")
		echo "Failed to complete authentication to '$2'." >&2
		;;
	*)
		echo "Unknown error code $1." >&2
		;;
	esac

	exit "$1"
}

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

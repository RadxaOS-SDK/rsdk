# shellcheck shell=bash

set -euo pipefail
shopt -s nullglob

LC_ALL="C"
LANG="C.UTF-8"
LANGUAGE="C.UTF-8"

EXIT_SUCCESS=0
EXIT_UNKNOWN_OPTION=1
EXIT_TOO_FEW_ARGUMENTS=2
EXIT_UNSUPPORTED_OPTION=3
EXIT_SUDO_PERMISSION=4
EXIT_BLKDEV_NO_ROOTDEV=5
EXIT_DEV_SHM_TOO_SMALL=6
EXIT_RUNNING_AS_ROOT=7
EXIT_MISSING_SUBCOMMAND=8
EXIT_FILE_NOT_EXIST=9
EXIT_AUTHENTICATION_FAILED=10
EXIT_NOT_BLOCK_DEVICE=11
EXIT_RUNNING_IN_CONTAINER=12

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
	"$EXIT_BLKDEV_NO_ROOTDEV")
		echo "Unable to find root partition for '$2'." >&2
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
	"$EXIT_NOT_BLOCK_DEVICE")
		echo "'$2' is not a block device." >&2
		;;
	"$EXIT_RUNNING_IN_CONTAINER")
		echo "'$(basename "$0")' cannot be run in the container. Please try again in a native shell." >&2
		;;
	*)
		echo "Unknown error code $1." >&2
		;;
	esac

	exit "$1"
}

# Workaround normal sudo can't access nix programs
sudo() {
	/usr/bin/env sudo --preserve-env=PATH -s "$@"
}

#!/usr/bin/env bash

_rsdk_build_completions() {
	# shellcheck source=bin/lib/stdlib.sh
	source "$(dirname "$(command -v "${COMP_WORDS[0]}")")/lib/stdlib.sh"

	local suggestions=(
		"--no-cache"
		"--no-efi"
		"-d"
		"--debug"
		"-T"
		"--test-repo"
		"-m"
		"--mirror"
		"-M"
		"-i"
		"--image-name"
		"-h"
		"--help"
	)

	local products=() product_provided="false"
	mapfile -t products < <(jsonnet -S "$(dirname "$(command -v "${COMP_WORDS[0]}")")/../templates/lib/product_list.libjsonnet")
	# Trim empty elements
	array_remove "products" ""

	for i in "${products[@]}"; do
		if in_array "$i" "${COMP_WORDS[@]}"; then
			product_provided="true"
			break
		fi
	done

	if [[ $product_provided == "false" ]]; then
		suggestions+=("${products[@]}")
	fi

	mapfile -t COMPREPLY < <(compgen -W "${suggestions[*]}" -- "${COMP_WORDS[COMP_CWORD]}")
}

_rsdk_chroot_completions() {
	case "$COMP_CWORD" in
	2)
		local i suggestions=()
		for i in out/*/output.img \
			"${COMP_WORDS[COMP_CWORD]%/}"/out/*/output.img \
			"${COMP_WORDS[COMP_CWORD]%/}"/*/output.img \
			"${COMP_WORDS[COMP_CWORD]%/}"/output.img; do
			if [[ -f $i ]]; then
				suggestions+=("$i")
			fi
		done
		for i in /dev/sd*; do
			if [[ -b $i ]] && [[ ! $i =~ .*[0-9] ]]; then
				suggestions+=("$i")
			fi
		done
		for i in /dev/nvme*n* /dev/mmcblk* /dev/mapper/loop*; do
			if [[ -b $i ]] && [[ ! $i =~ .*p[0-9] ]]; then
				suggestions+=("$i")
			fi
		done
		mapfile -t COMPREPLY < <(compgen -W "${suggestions[*]}" -- "${COMP_WORDS[COMP_CWORD]}")
		;;
	esac
}

_rsdk_write-image_completions() {
	case "$COMP_CWORD" in
	2)
		local i suggestions=()
		for i in out/*/output.img \
			"${COMP_WORDS[COMP_CWORD]%/}"/out/*/output.img \
			"${COMP_WORDS[COMP_CWORD]%/}"/*/output.img \
			"${COMP_WORDS[COMP_CWORD]%/}"/output.img; do
			if [[ -f $i ]]; then
				suggestions+=("$i")
			fi
		done
		mapfile -t COMPREPLY < <(compgen -W "${suggestions[*]}" -- "${COMP_WORDS[COMP_CWORD]}")
		;;
	3)
		local i suggestions=()
		for i in /dev/disk/by-path/*usb*; do
			if [[ $i == *-part* ]]; then
				continue
			fi
			i="$(realpath "$i")"
			if [[ -b $i ]]; then
				suggestions+=("$i")
			fi
		done
		mapfile -t COMPREPLY < <(compgen -W "${suggestions[*]}" -- "${COMP_WORDS[COMP_CWORD]}")
		;;
	esac
}

_rsdk_completions() {
	# shellcheck source=bin/lib/stdlib.sh
	source "$(dirname "$(command -v "${COMP_WORDS[0]}")")/lib/stdlib.sh"
	# shellcheck source=bin/lib/rsdk_configs.sh
	source "$(dirname "$(command -v "${COMP_WORDS[0]}")")/lib/rsdk_configs.sh"

	case "$COMP_CWORD" in
	0) : ;;
	1)
		local subcommands=(
			"${RSDK_SUPPORTED_SUBCOMMANDS[@]}"
		)

		if [[ -f "/.dockerenv" ]]; then
			array_remove "subcommands" "chroot"
			array_remove "subcommands" "devcon"
		fi

		if [[ -n $DEVENV_NIX ]]; then
			array_remove "subcommands" "shell"
		fi

		mapfile -t COMPREPLY < <(compgen -W "${subcommands[*]}" -- "${COMP_WORDS[COMP_CWORD]}")
		;;
	*)
		if [[ "$(type -t "_rsdk_${COMP_WORDS[1]}_completions")" == "function" ]]; then
			"_rsdk_${COMP_WORDS[1]}_completions"
		fi
		;;
	esac
}

complete -o default -F _rsdk_completions rsdk

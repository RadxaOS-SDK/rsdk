#!/usr/bin/env bash

_rsdk_completions() {
	case "${#COMP_WORDS[@]}" in
	2)
		local subcommands=(
			"build"
			"devcon"
			"help"
			"setup"
		)

		mapfile -t COMPREPLY < <(compgen -W "${subcommands[*]}" "${COMP_WORDS[1]}")
		;;
	esac
}

complete -o default -F _rsdk_completions rsdk

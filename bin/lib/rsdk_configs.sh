#!/usr/bin/env bash

export RSDK_DEFAULT_IMAGE_NAME="output.img"

export RSDK_SUPPORTED_SUBCOMMANDS=(
	"build"
	"chroot"
	"devcon"
	"help"
	"infra-build"
	"infra-update"
	"install"
	"setup"
	"shell"
	"write-image"
)

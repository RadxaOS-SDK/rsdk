#!/usr/bin/env bash

export RSDK_DEFAULT_IMAGE_NAME="output.img"

export RSDK_SUPPORTED_SUBCOMMANDS=(
	"build"
	"chroot"
	"devcon"
	"help"
	"setup"
	"shell"
	"update-product-repo"
	"write-image"
)

function(
    target,
) |||
	-include .github/local/Makefile.local
	PROJECT ?= %(target)s

	UBOOT_FORK ?= %(fork)s
	ARCH ?= arm
	CROSS_COMPILE ?= aarch64-linux-gnu-
	CUSTOM_MAKE_DEFINITIONS ?=
	CUSTOM_DEBUILD_ENV ?= DEB_BUILD_OPTIONS='parallel=1'
	SUPPORT_CLEAN ?= true

	UMAKE ?= $(MAKE) -C "$(SRC-UBOOT)" -j$(shell nproc) \
				$(CUSTOM_MAKE_DEFINITIONS) \
				ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) \
				UBOOTVERSION=$(shell dpkg-parsechangelog -S Version)-$(UBOOT_FORK)

	UBOOT_PRODUCTS ?=

	.DEFAULT_GOAL := all
	.PHONY: all
	all: build

	.PHONY: devcontainer_setup
	devcontainer_setup:
		sudo apt-get update
		sudo apt-get build-dep . -y

	#
	# Test
	#
	.PHONY: test
	test:

	#
	# Build
	#
	DIR-OUTPUT := out
	SRC-UBOOT := src

	$(DIR-OUTPUT):
		mkdir -p $@

	.PHONY: build
	build: $(DIR-OUTPUT) $(SRC-UBOOT) pre_build $(UBOOT_PRODUCTS) post_build

	.PHONY: pre_build
	pre_build:
		# Fix file permissions when created from template
		chmod +x debian/rules
	
	.PHONY: post_build
	post_build:

	#
	# Clean
	#
	.PHONY: clean_config
	clean_config:
		rm -f $(SRC-UBOOT)/.config

	.PHONY: distclean
	distclean: clean
		if [ "$(SUPPORT_CLEAN)" == "true" ]; then $(UMAKE) distclean; fi

	.PHONY: clean
	clean: clean-deb
		if [ "$(SUPPORT_CLEAN)" == "true" ]; then $(UMAKE) clean; fi

	.PHONY: clean-deb
	clean-deb:
		rm -rf $(DIR-OUTPUT) debian/.debhelper debian/${PROJECT}*/ debian/u-boot-*/ debian/tmp/ debian/debhelper-build-stamp debian/files debian/*.debhelper.log debian/*.postrm.debhelper debian/*.substvars

	#
	# Release
	#
	.PHONY: dch
	dch: debian/changelog
		EDITOR=true gbp dch --ignore-branch --multimaint-merge --commit --git-log='--no-merges --perl-regexp --author ^((?!github-actions\[bot\]).*)$$' --release --dch-opt=--upstream

	.PHONY: deb
	deb: debian
		$(CUSTOM_DEBUILD_ENV) debuild --no-lintian --lintian-hook "lintian --fail-on error,warning --suppress-tags bad-distribution-in-changes-file -- %%p_%%v_*.changes" --no-sign -b

	.PHONY: release
	release:
		gh workflow run .github/workflows/new_version.yaml --ref $(shell git branch --show-current)
||| % {
    target: target,
    fork: std.splitLimit(target, "-", 1)[1],
}

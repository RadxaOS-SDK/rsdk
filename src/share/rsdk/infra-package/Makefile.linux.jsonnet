function(
    target,
) |||
	-include .github/local/Makefile.local
	PROJECT ?= %(target)s

	KERNEL_FORK ?= %(fork)s
	ARCH ?= arm64
	CROSS_COMPILE ?= aarch64-linux-gnu-
	DPKG_FLAGS ?= -d
	KERNEL_DEFCONFIG ?= defconfig radxa.config
	CUSTOM_ENV_DEFINITIONS ?=
	CUSTOM_MAKE_DEFINITIONS ?=
	CUSTOM_DEBUILD_ENV ?= DEB_BUILD_OPTIONS='parallel=1'
	SUPPORT_CLEAN ?= true

	KMAKE ?= $(CUSTOM_ENV_DEFINITIONS) $(MAKE) -C "$(SRC-KERNEL)" -j$(shell nproc) \
				$(CUSTOM_MAKE_DEFINITIONS) \
				ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) HOSTCC=$(CROSS_COMPILE)gcc \
				KDEB_COMPRESS="xz" KDEB_CHANGELOG_DIST="unstable" DPKG_FLAGS=$(DPKG_FLAGS) \
				LOCALVERSION=-$(shell dpkg-parsechangelog -S Version | cut -d "-" -f 2)-$(KERNEL_FORK) \
				KERNELRELEASE=$(shell dpkg-parsechangelog -S Version)-$(KERNEL_FORK) \
				KDEB_PKGVERSION=$(shell dpkg-parsechangelog -S Version)

	.DEFAULT_GOAL := all
	.PHONY: all
	all: build

	.PHONY: devcontainer_setup
	devcontainer_setup:
		sudo dpkg --add-architecture arm64
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
	.PHONY: build
	build: pre_build build-defconfig build-bindeb post_build

	.PHONY: pre_build
	pre_build:
		# Fix file permissions when created from template
		chmod +x debian/rules
	
	.PHONY: post_build
	post_build:

	SRC-KERNEL	?=	src

	.PHONY: build-defconfig
	build-defconfig: $(SRC-KERNEL)
		$(KMAKE) $(KERNEL_DEFCONFIG)

	.PHONY: build-dtbs
	build-dtbs: $(SRC-KERNEL)
		$(KMAKE) dtbs

	.PHONY: build-modules
	build-modules: $(SRC-KERNEL)
		$(KMAKE) modules

	.PHONY: build-all
	build-all: $(SRC-KERNEL)
		$(KMAKE) all

	.PHONY: build-bindeb
	build-bindeb: $(SRC-KERNEL) build-all
		$(KMAKE) bindeb-pkg
		mv linux-*_arm64.deb linux-upstream*_arm64.changes linux-upstream*_arm64.buildinfo ../

	#
	# Clean
	#
	.PHONY: distclean
	distclean: clean
		if [ "$(SUPPORT_CLEAN)" == "true" ]; then $(KMAKE) distclean; fi

	.PHONY: clean
	clean: clean-deb
		if [ "$(SUPPORT_CLEAN)" == "true" ]; then $(KMAKE) clean; fi

	.PHONY: clean-deb
	clean-deb:
		rm -rf debian/.debhelper debian/$(PROJECT)*/ debian/linux-*/ debian/tmp/ debian/debhelper-build-stamp debian/files debian/*.debhelper.log debian/*.*.debhelper debian/*.substvars
		rm -f linux-*_arm64.deb linux-upstream*_arm64.changes linux-upstream*_arm64.buildinfo

	#
	# Release
	#
	.PHONY: dch
	dch: debian/changelog
		gbp dch --ignore-branch --multimaint-merge --release --spawn-editor=never \
		--git-log='--no-merges --perl-regexp --invert-grep --grep=^(chore:\stemplates\sgenerated)' \
		--dch-opt=--upstream --commit --commit-msg="feat: release %%(version)s"

	.PHONY: deb
	deb: debian
		$(CUSTOM_DEBUILD_ENV) debuild --no-lintian --lintian-hook "lintian --fail-on error,warning --suppress-tags-from-file $(PWD)/debian/common-lintian-overrides -- %%p_%%v_*.changes" --no-sign -b

	.PHONY: release
	release:
		gh workflow run .github/workflows/new_version.yaml --ref $(shell git branch --show-current)
||| % {
    target: target,
    fork: std.splitLimit(target, "-", 1)[1],
}

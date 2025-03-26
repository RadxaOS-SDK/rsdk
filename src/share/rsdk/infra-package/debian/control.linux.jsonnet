function(
    target,
) |||
    Source: %(target)s
    Maintainer: "Radxa Computer Co., Ltd" <dev@radxa.com>
    Section: admin
    Priority: standard
    Standards-Version: 4.6.0
    Build-Depends: debhelper (>=12~),
                devscripts,
                lintian,
                dh-exec,
                flex,
                bison,
                bc,
                libncurses-dev,
                crossbuild-essential-arm64 [!arm64],
                binfmt-support [!arm64],
                qemu-user-static [!arm64],
                libc6:arm64 [!arm64],
                libssl-dev:arm64,
                cpio,
                kmod:arm64,
                libyaml-dev:arm64,
                rsync,

    Package: linux-image
    Architecture: all
    Section: kernel
    Priority: optional
    Provides: linux-image
    Depends: radxa-overlays-dkms,
             linux-image-${binary:Version}-%(fork)s,
             ${misc:Depends},
    Description: Radxa Linux meta-package for new product
     This is the meta-package for Linux kernel.

    Package: linux-headers
    Architecture: all
    Section: kernel
    Priority: optional
    Provides: linux-headers
    Depends: linux-headers-${binary:Version}-%(fork)s,
             ${misc:Depends},
    Description: Radxa Linux headers meta-package for new product
     This is the meta-package for Linux headers.

    Package: linux-libc-dev
    Architecture: all
    Section: kernel
    Priority: optional
    Provides: linux-libc-dev
    Depends: linux-libc-dev-${binary:Version}-%(fork)s,
             ${misc:Depends},
    Description: Radxa Linux libc-dev meta-package for new product
     This is the meta-package for Linux libc-dev.
||| % {
    target: target,
    fork: std.splitLimitR(target, "-", 1)[1],
}

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
                   python3-setuptools,
                   swig,
                   python3-dev,
                   libgnutls28-dev,
                   python3-pyelftools,
                   libncurses-dev,
                   crossbuild-essential-arm64 [!arm64],
                   crossbuild-essential-armhf [!armhf],
                   crossbuild-essential-armel [!armel],
                   xxd,
                   bc,
                   lib32stdc++6 [!i386],
                   lib32z1 [!i386],
                   dos2unix,

    Package: %(target)s
    Architecture: all
    Section: admin
    Priority: optional
    Depends: ${misc:Depends},
    Description: U-Boot based on %(fork)s
     This package provides the prebuilt U-Boot based on %(fork)s.

    Package: u-boot-product
    Architecture: all
    Depends: %(target)s,
             ${misc:Depends},
    Section: admin
    Priority: optional
    Description: Radxa U-Boot meta-package for new product.
     This package provides the prebuilt U-Boot for new product.

||| % {
    target: target,
    fork: std.splitLimitR(target, "-", 1)[1],
}

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

    Package: %(target)s
    Architecture: all
    Section: admin
    Priority: optional
    Depends: ${misc:Depends},
    Description: U-Boot based on %(fork)s
     This package provides the prebuilt U-Boot based on %(fork)s.
||| % {
    target: target,
    fork: std.splitLimitR(target, "-", 1)[1],
}

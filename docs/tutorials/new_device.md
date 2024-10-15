# Adding support for new device

Every device supported by RadxaOS requires several metapackages available in the
apt repositories. They are usually unique to each hardware, as such cannot be
shared between devices.

It is intentional to keep this info in form of package dependencies, and spread
out in several packages, instead of a single hard coded config file. This is because:

1. Different build tools don't need to track this config in order to build with
   correct packages.
2. Ease of migration between tools.  
   For example, from `rbuild` to `rsdk`, we use the same simple package logic
   instead doing data transform, which was the case for `rbuild`'s `configs`
   files.
3. Allow underlying package to be changed/updated in the future.

## Adding new device

Currently, there are 4 places that need to be updated:

1. Kernel metapackages  
   Those includes Linux kernel image as well as kernel header, and some other
   less used packages.  
   Currently you need to edit the related `bsp`
   [Linux profile](https://github.com/radxa-repo/bsp/blob/main/linux/latest/fork.conf)
   to include the new device.
2. Firmware metapackage  
   This is similar to the kernel package in case of U-Boot, where the
   [U-Boot profile](https://github.com/radxa-repo/bsp/blob/main/u-boot/latest/fork.conf)
   needs to be updated.  
   For EDK2 you will need to [add the metapackage](https://github.com/radxa-pkg/edk2-cix/blob/main/debian/control)
   in the related repo.
3. Product metapackage  
   Each product also needs its own package to pull device-specific drivers, and
   some common config options.
   Those are defined in [`radxa-profiles`](https://github.com/radxa-pkg/radxa-profiles/blob/main/debian/control)
   repo.
4. [`products.json`](https://github.com/RadxaOS-SDK/rsdk/blob/main/src/share/rsdk/configs/products.json)  
   This registers the supported products for `rsdk` and their default configurations.

Right now, product metapackage does not specify dependencies to kernel and
firmware (even though we have product-agnostic metapackages for those two). This
is to allow users to install custom kernels only without breaking the
dependencies.

Note that vendor metapackage is listed as recommended in product metapackages.
This way users can install the system without SoC vendors' binary packages.

Finally, create the new product build repo under [`radxa-build`](https://github.com/radxa-build)
with `rsdk-infra-product-update` command.

## What if we introduce a new SoC?

You need to additionally update following places:

1. Vendor metapackage  
   Each SoC needs their own package to pull SoC-specific packages, and
   some common config options.
   Those are defined in [`vendor-profiles`](https://github.com/radxa-pkg/vendor-profiles/blob/main/debian/control)
   repo.
2. [`socs.json`](https://github.com/RadxaOS-SDK/rsdk/blob/main/src/share/rsdk/configs/socs.json)  
   New SoC **MUST** be added to `soc_specific_repo` array as well.
3. New SoC-specific apt repo under [`radxa-repo`](https://github.com/radxa-repo) organization.
4. SoC-specific package repo  
   In case of Rockchip, those are managed by [`rockchip-prebuilt`](https://github.com/radxa-pkg/rockchip-prebuilt)
   repo, and we create Rockchip SDK prebuilt packages in GitHub Releases, which
   will be uploaded to the SoC-specific apt repo.  
   If the new SoC is only a variant of already supported SoC, then you only need
   to edit the related [`pkg.conf`](https://github.com/radxa-pkg/rockchip-prebuilt/blob/main/pkg.conf.linux-6.1-stan-rkr1)
   to include the new SoC-specific apt repo.

## What if we introduce a new SoC vendor?

You need to additionally update following places:

1. Vendor metapackage  
   Each vendor needs their own package to pull common config options.
   Those are defined in [`vendor-profiles`](https://github.com/radxa-pkg/vendor-profiles/blob/main/debian/control)
   repo.
2. [`socs.json`](https://github.com/RadxaOS-SDK/rsdk/blob/main/src/share/rsdk/configs/socs.json)  
   There should be a new item for the new vendor.

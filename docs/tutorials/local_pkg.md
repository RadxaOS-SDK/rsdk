# Work with local packages

## Background

When working at the bleeding edge, developer needs to test some locally built
packages before committing the changes. However, to ensure the build is reproducible,
maintainer wants to lock up all inputs, usually in a version-controlled way.

At Radxa, this conflict primarily impacts our BSP developers, who are not involved
in toolchain development. As such, `rbuild` provides
[some helper flags](https://radxa-repo.github.io/rbuild/dev/bsp.html) to allow
better integration with `bsp`'s build outputs. The scope of local packages is
intentionally limited to kernel and firmware packages, since the development
workflow for the OS maintainers is different: just test the package on a live system. 

`rsdk` initially dropped this support. As an evolution of `rbuild`, the
package situation was stable enough that BSP developers did not need to build
images with custom packages very often. The support is now available in more
general form, in hope to support fully offline system building in the future.

## `rsdk-build --debs`

`rsdk-build` now supports `--debs <debs_dir>` flag. A folder containing locally
built packages are needed with this flag.

When this flag is specified, the content of `debs_dir` will be copied inside the
target system, and will be added as a local apt repository under `/srv/local-apt-repository`,
and it will have pin priority of 1999, effecitive making it the only provider of the included package.

```admonish warning
Unlike `rbuild`, this local apt repository will persist in the rootfs. This will
block future package upgrade via `apt` if it is available in an online source,
and also serves as the build input for future reproduceible build.

Consider clear `/srv/local-apt-repository` after the build if this behaviour is
undesired.
```

When running `rsdk` in `devcontainer`, we recommend `debs_dir` to be inside `rsdk`
project folder (for example, the `debs` folder in the project root). As the host
path may not be mapped inside `devcontainer`, `rsdk-build` may not be able to
access it.

## Add packages that are not part of the default install

Because the package are not explicitly installed like the case of `rbuild`, if
you want a package to be installed, it has to also be installed by the normal build
steps.

If your package is not installed by default, you will need to follow [`Rootfs customization`](customize.md#rootfs-customization)
to add them to the build steps.

## Override packages that are part of the default install

For example, if we want to replace the U-Boot for ROCK 4SE, we need to provide
both the `u-boot-rock-4se` metapackage, which is [installed by the build script](https://github.com/RadxaOS-SDK/rsdk/blob/47a766e773b187543dd5f38f7fc8c0df7d49e8b0/src/share/rsdk/build/mod/packages/categories/core.libjsonnet#L81),
and the `u-boot-latest` binary package, which provides the bootloader and is
`u-boot-rock-4se`'s dependency.

Usually you should copy every generated packages to `debs_dir` for each project
you are going to override. This is to reduce the likelihood of missing a dependency.

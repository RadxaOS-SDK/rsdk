# rsdk - RadxaOS Software Development Kit

## Installation

Clone this repo, then open it with Visual Studio Code and Dev Container.

This will set up the development environment automatically for you.

The first boot will be slow since it has to rebuild the entire development environment locally.

## Local installation

To run `rsdk` without Dev Container, you will ideally need an Ubuntu system, as it is the base system used in Dev Container.

Please first install [`devenv``](https://devenv.sh/getting-started/#2-install-cachix) on your system.

Optionally you can setup [`direnv``](https://devenv.sh/automatic-shell-activation/).

You can then run `devenv shell` to enter the development shell. This shell will manipulate your PATH to have the development dependency available.

If you have `direnv` setup, you don't have to run the above command when you enter the project directory to use the SDK. However, the `direnv` shell lacks `starship` integration as well as `rsdk` auto completion, as it only saves the environmental variables.

There are some additional system configurations and packages that are currently not managed by `devenv`. They are mostly covered by `install_native_dependency` function in [`rsdk-setup`](bin/sub/rsdk-setup).

## Build image

Currently you need to edit [image.jsonnet](templates/image.jsonnet) directly to specify the product-suite-edition tuple. Right now it is set to `radxa-zero-2pro_bookworm_cli` which is build and boot tested.

You will then run `rsdk build` to generate the complete rootfs under `out/rootfs.tar`. You can then run `rsdk deploy` to generated a bootable disk image under `out/output.img`.

Currently I'm experiencing an issue on my system where `umount` in [`rsdk-deploy`](bin/sub/rsdk-deploy) will stall the kernel and never returns. `sync` will stall as well, and `kpartx -d` cannot remove the rootfs loop device. This behaviour is observed within Dev Container as well as in native Arch host system running kernel 6.6.6, so I'm not sure what is causing it. For now I just do a system reboot for make sure the image is dismounted before I flash it to microSD.

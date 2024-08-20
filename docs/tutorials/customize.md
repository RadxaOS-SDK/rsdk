# Build customization

`rsdk` uses [`devenv`](https://devenv.sh/) to manage its **dev**elopment **env**rionronment, but itself is not `nix` based. `nix` has good support generating `NixOS` images, but here we are dealing with a Debian system, and some parts are [currently missing](https://github.com/NixOS/nixpkgs/pull/270095).

We currently uses [`bdebstrap`](https://github.com/bdrung/bdebstrap), which is a YAML frontend for [`mmdebstrap`](https://gitlab.mister-muffin.de/josch/mmdebstrap). `mmdebstrap` is [the recommended tool](https://wiki.debian.org/RISC-V#Creating_a_riscv64_chroot) for building RISC-V systems compared to traditional `debootstrap`.

YAML itself is not a templating language, so it cannot dynamically generate different configurations for different builds. We use [`jsonnet`](https://jsonnet.org) for this purpose.

Lastly, `mmdebstrap` does not handle disk image generation. We again use `jsonnet` to dynamically generate a [`guestfish`](https://libguestfs.org/guestfish.1.html) script to handle this task.

All of those tools are glued by `bash` to provide a frontend, known as [`rsdk-build`](https://github.com/RadxaOS-SDK/rsdk/tree/main/src/libexec/rsdk/rsdk-build).

Depending on your goal, you would need the knowledge of some of the above tools.

## Rootfs customization

[`rootfs.jsonnet`](https://github.com/RadxaOS-SDK/rsdk/tree/main/src/share/rsdk/build/rootfs.jsonnet) is the entry point for rootfs template. It collects the various inputs and passes them to different modules.

Module loading order matters, as that will determine [`*-hooks`](https://manpages.debian.org/testing/mmdebstrap/mmdebstrap.1.en.html#HOOKS)'s execution order. The safest way is to only edit the `customize-hooks` field in `rootfs.jsonnet` and only adding new entries after the existing ones.

You can also edit the `packages` field in `rootfs.jsonnet` to add additional packages to the system. `customize-hooks` will be run after `packages` are installed in the rootfs.

## Disk image customization

[`image.jsonnet`](https://github.com/RadxaOS-SDK/rsdk/tree/main/src/share/rsdk/build/rootfs.jsonnet) is the template for the deployment script. It is generally not necessary to change this part.

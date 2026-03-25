# Global build options

Like [`rbuild`](https://radxa-repo.github.io/rbuild/dev/config.html), `rsdk` also
allows defining global build options. The underlying mechanical is the same:
predefined environmental variables. However, since we use `devenv` to manage the
environment, the way to define them is also changed.

For now, you will need to add your definitions in `devenv.local.nix` file. We
provide `devenv.local.nix.example` as a reference for file structure. This is also
what we use in the office, but the server is locally hosted, so you won't be
able to use it.

## Example: set up local apt cache to speed up build

If you want to speed up image building time, one way is to use a locally hosted
apt cache to reduce download time.

First, copy `devenv.local.nix.example` to `devenv.local.nix`. You can then remove
`RSDK_OPTION_REPO_SUFFIX` if you do not want to build test image by default, and
then change `RSDK_OPTION_*_MIRROR` to your own address. Typical options are:

- `RSDK_OPTION_DISTRO_MIRROR`: default Debian/Ubuntu mirror (equivalent to `rsdk build -m`).
- `RSDK_OPTION_RADXA_MIRROR`: default Radxa APT mirror for radxa-deb (equivalent to `rsdk build -M`).

When using Radxa repositories, `rsdk` will use Radxa `pkgs.json` metadata by default whenever it is available.
You can disable this behavior at build time by passing `-P`/`--no-pkgs-json` or by setting
`RSDK_OPTION_PKGS_JSON=false` explicitly in the environment.

Below are example NixOS configuration to set up a local apt cache service, as
well as the mirror definition for `acng.conf` file. They may not be complete, so
adjust to match your own use case.

```nix
{
  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
        acng = {
          image = "docker.io/mbentley/apt-cacher-ng";
          ports = [
            "3142:3142"
          ];
          volumes = [
            "/home/acng/containers/acng.conf:/etc/apt-cacher-ng/acng.conf"
            "/home/acng/containers/acng/:/var/cache/apt-cacher-ng/"
          ];
          environment = {
            PUID = "1000";
            PGID = "100";
            TZ = "Asia/Shanghai";
          };
        };
      };
    };
  };
}
```

```
Remap-debian: /debian ; http://mirrors.tuna.tsinghua.edu.cn/debian
Remap-debian-security: /debian-security ; http://mirrors.tuna.tsinghua.edu.cn/debian-security
Remap-ubuntu: /ubuntu ; http://mirrors.tuna.tsinghua.edu.cn/ubuntu
Remap-ubuntu-ports: /ubuntu-ports ; http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports
Remap-armbian: /armbian ; http://mirrors.tuna.tsinghua.edu.cn/armbian
Remap-proxmox: /proxmox ; http://mirrors.tuna.tsinghua.edu.cn/proxmox/debian
Remap-proxmox-new: /debian/pve ; http://mirrors.tuna.tsinghua.edu.cn/proxmox/debian/pve
Remap-rbuild: /rbuild ; http://radxa-repo.github.io/apt
Remap-rbuild-buster: /rbuild-buster ; http://radxa-repo.github.io/buster
Remap-rbuild-buster-test: /rbuild-buster-test ; http://radxa-repo.github.io/buster-test
Remap-rbuild-bullseye: /rbuild-bullseye ; http://radxa-repo.github.io/bullseye
Remap-rbuild-bullseye-test: /rbuild-bullseye-test ; http://radxa-repo.github.io/bullseye-test
Remap-rbuild-rk3528a-bullseye-test: /rbuild-rk3528a-bullseye-test ; http://radxa-repo.github.io/rk3528a-bullseye-test
Remap-rbuild-focal: /rbuild-focal ; http://radxa-repo.github.io/focal
Remap-rbuild-focal-test: /rbuild-focal-test ; http://radxa-repo.github.io/focal-test
Remap-rbuild-jammy: /rbuild-jammy ; http://radxa-repo.github.io/jammy
Remap-rbuild-jammy-test: /rbuild-jammy-test ; http://radxa-repo.github.io/jammy-test
Remap-rbuild-bookworm: /rbuild-bookworm ; http://radxa-repo.github.io/bookworm
Remap-rbuild-bookworm-test: /rbuild-bookworm-test ; http://radxa-repo.github.io/bookworm-test
Remap-rbuild-rk3588-bookworm-test: /rbuild-rk3588-bookworm-test ; http://radxa-repo.github.io/rk3588-bookworm-test
Remap-rbuild-rk3588s2-bookworm-test: /rbuild-rk3588s2-bookworm-test ; http://radxa-repo.github.io/rk3588s2-bookworm-test
Remap-rbuild-sid: /rbuild-sid ; http://radxa-repo.github.io/sid
Remap-rbuild-sid-test: /rbuild-sid-test ; http://radxa-repo.github.io/sid-test
Remap-rbuild-noble-test: /rbuild-noble-test ; http://radxa-repo.github.io/noble-test
Remap-rbuild-vscodium: /rbuild-debs ; https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs
```

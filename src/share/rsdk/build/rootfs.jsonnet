local distro = import "mod/distro.libjsonnet";
local additional_repos = import "mod/additional_repos.libjsonnet";
local packages = import "mod/packages.libjsonnet";
local cleanup = import "mod/cleanup.libjsonnet";

function(
    architecture = "arm64",
    mode = "root",
    rootfs = "rootfs.tar",
    variant = "apt",

    temp_dir,
    output_dir,
    rsdk_rev = "",

    distro_mirror = "",
    snapshot_timestamp = "",

    radxa_mirror = "",
    radxa_repo_suffix = "",

    product,
    suite,
    edition,
    build_date,

    vendor_packages = true,
    linux_override = "",
    firmware_override = "",
    install_vscodium = false,
    use_pkgs_json = true,
) distro(suite, distro_mirror, architecture, snapshot_timestamp)
+ additional_repos(suite, radxa_mirror, radxa_repo_suffix, product, temp_dir, install_vscodium, use_pkgs_json)
+ packages(suite, edition, product, temp_dir, vendor_packages, linux_override, firmware_override)
+ cleanup()
+ {
    mmdebstrap+: {
        architectures: [
            architecture
        ],
        keyrings: [
            "%(temp_dir)s/keyrings/" % { temp_dir: temp_dir },
        ],
        mode: mode,
        target: rootfs,
        variant: variant,
        hostname: product,
        packages+:
        [
            // Adding additional packages to the system
            // For example:
            // "nano",
        ],
        "customize-hooks"+:
        [
            'echo "127.0.1.1	%(product)s" >> "$1/etc/hosts"' % { product: product },
            'cp "%(output_dir)s/config.yaml" "$1/etc/rsdk/"' % { output_dir: output_dir },
            'echo "FINGERPRINT_VERSION=\'2\'" > "$1/etc/radxa_image_fingerprint"',
            'echo "RSDK_BUILD_DATE=\'$(date -R)\'" >> "$1/etc/radxa_image_fingerprint"',
            'echo "RSDK_REVISION=\'%(rsdk_rev)s\'" >> "$1/etc/radxa_image_fingerprint"' % { rsdk_rev: rsdk_rev },
            'echo "RSDK_CONFIG=\'/etc/rsdk/config.yaml\'" >> "$1/etc/radxa_image_fingerprint"',
            'chroot "$1" sh -c "SYSTEMD_RELAX_ESP_CHECKS=1 update-initramfs -c -k all"',
            'chroot "$1" sh -c "u-boot-update"',
            |||
                cp -aR "$1/boot/efi" "$1/boot/efi2"
                chmod 0755 "$1/boot/efi2"
                umount "$1/boot/efi"
                rmdir "$1/boot/efi"
                mv "$1/boot/efi2" "$1/boot/efi"
            |||,
            |||
                mkdir -p "%(output_dir)s/seed"
                cp "$1/etc/radxa_image_fingerprint" "%(output_dir)s/seed"
                cp "$1/etc/rsdk/"* "%(output_dir)s/seed"
                tar Jvcf "%(output_dir)s/seed.tar.xz" -C "%(output_dir)s/seed" .
                rm -rf "%(output_dir)s/seed"
            ||| % { output_dir: output_dir },
            // Adding additional customization commands
            // $1 is the mounted rootfs than you can chroot into
            // For example:
            // |||
            //     set -e
            //     wget -O $1/tmp/your.deb https://example.com/your.deb
            //     chroot "$1" dpkg -i /tmp/your.deb
            //     rm $1/tmp/your.deb
            // |||,
        ]
    },
    metadata: {
        architecture: architecture,
        mode: mode,
        rootfs: rootfs,
        variant: variant,

        temp_dir: temp_dir,
        output_dir: output_dir,
        rsdk_rev: rsdk_rev,

        distro_mirror: distro_mirror,

        radxa_mirror: radxa_mirror,
        radxa_repo_suffix: radxa_repo_suffix,

        product: product,
        suite: suite,
        edition: edition,
        build_date: build_date,

        vendor_packages: vendor_packages,
        linux_override: linux_override,
        firmware_override: firmware_override,
        install_vscodium: install_vscodium,
        use_pkgs_json: use_pkgs_json,
        sdboot: std.extVar("sdboot"),
    },
}

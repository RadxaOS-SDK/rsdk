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

    radxa_mirror = "",
    radxa_repo_suffix = "",

    product,
    suite,
    edition,
    build_date,

    vendor_packages = true,
    linux_override = "",
    u_boot_override = "",
) distro(suite, distro_mirror, architecture)
+ additional_repos(suite, radxa_mirror, radxa_repo_suffix, product, temp_dir)
+ packages(suite, edition, product, temp_dir, vendor_packages, linux_override, u_boot_override)
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
        "customize-hooks"+:
        [
            'echo "127.0.1.1	%(product)s" >> "$1/etc/hosts"' % { product: product },
            'cp "%(output_dir)s/config.yaml" "$1/etc/rsdk/"' % { output_dir: output_dir },
            'echo "FINGERPRINT_VERSION=\'2\'" > "$1/etc/radxa_image_fingerprint"',
            'echo "RSDK_BUILD_DATE=\'$(date -R)\'" >> "$1/etc/radxa_image_fingerprint"',
            'echo "RSDK_REVISION=\'%(rsdk_rev)s\'" >> "$1/etc/radxa_image_fingerprint"' % { rsdk_rev: rsdk_rev },
            'echo "RSDK_CONFIG=\'/etc/rsdk/config.yaml\'" >> "$1/etc/radxa_image_fingerprint"',
            'chroot "$1" update-initramfs -cvk all',
            'chroot "$1" u-boot-update',
            |||
                mkdir -p "%(output_dir)s/seed"
                cp "$1/etc/radxa_image_fingerprint" "%(output_dir)s/seed"
                cp "$1/etc/rsdk/"* "%(output_dir)s/seed"
                tar zvcf "%(output_dir)s/seed.tar.gz" -C "%(output_dir)s/seed" .
                rm -rf "%(output_dir)s/seed"
            ||| % { output_dir: output_dir },
        ]
    },
    metadata: {
        product: product,
        suite: suite,
        edition: edition,
        build_date: build_date,
    }
}
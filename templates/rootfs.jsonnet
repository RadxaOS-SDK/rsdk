local distro = import "mod/distro.libjsonnet";
local additional_repos = import "mod/additional_repos.libjsonnet";
local packages = import "mod/packages.libjsonnet";
local cleanup = import "mod/cleanup.libjsonnet";

function(
    architecture = "arm64",
    mode = "root",
    target = "rootfs.tar",
    variant = "apt",

    temp_dir,
    output_dir,
    rsdk_rev = "",

    distro_mirror = "",

    radxa_mirror = "",
    radxa_repo_postfix = "",

    product,
    suite,
    edition,
    build_date,
) distro(suite, distro_mirror, architecture)
+ additional_repos(suite, radxa_mirror, radxa_repo_postfix, product, temp_dir)
+ packages(suite, edition, product, temp_dir)
+ cleanup()
+ {
    mmdebstrap+: {
        architectures: [
            architecture
        ],
        keyrings: [
            "%s/keyrings/" % [temp_dir]
        ],
        mode: mode,
        target: target,
        variant: variant,
        hostname: product,
        "customize-hooks"+:
        [
            'mkdir "$1/etc/rsdk/"',
            'cp "%s/config.yaml" "$1/etc/rsdk/"' % [output_dir],
            'echo "FINGERPRINT_VERSION=\'2\'" > "$1/etc/radxa_image_fingerprint"',
            'echo "RSDK_BUILD_DATE=\'$(date -R)\'" >> "$1/etc/radxa_image_fingerprint"',
            'echo "RSDK_REVISION=\'%s\'" >> "$1/etc/radxa_image_fingerprint"' % [rsdk_rev],
            'echo "RSDK_CONFIG=\'/etc/rsdk/config.yaml\'" >> "$1/etc/radxa_image_fingerprint"',
            'chroot "$1" update-initramfs -cvk all',
            'chroot "$1" u-boot-update',
        ]
    },
    metadata: {
        product: product,
        suite: suite,
        edition: edition,
        build_date: build_date,
    }
}
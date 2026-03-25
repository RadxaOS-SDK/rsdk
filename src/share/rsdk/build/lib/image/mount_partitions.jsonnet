local mount_config_partition() =
|||
    mkdir-p /config
    mount /dev/sda1 /config
|||;

local mount_efi_partition(efi) =
(if efi
then
|||
    mkdir-p /boot/efi
    mount /dev/sda2 /boot/efi
|||
else
    ""
);

local mount_root_partition(rootfs_type, root_part_num) =
|||
    mount-options %(options)s /dev/sda%(root_part_num)d /
||| % {
    root_part_num: root_part_num,
    options: (if rootfs_type == "btrfs" then "compress=zstd" else "defaults"),
};

function(efi, rootfs_type, root_part_num)
|||
    echo "Mounting partitions..."
||| +
mount_root_partition(rootfs_type, root_part_num) +
mount_config_partition() +
mount_efi_partition(efi) +
"\n"

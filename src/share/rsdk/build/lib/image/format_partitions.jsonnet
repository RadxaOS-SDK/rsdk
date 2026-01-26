local format_config_partition() =
|||
    mkfs vfat /dev/sda1 label:config
|||;

local format_efi_partition(create_efi_part) =
(if create_efi_part
then
|||
    mkfs vfat /dev/sda2 label:efi
|||
else
    ""
);

local format_ext4_partition(suite, root_part_num) =
(if suite == "bullseye"
then
|||
    mkfs ext4 /dev/sda%(root_part_num)d features:^orphan_file label:rootfs
|||
else
|||
    mkfs ext4 /dev/sda%(root_part_num)d label:rootfs
|||
) % {
    root_part_num: root_part_num,
};

local format_btrfs_partition(suite, root_part_num) =
|||
    mkfs-btrfs /dev/sda%(root_part_num)d label:rootfs
||| % {
    root_part_num: root_part_num,
};

local format_root_partition(suite, rootfs_type, root_part_num) =
(if rootfs_type == "btrfs"
then
    format_btrfs_partition(suite, root_part_num)
else
    format_ext4_partition(suite, root_part_num)
);

function(create_efi_part, suite, rootfs_type, root_part_num)
|||
    echo "Formatting partitions..."
||| +
format_config_partition() +
format_efi_partition(create_efi_part) +
format_root_partition(suite, rootfs_type, root_part_num) +
"\n"

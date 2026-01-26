local product_partition_table_type = import "../configs/product_partition_table_type.libjsonnet";
local product_firmware_type = import "../configs/product_firmware_type.libjsonnet";
local product_sector_size = import "../configs/product_sector_size.libjsonnet";

local create_image = import "lib/image/create_image.jsonnet";
local create_partition_table = import "lib/image/create_partition_table.jsonnet";
local format_partitions = import "lib/image/format_partitions.jsonnet";
local mount_partitions = import "lib/image/mount_partitions.jsonnet";
local deploy_rootfs = import "lib/image/deploy_rootfs.jsonnet";
local update_partition_uuid = import "lib/image/update_partition_uuid.jsonnet";
local shrink_root_partition = import "lib/image/shrink_root_partition.jsonnet";
local install_bootloader = import "lib/image/install_bootloader.jsonnet";
local expand_root_partition = import "lib/image/expand_root_partition.jsonnet";
local clean_up = import "lib/image/clean_up.jsonnet";

function(
    product,
    suite,
    output = "output.img",
    rootfs = "rootfs.tar",
    temp_dir = "./temp_dir",
    partition_table_type = product_partition_table_type(product),
    firmware_type = product_firmware_type(product),
    sector_size = product_sector_size(product),
    create_efi_part = (partition_table_type == "gpt"),
    efi_boot = (firmware_type == "edk2" && create_efi_part),
    rootfs_type = (if efi_boot then "btrfs" else "ext4"),
    image_size = (if rootfs_type == "btrfs" then "5G" else "10G"),
    root_part_num = (if create_efi_part then 3 else 2),
)
    create_image(output, sector_size, image_size) +
    create_partition_table(create_efi_part, efi_boot, sector_size, partition_table_type, root_part_num) +
    format_partitions(create_efi_part, suite, rootfs_type, root_part_num) +
    mount_partitions(create_efi_part, rootfs_type, root_part_num) +
    deploy_rootfs(rootfs, temp_dir, efi_boot, firmware_type) +
    update_partition_uuid(create_efi_part, temp_dir, efi_boot, rootfs_type, root_part_num) +
    // btrfs shrink requires the image to be mounted in the host system
    (if rootfs_type != "btrfs" then shrink_root_partition(rootfs_type, output, temp_dir, sector_size, partition_table_type, root_part_num) else "")+
    install_bootloader(firmware_type, output, temp_dir, product, sector_size) +
    expand_root_partition(output, sector_size, rootfs_type, root_part_num) +
    clean_up(temp_dir)

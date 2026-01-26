// part_size unit is MiB
local efi_part_end_sector_internal(part_size, start_sector, sector_size) =
(part_size * 1024 * 1024 / sector_size) + start_sector - 1;

local efi_part_end_sector(efi_boot, start_sector, sector_size) =
(if efi_boot
then
    efi_part_end_sector_internal(1024, start_sector, sector_size)
else
    efi_part_end_sector_internal(300, start_sector, sector_size)
);

local create_config_partition(partition_table_type) =
|||
    part-init /dev/sda %(partition_table_type)s
    part-add /dev/sda primary 32768 65535
||| % {
    partition_table_type: partition_table_type,
};

local create_efi_part_partition(create_efi_part, efi_boot, sector_size, partition_table_type) =
(if create_efi_part
then
|||
    part-add /dev/sda primary 65536 %(efi_part_end_sector)d
    part-set-bootable /dev/sda 2 true
||| % {
    efi_part_end_sector: efi_part_end_sector(efi_boot, 65536, sector_size),
} +
    (if partition_table_type == "gpt"
    then
|||
    part-set-gpt-type /dev/sda 2 C12A7328-F81F-11D2-BA4B-00A0C93EC93B
    part-set-gpt-attributes /dev/sda 2 4
|||
    else
""
    )
else
""
);

local create_root_partition(create_efi_part, efi_boot, sector_size, partition_table_type, root_part_num) =
|||
    part-add /dev/sda primary %(root_part_start_sector)d -34
    part-set-bootable /dev/sda %(root_part_num)d true
||| % {
    root_part_start_sector: (if create_efi_part then efi_part_end_sector(efi_boot, 65536, sector_size) + 1 else 65536),
    root_part_num: root_part_num,
} +
(if partition_table_type == "gpt"
then
|||
    part-set-gpt-type /dev/sda %(root_part_num)d 0FC63DAF-8483-4772-8E79-3D69D8477DE4
    part-set-gpt-attributes /dev/sda %(root_part_num)d 4
||| % {
    root_part_num: root_part_num,
}
else
""
);

function(create_efi_part, efi_boot, sector_size, partition_table_type, root_part_num)
|||
    echo "Creating partition table..."
||| +
create_config_partition(partition_table_type) +
create_efi_part_partition(create_efi_part, efi_boot, sector_size, partition_table_type) +
create_root_partition(create_efi_part, efi_boot, sector_size, partition_table_type, root_part_num) +
"\n"

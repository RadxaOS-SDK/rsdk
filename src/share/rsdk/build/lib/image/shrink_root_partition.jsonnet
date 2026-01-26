local shrink_ext4_partition(temp_dir, root_part_num) =
|||
    unmount-all
    resize2fs-M /dev/sda%(root_part_num)d
    tune2fs-l /dev/sda%(root_part_num)d | cat > "%(temp_dir)s/tune2fs"
    !echo "$(( $(grep "Block count:" %(temp_dir)s/tune2fs | cut -d " " -f 3) * $(grep "Block size:" %(temp_dir)s/tune2fs | cut -d " " -f 3) ))" > "%(temp_dir)s/rootfs_size"
||| % {
    temp_dir: temp_dir,
    root_part_num: root_part_num,
};

local shrink_btrfs_partition(temp_dir, root_part_num) =
|||
    !btrfs filesystem resize "-$(btrfs fi usage -b / | awk '/Free \(estimated\)/{print substr($NF, 1, length($NF-1))}')" /
    !echo "$(btrfs fi usage -b / | awk '/Device size/{print $NF}')" > "%(temp_dir)s/rootfs_size"
    unmount-all
||| % {
    temp_dir: temp_dir,
    root_part_num: root_part_num,
};

function(rootfs_type, output, temp_dir, sector_size, partition_table_type, root_part_num)
(if sector_size == 512
then
|||
    echo "Shrinking rootfs..."
||| +
(if rootfs_type == "btrfs"
then
    shrink_btrfs_partition(temp_dir, root_part_num)
else
    shrink_ext4_partition(temp_dir, root_part_num)
) +
|||
    !echo "resizepart %(root_part_num)d" > "%(temp_dir)s/parted"
    !echo "$(( $(sgdisk -i %(root_part_num)d "%(output)s" | grep "First sector:" | cut -d " " -f 3) * %(sector_size)d + $(cat "%(temp_dir)s/rootfs_size") ))B" >> "%(temp_dir)s/parted"
    !echo "yes" >> "%(temp_dir)s/parted"
    sync
    shutdown
    !cat "%(temp_dir)s/parted" | parted ---pretend-input-tty "%(output)s" > /dev/null 2>&1
    !truncate "--size=$(( ( $(sgdisk -i %(root_part_num)d "%(output)s" | grep "Last sector:" | cut -d " " -f 3) + 34 ) * %(sector_size)d ))" "%(output)s"
||| % {
    output: output,
    temp_dir: temp_dir,
    root_part_num: root_part_num,
    sector_size: sector_size,
} +
(if partition_table_type == "gpt"
then
|||

    echo "Fixing partition table..."
    echo "NOTICE: Some issues are expected result of shrinking the disk."
    !sgdisk -ge "%(output)s" > /dev/null 2>&1 || true
||| % {
    output: output,
}
else
    ""
)+
"\n"
else
    ""
)

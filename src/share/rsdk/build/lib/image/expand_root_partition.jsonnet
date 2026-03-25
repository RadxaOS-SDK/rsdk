local expand_ext4_partition(root_part_num) =
"resize2fs /dev/sda%(root_part_num)d" % {
    root_part_num: root_part_num,
};

local expand_btrfs_partition(root_part_num) =
|||
    mount-options compress=zstd /dev/sda%(root_part_num)d /
    btrfs-filesystem-resize /
    unmount-all    
||| % {
    root_part_num: root_part_num,
};

function(output, sector_size, rootfs_type, root_part_num)
|||
    echo "Enlarging rootfs to the underlying block device..."
    shutdown
    add-drive "%(output)s" format:raw discard:besteffort blocksize:%(sector_size)d
    run
    %(expand_command)s
    shutdown

||| % {
    output: output,
    root_part_num: root_part_num,
    sector_size: sector_size,
    expand_command: (if rootfs_type == "btrfs" then
        expand_btrfs_partition(root_part_num)
    else
        expand_ext4_partition(root_part_num)
    ),
}

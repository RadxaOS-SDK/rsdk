local product_partition_table_type = import "lib/product_partition_table_type.libjsonnet";
local rootdev(efi) = (if efi
then
    3
else
    2
);

function(
    output = "output.img",
    rootfs = "rootfs.tar",
    temp_dir = "./temp_dir",
    product,
    efi = true,
) |||
    #!/usr/bin/env -S guestfish -f

    echo "Allocating image file..."
    !rm -f "%(output)s"
    sparse "%(output)s" 6G
    run

    echo "Creating partition table..."
    part-init /dev/sda %(partition_table_type)s
    part-add /dev/sda primary 32768 65535
||| % {
    output: output,
    partition_table_type: product_partition_table_type(product),
} +
(if efi
then
|||
    part-add /dev/sda primary 65536 679935
    part-add /dev/sda primary 679936 -34
|||
else
    "part-add /dev/sda primary 65536 -34"
) +
|||

    echo "Formatting partitions..."
    mkfs vfat /dev/sda1 label:config
||| +
(if efi
then
    "mkfs vfat /dev/sda2 label:efi"
else
    ""
) +
|||

    mkfs ext4 /dev/sda%(rootdev)d label:rootfs

    echo "Mounting partitions..."
    mount /dev/sda%(rootdev)d /
    mkdir-p /config
    mount /dev/sda1 /config
||| % {
    rootdev: rootdev(efi),
    output: output,
} +
(if efi
then
|||
    mkdir-p /boot/efi
    mount /dev/sda2 /boot/efi
|||
else
    ""
) +
|||
    
    echo "Deploying rootfs..."
    %(deploy_method)s /

    echo "Copying content from rootfs..."
    !mkdir -p "%(temp_dir)s/u-boot"
    copy-out /usr/lib/u-boot/ "%(temp_dir)s"
    copy-out /boot/extlinux/extlinux.conf "%(temp_dir)s/"

    echo "Updating files with disk info..."
    blkid /dev/sda1 | grep "^UUID:" | cut -d " " -f 2 | xargs printf "UUID=%%s /config vfat defaults,x-systemd.automount 0 2\n" > "%(temp_dir)s/fstab"
||| % {
    deploy_method: (if std.endsWith(rootfs, ".tar")
    then
        "tar-in %(rootfs)s" % { rootfs: rootfs }
    else
        "copy-in %(rootfs)s/." % { rootfs: rootfs }
    ),
    temp_dir: temp_dir,
} +
(if efi
then
|||
    blkid /dev/sda2 | grep "^UUID:" | cut -d " " -f 2 | xargs printf "UUID=%%s /boot/efi vfat defaults,x-systemd.automount 0 2\n" >> "%(temp_dir)s/fstab"
||| % {
    temp_dir: temp_dir,
}
else
    ""
) +
|||
    blkid /dev/sda%(rootdev)d | grep "^UUID:" | cut -d " " -f 2 | xargs printf "UUID=%%s / ext4 defaults 0 1\n" >> "%(temp_dir)s/fstab"
    blkid /dev/sda%(rootdev)d | grep "^UUID:" | cut -d " " -f 2 > "%(temp_dir)s/rootfs_uuid"
    !sed -i "s/root=[^[:space:]]*/root=UUID=$(cat "%(temp_dir)s/rootfs_uuid")/g" "%(temp_dir)s/extlinux.conf"
    copy-in "%(temp_dir)s/fstab" /etc/
    copy-in "%(temp_dir)s/extlinux.conf" /boot/extlinux/

    echo "Shrinking rootfs..."
    unmount-all
    resize2fs-M /dev/sda%(rootdev)d
    tune2fs-l /dev/sda%(rootdev)d | cat > "%(temp_dir)s/tune2fs"
    !echo "resizepart %(rootdev)d" > "%(temp_dir)s/parted"
    !echo "$(( $(sgdisk -i %(rootdev)d "%(output)s" | grep "First sector:" | cut -d " " -f 3) * 512 + $(grep "Block count:" %(temp_dir)s/tune2fs | cut -d " " -f 3) * $(grep "Block size:" %(temp_dir)s/tune2fs | cut -d " " -f 3) ))B" >> "%(temp_dir)s/parted"
    !echo "yes" >> "%(temp_dir)s/parted"
    sync

    echo "Installing bootloader..."
    shutdown
    !cat "%(temp_dir)s/parted" | parted ---pretend-input-tty "%(output)s" > /dev/null 2>&1
    !truncate "--size=$(( ( $(sgdisk -i %(rootdev)d "%(output)s" | grep "Last sector:" | cut -d " " -f 3) + 34 ) * 512 ))" "%(output)s"
    !sgdisk -ge "%(output)s" > /dev/null 2>&1 || true
    !chmod +x "%(temp_dir)s/u-boot/%(product)s/setup.sh"
    !"%(temp_dir)s/u-boot/%(product)s/setup.sh" update_bootloader "%(output)s" 2> /dev/null
||| % {
    output: output,
    temp_dir: temp_dir,
    product: product,
    rootdev: rootdev(efi),
} +
(if efi
then
|||
    !sgdisk -A 2:set:2 -A 3:set:2 "%(output)s" > /dev/null || true
    !sfdisk -A "%(output)s" 2 3 > /dev/null
||| % {
    output: output,
}
else
|||
    !sgdisk -A 2:set:2 "%(output)s" > /dev/null || true
    !sfdisk -A "%(output)s" 2 > /dev/null
||| % {
    output: output,
}) +
|||

    echo "Cleaning up..."
    !rm -rf "%(temp_dir)s"
    !sync

    echo "Deploy succeed!"
||| % {
    output: output,
    temp_dir: temp_dir,
}

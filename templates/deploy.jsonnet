local product_partition_table_type = import "lib/product_partition_table_type.libjsonnet";

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
    !sgdisk -A 2:set:2 -A 3:set:2 "%(output)s" || true
    !sfdisk -A "%(output)s" 2 3

    echo "Formatting partitions..."
    mkfs vfat /dev/sda1 label:config
    mkfs vfat /dev/sda2 label:efi
    mkfs ext4 /dev/sda3 label:rootfs

    echo "Mounting partitions..."
    mount /dev/sda3 /
    mkdir-p /config
    mount /dev/sda1 /config
    mkdir-p /boot/efi
    mount /dev/sda2 /boot/efi
||| % {
    output: output,
}
else
|||
    part-add /dev/sda primary 65536 -34
    !sgdisk -A 2:set:2 "%(output)s" || true
    !sfdisk -A "%(output)s" 2

    echo "Formatting partitions..."
    mkfs vfat /dev/sda1 label:config
    mkfs ext4 /dev/sda2 label:rootfs

    echo "Mounting partitions..."
    mount /dev/sda2 /
    mkdir-p /config
    mount /dev/sda1 /config
||| % {
    output: output,
}) +
|||
    
    echo "Deploying rootfs..."
    tar-in %(rootfs)s /

    echo "Copying content from rootfs..."
    !mkdir -p "%(temp_dir)s/u-boot"
    copy-out /usr/lib/u-boot/ "%(temp_dir)s"
    copy-out /boot/extlinux/extlinux.conf "%(temp_dir)s/"

    echo "Updating files with disk info..."
    blkid /dev/sda1 | grep "^UUID:" | cut -d ' ' -f 2 | xargs printf "UUID=%%s /config vfat defaults,x-systemd.automount 0 2\n" > "%(temp_dir)s/fstab"
||| % {
    rootfs: rootfs,
    temp_dir: temp_dir,
} +
(if efi
then
|||
    blkid /dev/sda2 | grep "^UUID:" | cut -d ' ' -f 2 | xargs printf "UUID=%%s /boot/efi vfat defaults,x-systemd.automount 0 2\n" >> "%(temp_dir)s/fstab"
    blkid /dev/sda3 | grep "^UUID:" | cut -d ' ' -f 2 | xargs printf "UUID=%%s / ext4 defaults 0 1\n" >> "%(temp_dir)s/fstab"
    blkid /dev/sda3 | grep "^UUID:" | cut -d ' ' -f 2 > "%(temp_dir)s/rootfs_uuid"
||| % {
    temp_dir: temp_dir,
}
else
|||
    blkid /dev/sda2 | grep "^UUID:" | cut -d ' ' -f 2 | xargs printf "UUID=%%s / ext4 defaults 0 1\n" >> "%(temp_dir)s/fstab"
    blkid /dev/sda2 | grep "^UUID:" | cut -d ' ' -f 2 > "%(temp_dir)s/rootfs_uuid"
||| % {
    temp_dir: temp_dir,
}) +
|||
    !sed -i "s/root=[^[:space:]]*/root=UUID=$(cat "%(temp_dir)s/rootfs_uuid")/g" "%(temp_dir)s/extlinux.conf"
    copy-in "%(temp_dir)s/fstab" /etc/
    copy-in "%(temp_dir)s/extlinux.conf" /boot/extlinux/

    echo "Installing bootloader..."
    !chmod +x "%(temp_dir)s/u-boot/%(product)s/setup.sh"
    !"%(temp_dir)s/u-boot/%(product)s/setup.sh" update_bootloader "%(output)s"

    echo "Cleaning up..."
    !rm -rf "%(temp_dir)s"

    echo "Deploy succeed!"
    sync
||| % {
    output: output,
    temp_dir: temp_dir,
    product: product,
}

local product_partition_table_type = import "../configs/product_partition_table_type.libjsonnet";
local product_firmware_type = import "../configs/product_firmware_type.libjsonnet";
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
    partition_table_type = product_partition_table_type(product),
    sdboot = false,
    suite,
    sector_size = 512,
) |||
    #!/usr/bin/env -S guestfish -f

    !echo "Image generation started at $(date)."
    echo "Allocating image file..."
    !rm -f "%(output)s"
    disk-create "%(output)s" raw 9G
    add-drive "%(output)s" format:raw discard:besteffort blocksize:%(sector_size)d
    run

    echo "Creating partition table..."
    part-init /dev/sda %(partition_table_type)s
    part-add /dev/sda primary 32768 65535
||| % {
    output: output,
    partition_table_type: partition_table_type,
    sector_size: sector_size,
} +
(if efi
then
|||
    part-add /dev/sda primary 65536 679935
    part-set-bootable /dev/sda 2 true
    part-add /dev/sda primary 679936 -34
    part-set-bootable /dev/sda 3 true
|||
else
|||
    part-add /dev/sda primary 65536 -34
    part-set-bootable /dev/sda 2 true
|||
) +
(if efi && partition_table_type == "gpt"
then
|||
    part-set-gpt-type /dev/sda 2 C12A7328-F81F-11D2-BA4B-00A0C93EC93B
    part-set-gpt-attributes /dev/sda 2 4
    part-set-gpt-attributes /dev/sda 3 4
|||
else
    ""
) +
|||

    echo "Formatting partitions..."
    mkfs vfat /dev/sda1 label:config
||| +
(if efi
then
|||
    mkfs vfat /dev/sda2 label:efi
|||
else
    ""
) +
(if suite == "bullseye"
then
|||
    mkfs ext4 /dev/sda%(rootdev)d features:^orphan_file label:rootfs
|||
else
|||
    mkfs ext4 /dev/sda%(rootdev)d label:rootfs
|||
) % {
    rootdev: rootdev(efi),
} +
|||

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
    %(deploy_method)s

    echo "Copying content from rootfs..."
    !mkdir -p "%(temp_dir)s"
    copy-out /etc/kernel/cmdline "%(temp_dir)s"
    copy-out /boot/extlinux/extlinux.conf "%(temp_dir)s"
|||  % {
    deploy_method: (if std.endsWith(rootfs, ".tar")
    then
        "tar-in %(rootfs)s / xattrs:true" % { rootfs: rootfs }
    else
        "copy-in %(rootfs)s/. /" % { rootfs: rootfs }
    ),
    temp_dir: temp_dir,
} +
(if product_firmware_type(product) == "u-boot"
then
|||
    !mkdir -p "%(temp_dir)s/u-boot"
    copy-out /usr/lib/u-boot/ "%(temp_dir)s"
||| % {
    temp_dir: temp_dir,
}
else
    ""
) +
(if sdboot || product_firmware_type(product) == "edk2"
then
|||
    !mkdir -p "%(temp_dir)s/entries"
    copy-out /boot/efi/loader/entries "%(temp_dir)s"
||| % {
    temp_dir: temp_dir,
}
else
    ""
) +
|||

    echo "Updating files with disk info..."
    blkid /dev/sda1 | grep "^UUID:" | cut -d " " -f 2 | xargs printf "UUID=%%s /config vfat defaults,x-systemd.automount,fmask=0077,dmask=0077 0 2\n" > "%(temp_dir)s/fstab"
||| % {
    temp_dir: temp_dir,
} +
(if efi
then
|||
    blkid /dev/sda2 | grep "^UUID:" | cut -d " " -f 2 | xargs printf "UUID=%%s /boot/efi vfat defaults,x-systemd.automount,fmask=0077,dmask=0077 0 2\n" >> "%(temp_dir)s/fstab"
||| % {
    temp_dir: temp_dir,
}
else
    ""
) +
|||
    blkid /dev/sda%(rootdev)d | grep "^UUID:" | cut -d " " -f 2 | xargs printf "UUID=%%s / ext4 defaults 0 1\n" >> "%(temp_dir)s/fstab"
    blkid /dev/sda%(rootdev)d | grep "^UUID:" | cut -d " " -f 2 > "%(temp_dir)s/rootfs_uuid"
    !sed -i -E -e "s/([[:space:]]*root=[^[:space:]]*[[:space:]]*)/ /g" -e "s/(append[[:space:]]+)/append root=UUID=$(cat "%(temp_dir)s/rootfs_uuid") /g" "%(temp_dir)s/extlinux.conf"
    !sed -i -E -e "s/([[:space:]]*root=[^[:space:]]*[[:space:]]*)/ /g" -e "s/^/root=UUID=$(cat "%(temp_dir)s/rootfs_uuid") /g" "%(temp_dir)s/cmdline"
    copy-in "%(temp_dir)s/fstab" /etc/
    copy-in "%(temp_dir)s/extlinux.conf" /boot/extlinux/
    copy-in "%(temp_dir)s/cmdline" /etc/kernel/
||| % {
    temp_dir: temp_dir,
    rootdev: rootdev(efi),
} +
(if sdboot || product_firmware_type(product) == "edk2"
then
|||
    !sed -i -E -e "s/([[:space:]]*root=[^[:space:]]*[[:space:]]*)/ /g" -e "s/(options[[:space:]]*)/options root=UUID=$(cat "%(temp_dir)s/rootfs_uuid") /g" %(temp_dir)s/entries/*.conf
    copy-in "%(temp_dir)s/entries" /boot/efi/loader/
||| % {
    temp_dir: temp_dir,
}
else
    ""
) +
(if sector_size == 512
then
|||

    echo "Shrinking rootfs..."
    unmount-all
    resize2fs-M /dev/sda%(rootdev)d
    tune2fs-l /dev/sda%(rootdev)d | cat > "%(temp_dir)s/tune2fs"
    !echo "resizepart %(rootdev)d" > "%(temp_dir)s/parted"
    !echo "$(( $(sgdisk -i %(rootdev)d "%(output)s" | grep "First sector:" | cut -d " " -f 3) * %(sector_size)d + $(grep "Block count:" %(temp_dir)s/tune2fs | cut -d " " -f 3) * $(grep "Block size:" %(temp_dir)s/tune2fs | cut -d " " -f 3) ))B" >> "%(temp_dir)s/parted"
    !echo "yes" >> "%(temp_dir)s/parted"
    sync
    shutdown
    !cat "%(temp_dir)s/parted" | parted ---pretend-input-tty "%(output)s" > /dev/null 2>&1
    !truncate "--size=$(( ( $(sgdisk -i %(rootdev)d "%(output)s" | grep "Last sector:" | cut -d " " -f 3) + 34 ) * %(sector_size)d ))" "%(output)s"
||| % {
    output: output,
    temp_dir: temp_dir,
    rootdev: rootdev(efi),
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
)
else
    ""
)+
(if product_firmware_type(product) == "u-boot"
then
|||

    echo "Installing bootloader..."
    shutdown
    !chmod +x "%(temp_dir)s/u-boot/%(product)s/setup.sh"
    !"%(temp_dir)s/u-boot/%(product)s/setup.sh" update_bootloader "%(output)s" %(sector_size)d 2> /dev/null
||| % {
    output: output,
    temp_dir: temp_dir,
    product: product,
    sector_size: sector_size,
}
else
    ""
) +
|||

    echo "Enlarging rootfs to the underlying block device..."
    shutdown
    add-drive "%(output)s" format:raw discard:besteffort blocksize:%(sector_size)d
    run
    resize2fs /dev/sda%(rootdev)d
    shutdown

    echo "Cleaning up..."
    !rm -rf "%(temp_dir)s"
    !sync

    echo "Deploy succeed!"
||| % {
    output: output,
    rootdev: rootdev(efi),
    temp_dir: temp_dir,
    sector_size: sector_size,
} +
'!echo "Image generation finished at $(date)."'

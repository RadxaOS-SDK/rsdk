function(create_efi_part, temp_dir, efi_boot, rootfs_type, root_part_num)
|||
    echo "Updating files with disk info..."
||| +
|||
    blkid /dev/sda1 | grep "^UUID:" | cut -d " " -f 2 | xargs printf "UUID=%%s /config vfat defaults,x-systemd.automount,fmask=0077,dmask=0077 0 2\n" > "%(temp_dir)s/fstab"
||| % {
    temp_dir: temp_dir,
} +
(if create_efi_part
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
    blkid /dev/sda%(root_part_num)d | grep "^UUID:" | cut -d " " -f 2 | xargs printf "UUID=%%s / %(rootfs_type)s defaults 0 1\n" >> "%(temp_dir)s/fstab"
    blkid /dev/sda%(root_part_num)d | grep "^UUID:" | cut -d " " -f 2 > "%(temp_dir)s/rootfs_uuid"
    !sed -i -E -e "s/([[:space:]]*root=[^[:space:]]*[[:space:]]*)/ /g" -e "s/(append[[:space:]]+)/append root=UUID=$(cat "%(temp_dir)s/rootfs_uuid") /g" "%(temp_dir)s/extlinux.conf"
    !sed -i -E -e "s/([[:space:]]*root=[^[:space:]]*[[:space:]]*)/ /g" -e "s/^/root=UUID=$(cat "%(temp_dir)s/rootfs_uuid") /g" "%(temp_dir)s/cmdline"
    copy-in "%(temp_dir)s/fstab" /etc/
    chown 0 0 /etc/fstab
    copy-in "%(temp_dir)s/extlinux.conf" /boot/extlinux/
    chown 0 0 /boot/extlinux/extlinux.conf
    copy-in "%(temp_dir)s/cmdline" /etc/kernel/
    chown 0 0 /etc/kernel/cmdline
||| % {
    temp_dir: temp_dir,
    root_part_num: root_part_num,
    rootfs_type: rootfs_type,
} +
(if efi_boot
then
|||
    !sed -i -E -e "s/([[:space:]]*root=[^[:space:]]*[[:space:]]*)/ /g" -e "s/(options[[:space:]]*)/options root=UUID=$(cat "%(temp_dir)s/rootfs_uuid") /g" %(temp_dir)s/entries/*.conf
    copy-in "%(temp_dir)s/entries" /boot/efi/loader/
    chown 0 0 /boot/efi/loader/entries
||| % {
    temp_dir: temp_dir,
}
else
    ""
) +
"\n"

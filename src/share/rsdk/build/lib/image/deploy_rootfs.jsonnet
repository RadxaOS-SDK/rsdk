function(rootfs, temp_dir, efi_boot, firmware_type)
|||
    echo "Deploying rootfs..."
||| +
|||
    %(deploy_method)s

    echo "Copying content from rootfs..."
    !mkdir -p "%(temp_dir)s"
    copy-out /etc/kernel/cmdline "%(temp_dir)s"
    copy-out /boot/extlinux/extlinux.conf "%(temp_dir)s"
||| % {
    deploy_method: (if std.endsWith(rootfs, ".tar")
    then
        "tar-in %(rootfs)s / xattrs:true" % { rootfs: rootfs, }
    else
|||
    echo "[NOTICE] rootfs is a directory."
    echo "[NOTICE] You will encounter 'Permission denied' error"
    echo "[NOTICE] if the script is not running in escalated privilege."
||| +
        "copy-in %(rootfs)s/. /" % { rootfs: rootfs, }
    ),
    temp_dir: temp_dir,
} +
(if firmware_type == "u-boot"
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
(if efi_boot
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
"\n"

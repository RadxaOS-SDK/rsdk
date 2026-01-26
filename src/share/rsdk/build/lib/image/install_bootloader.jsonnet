function(firmware_type, output, temp_dir, product, sector_size)
(if firmware_type == "u-boot"
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
)

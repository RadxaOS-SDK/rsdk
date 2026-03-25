function(output, sector_size, image_size)
|||
    #!/usr/bin/env -S guestfish -f

    !echo "Image generation started at $(date)."
    echo "Allocating image file..."
    !rm -f "%(output)s"
    disk-create "%(output)s" raw "%(image_size)s"
    add-drive "%(output)s" format:raw discard:besteffort blocksize:%(sector_size)d
    run

||| % {
    output: output,
    sector_size: sector_size,
    image_size: image_size,
}

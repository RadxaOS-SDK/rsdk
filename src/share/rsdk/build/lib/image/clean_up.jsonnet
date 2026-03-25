function(temp_dir)
|||
    echo "Cleaning up..."
    !rm -rf "%(temp_dir)s"
    !sync

    echo "Deploy succeed!"
||| % {
    temp_dir: temp_dir,
} + // end with a normal string to avoid double new lines at the end
    '!echo "Image generation finished at $(date)."'

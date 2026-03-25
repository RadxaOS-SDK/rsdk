<!-- cmdrun rsdk build --help -->

## Build RadxaOS image

When no suite or edition options is supplied, `rsdk-build` will use the product-specific default values, which are defined in `src/share/rsdk/configs/products.json` as the first element of the respective array.  
Using ROCK 3C as an example, if you want to build a CLI image for RadxaOS Bullseye, you can run the following command:

```bash
rsdk build rock-3c bullseye cli
```

## Mirror options

`rsdk build` supports changing both the Radxa APT repository (radxa-deb) and the Debian/Ubuntu upstream mirror:

- `-M <radxa-mirror>`: change Radxa APT mirror (radxa-deb). For example:

	```bash
	rsdk build -M https://mirrors.ustc.edu.cn/radxa-deb rock-3c
	```

	If you pass a third‑party radxa-deb mirror here, `rsdk` will **disable Radxa pkgs.json usage by default**, because those mirrors usually do not provide `pkgs.json`.

- `-m | --mirror <distro-mirror>`: change Debian/Ubuntu mirror. For example:

	```bash
	rsdk build -m https://mirrors.ustc.edu.cn rock-3c
	```

You can also use them together to change both Radxa and Debian/Ubuntu mirrors:

```bash
rsdk build \
	-M https://mirrors.ustc.edu.cn/radxa-deb \
	-m https://mirrors.ustc.edu.cn \
	rock-3c
```

## Radxa pkgs.json option

By default, when using the official Radxa repository (`https://radxa-repo.github.io/radxa-deb` and its variants), `rsdk` downloads and embeds Radxa `pkgs.json` metadata into the image.

For third‑party radxa-deb mirrors that do not provide `pkgs.json`, you may want to disable this behavior.

You can explicitly skip downloading and embedding `pkgs.json` by using:

```bash
rsdk build -P rock-3c
```

or:

```bash
rsdk build --no-pkgs-json rock-3c
```

This option is useful when you know the current mirror does not provide `pkgs.json`.

## RadxaOS output path

You can find the generated RadxaOS image as `out/${product}_${suite}_${edition}/output.img`.

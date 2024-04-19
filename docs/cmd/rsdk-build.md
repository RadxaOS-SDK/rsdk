<!-- cmdrun rsdk build --help -->

## Build RadxaOS image

When no suite or edition options is supplied, `rsdk-build` will use the product-specific default values, which are defined in `src/share/rsdk/configs/products.json` as the first element of the respective array.  
Using ROCK 3C as an example, if you want to build a CLI image for RadxaOS Bullseye, you can run the following command:

```bash
rsdk build rock-3c bullseye cli
```

## RadxaOS output path

you can find the generated RadxaOS image as `out/${product}_${suite}_${edition}/output.img`.

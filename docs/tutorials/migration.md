# Migrating from old toolchain

## `rbuild`

`rsdk build` is the `rbuild` replacement.
It uses the same argument ordering, and support similar input values.

When no suite or edition is supplied, `rsdk build` will use the value defined in `src/share/rsdk/configs/products.json` instead of `bullseye` `cli`.

Not all `rbuild` options are supported by `rsdk build`.
Please check the command help for more details.

`.rbuild-config` file is now replaced by `devenv.local.nix`, and option names are adjusted.
You can check `devenv.local.nix.example` for syntax.

# Migrating from old toolchain

## `rbuild`

`rsdk build` is the `rbuild` replacement.
It uses the same argument ordering, and support similar input values.

When no suite or edition is supplied, `rsdk build` will use the value defined in `src/share/rsdk/configs/products.json` instead of `bullseye` `cli`.

Not all `rbuild` options are supported by `rsdk build`.
Please check the command help for more details.

`.rbuild-config` file is now replaced by [`devenv.local.nix`](global_options.md), and option names are adjusted.
You can check `devenv.local.nix.example` for syntax.

### `rbuild json`

This subcommand is replaced by configuration files under `src/share/rsdk/configs`.

### `rbuild shrink-image`

This subcommand is no longer needed, as now image shrinking is no longer a root operation, and comes standard.

### `rbuild write-image`

`rsdk write-image` is the `rbuild write-image` replacement.
It uses the same argument ordering.

# Run `rsdk` natively

```admonish warning
This is not a well supported or tested installation method.

When you have issues, please check the source code for up-to-date runtime dependencies.

We do not answer support questions related to this type of installation.
```

To run `rsdk` natively, you will ideally need an Ubuntu system, as it is the base system used in Dev Container.

Please first install [`devenv`](https://devenv.sh/getting-started/#2-install-cachix) on your system.

Optionally you can setup [`direnv`](https://devenv.sh/automatic-shell-activation/), then run `direnv allow` within the project folder to enable it.

You can then run `devenv shell` to enter the development shell. This shell will manipulate your PATH to have the development dependency available.

If you have `direnv` setup, you don't have to run the above command when you enter the project directory to use the SDK. However, the `direnv` shell lacks `starship` integration as well as `rsdk` auto completion, as it only saves the environmental variables.

There are some additional system configurations and packages that are currently not managed by `devenv`. They are mostly covered by `install_native_dependency` function in `rsdk-setup`.

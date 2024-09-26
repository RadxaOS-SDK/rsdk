# Run `rsdk` with devcontainer alone

This is similar to how we build system images in the CI pipelines.

First, please install the required dependencies:

```bash
sudo apt-get update
sudo apt-get install git qemu-user-static binfmt-support
sudo apt-get install npm docker.io
sudo usermod -a -G docker $USER
```

If you were not in the `docker` group before, you will need to log out and log back in.

For SSH, simple disconnect the current session and reconnect.

Then clone the project with `git` and install `devcontainer`:

```bash
git clone --recurse-submodules https://github.com/RadxaOS-SDK/rsdk.git
cd rsdk
npm install @devcontainers/cli
export PATH="$PWD/src/bin:$PWD/node_modules/.bin:$PATH"
rsdk devcon up
rsdk devcon
```

You are now inside the `rsdk`'s `devcontainer` shell.

The following recording demostates how to set up `rsdk` and build an image on a fresh Debian 12 install:

[![asciicast](https://asciinema.org/a/A064TrKbZsXncNkEveIUFAGvp.svg)](https://asciinema.org/a/A064TrKbZsXncNkEveIUFAGvp)

## Common issues

1. devcontainer setup paused with `You might be rate limited by GitHub.` message

   You might be rate limited by GitHub. Please follow the instruction listed in the output.

2. Failed to launch devcontainer.

   Please edit `.devcintainer/devcontainer.json`, and adjust `runArgs` property.

# Run `rsdk` with Visual Studio Code & devcontainer


```admonish info
This is the preferred method to run `rsdk`.
```

First, please install the required dependencies:

```bash
sudo apt-get update
sudo apt-get install git qemu-user-static binfmt-support
```

Then follow Visual Studio Code's documentation to:

1. [Install Visual Studio Code](https://code.visualstudio.com/docs/setup/setup-overview)
2. [Setup devcontainer](https://code.visualstudio.com/docs/devcontainers/containers)

Then clone the project with `git`:

```bash
git clone --recurse-submodules https://github.com/RadxaOS-SDK/rsdk.git
```

Open the project in Visual Studio Code. A notification will pop up on the corner
asking if you want to reopen in devcontainer. Click `yes` and wait for the container
to be set up.

This can be combined with VS Code remote development extension to run rsdk in other systems.

## Common issues

1. devcontainer setup paused with `You might be rate limited by GitHub.` message

   You might be rate limited by GitHub. Please follow the instruction listed in the output.

2. Failed to launch devcontainer.

   Please edit `.devcintainer/devcontainer.json`, and adjust `runArgs` property.

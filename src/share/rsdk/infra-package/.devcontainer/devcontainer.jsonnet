function(
    devcontainer_image,
) std.manifestJson({
    "customizations": {
        "vscode": {
            "extensions": [
                "mkhl.direnv",
                "github.vscode-github-actions",
                "grafana.vscode-jsonnet",
                "ms-vscode.cpptools-extension-pack",
                "ms-vscode.makefile-tools",
                "vivaxy.vscode-conventional-commits"
            ],
            "settings": {
                "terminal.integrated.defaultProfile.linux": "bash"
            }
        }
    },
    "features": {
        "ghcr.io/devcontainers/features/nix:1": {
            "extraNixConfig": [
                "experimental-features = nix-command flakes",
                // Uncomment below to speed up container building in China
                // "substituters = https://mirrors.ustc.edu.cn/nix-channels/store https://devenv.cachix.org https://cache.nixos.org",
                "trusted-users = root vscode"
            ],
            "packages": [
                "cachix",
                "direnv",
                "devenv"
            ],
            "useAttributePath": true,
            "version": "latest"
        }
    },
    "image": "mcr.microsoft.com/devcontainers/base:bullseye",
    "mounts": [
        {
            "source": "${localWorkspaceFolder}/.devcontainer/.devenv",
            "target": "${containerWorkspaceFolder}/.devenv",
            "type": "bind"
        },
        {
            "source": "${localWorkspaceFolder}/.devcontainer/.direnv",
            "target": "${containerWorkspaceFolder}/.direnv",
            "type": "bind"
        },
        {
            "source": "/var/run/docker.sock",
            "target": "/var/run/docker.sock",
            "type": "bind"
        }
    ],
    "overrideCommand": true,
    "runArgs": [
        // https://github.com/moby/moby/issues/27195#issuecomment-1410745778
        "--ulimit",
        "nofile=1024:524288",
        // Docker gid is 118
        "--group-add",
        "118"
    ],
    "updateContentCommand": "make devcontainer_setup",
    "workspaceMount": "source=${localWorkspaceFolder}/..,target=/workspaces,type=bind,consistency=cached"
})

function() std.manifestYamlDoc(
    {
        name: "Create release",
        "run-name": "${{ inputs.update && 'Update submodule' || '' }}${{ inputs.update && inputs.release && ' & ' || '' }}${{ inputs.release && 'Release new version' }}${{ !inputs.update && !inputs.release && 'Test for new release' || '' }}",
        on: {
            workflow_dispatch: {
                inputs: {
                    update: {
                        description: "Update submodule",
                        type: "boolean",
                        required: true,
                        default: false,
                    },
                    release: {
                        description: "Release new version",
                        type: "boolean",
                        required: true,
                        default: true,
                    },
                },
            },
        },
        permissions: {},
        jobs: {
            release: {
                "runs-on": "ubuntu-latest",
                permissions: {
                    contents: "write",
                },
                steps: [
                    {
                        name: "Checkout",
                        uses: "actions/checkout@v5",
                        with: {
                            "fetch-depth": 0,
                            submodules: "recursive",
                            token: "${{secrets.GIT_PUSH_TOKEN}}",
                        },
                    },
                    {
                        name: "Update submodules",
                        "if": "github.event.inputs.update == 'true'",
                        shell: "bash",
                        run: |||
                            git config user.name "github-actions[bot]"
                            git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
                            git submodule update --remote
                            if git diff --quiet; then
                                echo "Submodules are the latest. Nothing to update."
                                exit
                            fi
                            git add .
                            git commit -m "chore: update submodules"
                        |||,
                    },
                    {
                        name: "Set up QEMU Emulation",
                        uses: "docker/setup-qemu-action@v3",
                        with: {
                            image: "tonistiigi/binfmt:latest",
                        },
                    },
                    {
                        name: "Test",
                        uses: "devcontainers/ci@v0.3",
                        with: {
                            push: "never",
                            runCmd: |||
                                set -euo pipefail
                                sudo apt-get update
                                sudo apt-get install --no-install-recommends -y git-buildpackage
                                export DEBEMAIL="dev@radxa.com"
                                export DEBFULLNAME='"Radxa Computer Co., Ltd"'
                                git config user.name "github-actions[bot]"
                                git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
                                make dch
                                make test deb
                            |||,
                        },
                    },
                    {
                        name: "Push",
                        "if": "github.event.inputs.release == 'true'",
                        shell: "bash",
                        run: |||
                            git push
                        |||,
                    },
                ],
            },
        }
    },
    quote_keys=false,
)

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
            "check-runner": {
                "runs-on": "ubuntu-latest",
                outputs: {
                    runner: "${{ steps.env.outputs.runner }}",
                    build_env: "${{ steps.env.outputs.build_env }}",
                },
                steps: [
                    {
                        name: "Checkout",
                        uses: "actions/checkout@v7",
                    },
                    {
                        name: "Determine runner and build env",
                        id: "env",
                        shell: "bash",
                        run: |||
                            if [[ -f .github/local/runner ]]; then
                                runner="$(head -1 .github/local/runner)"
                                echo "runner=$runner" | tee -a "$GITHUB_OUTPUT"
                            else
                                runner="ubuntu-latest"
                                echo "runner=$runner" | tee -a "$GITHUB_OUTPUT"
                            fi
                            if echo "$runner" | grep -q arm; then
                                echo "build_env=host" | tee -a "$GITHUB_OUTPUT"
                            else
                                echo "build_env=devcontainer" | tee -a "$GITHUB_OUTPUT"
                            fi
                        |||,
                    },
                ],
            },
            release: {
                "runs-on": "${{ needs.check-runner.outputs.runner }}",
                needs: "check-runner",
                permissions: {
                    contents: "write",
                },
                steps: [
                    {
                        name: "Checkout",
                        uses: "actions/checkout@v7",
                        with: {
                            "fetch-depth": 0,
                            submodules: "recursive",
                            token: "${{secrets.CODE_WRITE_TOKEN}}",
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
                        "if": "${{ needs.check-runner.outputs.build_env != 'host' }}",
                        uses: "docker/setup-qemu-action@v4",
                        with: {
                            image: "tonistiigi/binfmt:latest",
                        },
                    },
                    {
                        name: "Test",
                        "if": "${{ needs.check-runner.outputs.build_env == 'devcontainer' }}",
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
                        name: "Test",
                        "if": "${{ needs.check-runner.outputs.build_env == 'host' }}",
                        shell: "bash",
                        run: |||
                            set -euo pipefail
                            sudo apt-get update
                            sudo apt-get install --no-install-recommends -y git-buildpackage
                            sudo apt-get build-dep . -y
                            export DEBEMAIL="dev@radxa.com"
                            export DEBFULLNAME='"Radxa Computer Co., Ltd"'
                            git config user.name "github-actions[bot]"
                            git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
                            make dch
                            make test deb
                        |||,
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

function() std.manifestYamlDoc(
    {
        name: "Create release",
        on: {
            workflow_dispatch: {},
        },
        permissions: {},
        jobs: {
            build: {
                "runs-on": "ubuntu-latest",
                permissions: {
                    contents: "write",
                },
                steps: [
                    {
                        name: "Checkout",
                        uses: "actions/checkout@v4",
                        with: {
                            "fetch-depth": 0,
                            submodules: "recursive",
                            token: "${{secrets.GIT_PUSH_TOKEN}}",
                        },
                    },
                    {
                        name: "Enable Multiarch",
                        uses: "RadxaYuntian/action-apt@master",
                        with: {
                            arch: "arm64",
                        },
                    },
                    {
                        name: "Create release commit",
                        shell: "bash",
                        run: |||
                            sudo apt-get update
                            sudo apt-get install --no-install-recommends -y git-buildpackage
                            export DEBEMAIL="dev@radxa.com"
                            export DEBFULLNAME='"Radxa Computer Co., Ltd"'
                            git config user.name "github-actions[bot]"
                            git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
                            make dch
                        |||,
                    },
                    {
                        name: "Test",
                        shell: "bash",
                        run: |||
                            make devcontainer_setup
                            make test deb
                        |||,
                    },
                    {
                        name: "Test",
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

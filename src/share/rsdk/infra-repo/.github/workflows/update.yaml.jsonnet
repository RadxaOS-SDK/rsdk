function(
    git_rev,
) std.manifestYamlDoc(
    {
        name: "Update package version info",
        on: {
            repository_dispatch: {
                types: [
                    "new_package_release"
                ],
            },
            workflow_dispatch: {},
            pull_request: {
                paths: [
                    ".github/workflows/update.yaml",
                ]
            },
        },
        permissions: {},
        concurrency: {
            group: "${{ github.workflow }}-${{ github.ref }}",
            "cancel-in-progress": true,
        },
        jobs: {
            update: {
                "runs-on": "ubuntu-latest",
                permissions: {
                    contents: "write",          // for git push
                },
                steps: [
                    {
                        name: "Secret tests",
                        uses: "actions/github-script@v8",
                        env: {
                            SECRETS: "${{ toJSON(secrets) }}",
                        },
                        with: {
                            script: |||
                                const secrets = JSON.parse(process.env.SECRETS);
                                if (secrets.GPG_KEY === undefined || secrets.RADXA_APT_KEY_2024 === undefined) {
                                    core.setFailed('Required secrets are unset!');
                                }
                            |||,
                        },
                    },
                    {
                        name: "Checkout rsdk",
                        uses: "actions/checkout@v5",
                        with: {
                            repository: "RadxaOS-SDK/rsdk",
                            ref: "%(git_rev)s" % {git_rev: git_rev},
                        },
                    },
                    {
                        name: "Checkout current repo",
                        uses: "actions/checkout@v5",
                        with: {
                            path: ".infra-repo",
                            token: "${{secrets.GIT_PUSH_TOKEN}}",
                        },
                    },
                    {
                        name: "Update pkgs.json",
                        id: "build",
                        shell: "bash",
                        env: {
                            GH_TOKEN: "${{ secrets.GITHUB_TOKEN }}",
                        },
                        run: |||
                            pushd .infra-repo
                            if [[ "${{ github.repository }}" != *-test ]] && \
                                wget "https://raw.githubusercontent.com/${{ github.repository }}-test/main/pkgs.lock" -O pkgs.lock.new; then
                                mv pkgs.lock.new pkgs.lock
                                git add pkgs.lock
                            fi

                            ../src/bin/rsdk infra-pkg-snapshot
                            git add pkgs.json

                            if [[ -n "$(git status --porcelain)" ]]; then
                                git config --global user.name 'github-actions[bot]'
                                git config --global user.email '41898282+github-actions[bot]@users.noreply.github.com'
                                git commit -m "chore: update package snapshot"
                            fi
                            popd
                        |||,
                    },
                    {
                        name: "Commit package snapshot",
                        "if": "github.event_name != 'pull_request'",
                        shell: "bash",
                        run: |||
                            pushd .infra-repo
                            git push
                            popd
                        |||,
                    },
                ],
            },
        },
    },
    quote_keys=false,
)

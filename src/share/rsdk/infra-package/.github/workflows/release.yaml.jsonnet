function() std.manifestYamlDoc(
    {
        name: "Build & Release",
        on: {
            workflow_dispatch: {},
            merge_group: {},
            push: {
                branches: [
                    "main",
                    "gh-readonly-queue/main/*",
                ],
                "paths-ignore": [
                    "docs/**",
                    "theme/**",
                    "po/**",
                    "book.toml",
                    ".github/workflows/docs.yaml",
                ],
            },
            pull_request: {
                "paths-ignore": [
                    "docs/**",
                    "theme/**",
                    "po/**",
                    "book.toml",
                    ".github/workflows/docs.yaml",
                ],
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
                        uses: "actions/checkout@v6",
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
            build: {
                "runs-on": "${{ needs.check-runner.outputs.runner }}",
                needs: "check-runner",
                outputs: {
                    distro: "${{ steps.distro_check.outputs.distro }}",
                },
                steps: [
                    {
                        name: "Checkout",
                        uses: "actions/checkout@v6",
                        with: {
                            "fetch-depth": 0,
                            "fetch-tags": true,
                            submodules: "recursive",
                        },
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
                                git branch -m GITHUB_RUNNER || true
                                git branch -D main || true
                                git switch -c main || true
                                make dch
                                make test deb
                                git reset --hard HEAD~1
                                rm ../*.deb
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
                            git branch -m GITHUB_RUNNER || true
                            git branch -D main || true
                            git switch -c main || true
                            make dch
                            make test deb
                            git reset --hard HEAD~1
                            rm ../*.deb
                        |||,
                    },
                    {
                        name: "Build",
                        "if": "${{ needs.check-runner.outputs.build_env == 'devcontainer' }}",
                        uses: "devcontainers/ci@v0.3",
                        with: {
                            push: "never",
                            runCmd: |||
                                set -euo pipefail
                                make deb
                            |||,
                        },
                    },
                    {
                        name: "Build",
                        "if": "${{ needs.check-runner.outputs.build_env == 'host' }}",
                        shell: "bash",
                        run: |||
                            set -euo pipefail
                            make deb
                        |||,
                    },
                    {
                        name: "Workaround actions/upload-artifact#176",
                        id: "artifacts_path",
                        shell: "bash",
                        run: |||
                            echo "artifacts_path=$(realpath ..)" | tee -a "$GITHUB_OUTPUT"
                        |||,
                    },
                    {
                        name: "Upload artifacts",
                        uses: "actions/upload-artifact@v7",
                        with: {
                            name: "${{ github.event.repository.name }}",
                            path: |||
                                ${{ steps.artifacts_path.outputs.artifacts_path }}/*.deb
                            |||,
                        },
                    },
                    {
                        name: "Check if the latest version is releasable",
                        id: "distro_check",
                        shell: "bash",
                        run: |||
                            version="$(dpkg-parsechangelog -S Version)"
                            version="${version//\~/.}"
                            if [[ -n "$(git tag -l "$version")" ]]
                            then
                                echo "distro=UNRELEASED"
                            else
                                echo "distro=$(dpkg-parsechangelog -S Distribution)"
                            fi | tee -a "$GITHUB_OUTPUT"
                        |||,
                    },
                ],
            },
            release: {
                "runs-on": "${{ needs.check-runner.outputs.runner }}",
                needs: [
                    "check-runner",
                    "build",
                ],
                permissions: {
                    contents: "write",
                },
                "if": "${{ github.event_name != 'pull_request' && needs.build.outputs.distro != 'UNRELEASED' }}",
                steps: [
                    {
                        name: "Checkout",
                        uses: "actions/checkout@v6",
                    },
                    {
                        name: "Download generated debs",
                        uses: "actions/download-artifact@v8",
                        with: {
                            name: "${{ github.event.repository.name }}",
                            path: ".artifacts",
                        },
                    },
                    {
                        name: "Prepare for release",
                        shell: "bash",
                        run: |||
                            version="$(dpkg-parsechangelog -S Version)"
                            version="${version//\~/.}"
                            {
                                echo "version=$version"
                                echo "changes<<EOF"
                                echo '```'
                                echo "$(dpkg-parsechangelog -S Changes)"
                                echo '```'
                                echo "EOF"
                            } | tee -a "$GITHUB_ENV"
                            echo "$version" | tee VERSION
                            if [[ -f pkg.conf.template ]]
                            then
                                sed "s/VERSION/$version/g" pkg.conf.template | tee pkg.conf
                            fi
                        |||,
                    },
                    {
                        name: "Release",
                        uses: "softprops/action-gh-release@v3",
                        with: {
                            tag_name: "${{ env.version }}",
                            body_path: "README.md",
                            token: "${{ secrets.GITHUB_TOKEN }}",
                            target_commitish: "${{ github.sha }}",
                            draft: false,
                            prerelease: false,
                            fail_on_unmatched_files: false,
                            files: |||
                                .artifacts/**/*.deb
                                pkg.conf
                                VERSION
                            |||,
                        },
                    },
                    {
                        name: "Append changelog",
                        uses: "softprops/action-gh-release@v3",
                        with: {
                            tag_name: "${{ env.version }}",
                            append_body: true,
                            body: |||
                                ## Changelog for ${{ env.version }}
                                ${{ env.changes }}
                            |||,
                        },
                    },
                    {
                        name: "Update Test repos",
                        uses: "RadxaOS-SDK/rsdk/.github/actions/infra-repo-update@main",
                        with: {
                            token: "${{ secrets.RSDK_APT_REPOSITORY_TOKEN }}",
                            "test-repo": true,
                        },
                    },
                ],
            },
        }
    },
    quote_keys=false,
)

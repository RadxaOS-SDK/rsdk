function() std.manifestYamlDoc(
    {
        name: "Build & Release",
        on: {
            workflow_dispatch: {},
            merge_group: {},
            push: {
                branches: [
                    "main",
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
            build: {
                "runs-on": "ubuntu-latest",
                outputs: {
                    distro: "${{ steps.distro_check.outputs.distro }}",
                },
                steps: [
                    {
                        name: "Checkout",
                        uses: "actions/checkout@v4",
                        with: {
                            "fetch-depth": 0,
                            "fetch-tags": true,
                            submodules: "recursive",
                        },
                    },
                    {
                        name: "Test",
                        shell: "bash",
                        run: |||
                            sudo apt-get update
                            sudo apt-get build-dep --no-install-recommends -y .
                            sudo apt-get install --no-install-recommends -y git-buildpackage
                            export DEBEMAIL="dev@radxa.com"
                            export DEBFULLNAME='"Radxa Computer Co., Ltd"'
                            git config user.name "github-actions[bot]"
                            git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
                            git branch -m GITHUB_RUNNER || true
                            git branch -D main || true
                            git switch -c main || true
                            make dch
                            make test all deb
                            git reset --hard HEAD~1
                        |||,
                    },
                    {
                        name: "Build",
                        shell: "bash",
                        run: |||
                            make all deb
                        |||,
                    },
                    {
                        name: "Workaround actions/upload-artifact#176",
                        id: "artifacts_path",
                        shell: "bash",
                        run: |||
                            echo "artifacts_path=$(realpath ..)" >> "$GITHUB_OUTPUT"
                        |||,
                    },
                    {
                        name: "Upload artifacts",
                        uses: "actions/upload-artifact@v4",
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
                                echo "distro=UNRELEASED" >> "$GITHUB_OUTPUT"
                            else
                                echo "distro=$(dpkg-parsechangelog -S Distribution)" >> "$GITHUB_OUTPUT"
                            fi
                        |||,
                    },
                ],
            },
            release: {
                "runs-on": "ubuntu-latest",
                needs: "build",
                permissions: {
                    contents: "write",
                },
                "if": "${{ github.event_name != 'pull_request' && needs.build.outputs.distro != 'UNRELEASED' }}",
                steps: [
                    {
                        name: "Checkout",
                        uses: "actions/checkout@v4",
                    },
                    {
                        name: "Download generated debs",
                        uses: "actions/download-artifact@v4",
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
                            echo "version=$version" >> $GITHUB_ENV
                            echo "changes<<EOF" >> $GITHUB_ENV
                            echo '```' >> $GITHUB_ENV
                            echo "$(dpkg-parsechangelog -S Changes)" >> $GITHUB_ENV
                            echo '```' >> $GITHUB_ENV
                            echo "EOF" >> $GITHUB_ENV
                            echo "$version" > VERSION
                            if [[ -f pkg.conf.template ]]
                            then
                                sed "s/VERSION/$version/g" pkg.conf.template > pkg.conf
                            fi
                        |||,
                    },
                    {
                        name: "Release",
                        uses: "softprops/action-gh-release@v2",
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
                        uses: "softprops/action-gh-release@v2",
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
                        uses: "radxa-repo/update-repo-action@main",
                        with: {
                            token: "${{ secrets.RADXA_APT_TEST_REPO_TOKEN }}",
                            "test-repo": true,
                        },
                    },
                ],
            },
        }
    },
    quote_keys=false,
)

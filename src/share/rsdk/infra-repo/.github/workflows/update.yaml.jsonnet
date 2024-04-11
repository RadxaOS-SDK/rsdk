function(
    pkg_org,
) std.manifestYamlDoc(
    {
        name: "Update packages",
        on: {
            repository_dispatch: {
                types: [
                    "new_package_release"
                ],
            },
            workflow_dispatch: {},
            workflow_run: {
                workflows: [
                    "Reset APT repo"
                ],
                types: [
                    "completed"
                ],
            },
        },
        jobs: {
            update: {
                "runs-on": "ubuntu-latest",
                steps: [
                    {
                        name: "Checkout",
                        uses: "actions/checkout@v4",
                        with: {
                            "fetch-depth": 0
                        },
                    },
                    {
                        name: "Rebase to main",
                        run: |||
                            git config --global user.name 'github-actions[bot]'
                            git config --global user.email '41898282+github-actions[bot]@users.noreply.github.com'
                            git switch gh-pages
                            git rebase -X theirs main
                        |||,
                    },
                    {
                        name: "Update packages",
                        uses: "radxa-repo/apt-repo-action@main",
                        with: {
                            token: "${{ secrets.GITHUB_TOKEN }}",
                            organization: pkg_org,
                        },
                    },
                    {
                        name: "Check for modified files",
                        id: "git-check",
                        run: |||
                            echo "modified=$([ -z "$(git status --porcelain)" ]; echo $?)" >> "$GITHUB_OUTPUT"
                        |||,
                    },
                    {
                        name: "Commit changes",
                        "if": "steps.git-check.outputs.modified == 1",
                        run: |||
                            cat << EOF | gpg --import
                            ${{ secrets.GPG_KEY }}
                            EOF
                            freight cache
                            git add .
                            git commit -m "Update packages"
                            git push -f
                        |||,
                    },
                ],
            },
        },
    },
    quote_keys=false,
)

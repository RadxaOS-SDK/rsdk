function() std.manifestYamlDoc(
    {
        name: "Reset APT repo",
        on: {
            repository_dispatch: {
                types: [
                    "reset_repo"
                ],
            },
            workflow_dispatch: {},
        },
        jobs: {
            reset: {
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
                        name: "Reset history",
                        run: |||
                            git branch gh-pages || true
                            git switch gh-pages
                            git reset --hard origin/main
                            git push --set-upstream origin -f gh-pages
                        |||,
                    },
                ],
            },
        },
    },
    quote_keys=false,
)

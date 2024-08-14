function(
    target,
) std.manifestYamlDoc(
    {
        name: "Deploy documentation",
        on: {
            workflow_dispatch: {},
            merge_group: {},
            push: {
                branches: [
                    "main",
                ],
                paths: [
                    "docs/**",
                    "theme/**",
                    "po/**",
                    "book.toml",
                    ".github/workflows/docs.yaml",
                ],
            },
            pull_request: {
                paths: [
                    "docs/**",
                    "theme/**",
                    "po/**",
                    "book.toml",
                    ".github/workflows/docs.yaml",
                ],
            },
        },
        permissions: {},
        concurrency: {
            group: "${{ github.workflow }}-${{ github.ref }}",
            "cancel-in-progress": true,
        },
        jobs: {
            build: {
                "runs-on": "ubuntu-latest",
                permissions: {
                    pages: "write",
                    "id-token": "write",
                },
                steps: [
                    {
                        name: "Checkout",
                        uses: "actions/checkout@v4",
                        with: {
                            "fetch-depth": 0,
                        },
                    },
                    {
                        name: "Setup mdBook",
                        uses: "peaceiris/actions-mdbook@v2",
                        with: {
                            "mdbook-version": "latest",
                        },
                    },
                    {
                        name: "Install mdbook plugins",
                        shell: "bash",
                        run: |||
                            plugins=(
                                mdbook-admonish
                                mdbook-linkcheck
                                mdbook-i18n-helpers
                                mdbook-toc
                                mdbook-cmdrun
                            )
                            for i in "${plugins[@]}"
                            do
                                cargo install "$i"
                            done
                        |||,
                    },
                    {
                        name: "Build",
                        shell: "bash",
                        run: |||
                            mdbook build
                            for po_lang in zh-CN
                            do
                                POT_CREATION_DATE=$(grep --max-count 1 '^"POT-Creation-Date:' po/$po_lang.po | sed -E 's/".*: (.*)\\n"/\1/')
                                if [[ $POT_CREATION_DATE == "" ]]; then
                                    POT_CREATION_DATE=now
                                fi
                                echo "::group::Building $po_lang translation as of $POT_CREATION_DATE"
                                rm -r docs/
                                git restore --source "$(git rev-list -n 1 --before "$POT_CREATION_DATE" @)" docs/

                                # Set language and adjust site URL. Clear the redirects
                                # since they are in sync with the source files, not the
                                # translation.
                                MDBOOK_BOOK__LANGUAGE=$po_lang \
                                MDBOOK_OUTPUT__HTML__SITE_URL=/%(target)s/$po_lang/ \
                                MDBOOK_OUTPUT__HTML__REDIRECT='{}' \
                                mdbook build -d book/$po_lang
                                mv book/$po_lang/html book/html/$po_lang
                                echo "::endgroup::"
                            done
                        ||| % {target: target},
                    },
                    {
                        name: "Setup Pages",
                        uses: "actions/configure-pages@v5",
                    },
                    {
                        name: "Upload artifact",
                        uses: "actions/upload-pages-artifact@v3",
                        with: {
                            path: "./book/html",
                        },
                    },
                    {
                        name: "Deploy to GitHub Pages",
                        uses: "actions/deploy-pages@v4",
                        "if": "github.event_name != 'pull_request'",
                    },
                ],
            },
        }
    },
    quote_keys=false,
)

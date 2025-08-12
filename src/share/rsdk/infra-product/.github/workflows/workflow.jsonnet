local product_data = import "../../../configs/product_data.libjsonnet";

local release_info = function(variant) if variant == "release"
then
    {
        name: "b${{ github.run_number }} (rsdk)",
        tag_name: "rsdk-b${{ github.run_number }}",
        body_path: "README.md",
    }
else if variant == "test"
then
    {
        name: "t${{ github.run_number }} (rsdk)",
        tag_name: "rsdk-t${{ github.run_number }}",
        body: "This is a test build for internal development.\nOnly use when specifically instructed by Radxa support.\n",
    }
else
    {};

function(
    target,
    variant,
) std.manifestYamlDoc(
    {
        name: "Build image for %(variant)s channel" % {variant: variant},
        on: {
            workflow_dispatch: {}
        },
        env: {
            GH_TOKEN: "${{ github.token }}"
        },
        jobs: {
            prepare_release: {
                "runs-on": "ubuntu-latest",
                steps: [
                    {
                        name: "Checkout",
                        uses: "actions/checkout@v5",
                        with: {
                            "fetch-depth": 0,
                            "fetch-tags": true,
                        },
                    },
                    {
                        name: "Check for existing releases",
                        run: |||
                            TAG="%(tag_name)s"
                            if git show-ref --tags --verify --quiet "refs/tags/${TAG}"; then
                                echo "Release ${TAG} exists."
                                exit 1
                            fi
                        ||| % {tag_name: release_info(variant).tag_name},
                    },
                    {
                        name: "Generate changelog",
                        uses: "radxa-repo/rbuild-changelog@main",
                        with: {
                            product: target
                        }
                    },
                    {
                        name: "Query product info",
                        id: "query",
                        uses: "RadxaOS-SDK/rsdk/.github/actions/query@main",
                        with: {
                            product: target
                        }
                    },
                    {
                        name: "Create empty release",
                        id: "release",
                        uses: "softprops/action-gh-release@v2",
                        with: {
                            token: "${{ secrets.GITHUB_TOKEN }}",
                            target_commitish: "main",
                            draft: false,
                            prerelease: true,
                            files: ".changelog/changelog.md",
                        } + release_info(variant),
                    }
                ],
                outputs: {
                    release_id: "${{ steps.release.outputs.id }}",
                    suites: "${{ steps.query.outputs.suites }}",
                    editions: "${{ steps.query.outputs.editions }}",
                }
            },
            build: {
                "runs-on": "ubuntu-22.04",
                needs: "prepare_release",
                strategy: {
                    matrix: {
                        product: [ target ],
                        suite: "${{ fromJSON(needs.prepare_release.outputs.suites )}}",
                        edition: "${{ fromJSON(needs.prepare_release.outputs.editions )}}",
                    }
                },
                steps: [
                    {
                        name: "Checkout",
                        uses: "actions/checkout@v5",
                    },
                    {
                        name: "Build image",
                        uses: "RadxaOS-SDK/rsdk/.github/actions/build@main",
                        with: {
                            product: "${{ matrix.product }}",
                            suite: "${{ matrix.suite }}",
                            edition: "${{ matrix.edition }}",
                            "release-id": "${{ needs.prepare_release.outputs.release_id }}",
                            "github-token": "${{ secrets.GITHUB_TOKEN }}",
                        } + if variant == "test"
                        then
                            {
                                "test-repo": true,
                                timestamp: "t${{ github.run_number }}",
                                tag_name: release_info(variant).tag_name,
                            }
                        else
                            {},
                    }
                ]
            }
        }
    },
    quote_keys=false,
)

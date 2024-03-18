local product_data = import "../../../lib/product_data.libjsonnet";

function(
    product,
    build_org
) std.manifestYamlDoc(
    {
        name: "Build image for Release channel",
        on: {
            workflow_dispatch: {}
        },
        env: {
            GH_TOKEN: "${{ github.token }}"
        },
        jobs: {
            prepare_release:{
                "runs-on": "ubuntu-latest",
                steps: [
                    {
                        name: "Checkout",
                        uses: "actions/checkout@v4"
                    },
                    {
                        name: "Generate rbuild changelog",
                        uses: "radxa-repo/rbuild-changelog@main",
                        with: {
                            product: product_data(product).product
                        }
                    },
                    {
                        name: "Create empty release",
                        id: "release",
                        uses: "softprops/action-gh-release@v2",
                        with: {
                            tag_name: "b${{ github.run_number }}",
                            body_path: "README.md",
                            token: "${{ secrets.GITHUB_TOKEN }}",
                            target_commitish: "main",
                            draft: false,
                            prerelease: true,
                            files: ".changelog/changelog.md",
                        }
                    }
                ],
                outputs: {
                    release_id: "${{ steps.release.outputs.id }}"
                }
            },
            build: {
                "runs-on": "ubuntu-latest",
                needs: "prepare_release",
                strategy: {
                    matrix:{
                        boards: [ product_data(product).product ],
                        suites: product_data(product).supported_suite,
                        flavors: product_data(product).supported_edition
                    }
                },
                steps: [
                    {
                        name: "Checkout",
                        uses: "actions/checkout@v4"
                    },
                    {
                        name: "Upload rbuild image",
                        uses: "radxa-repo/rbuild@main",
                        with: {
                            board: "${{ matrix.boards }}",
                            suite: "${{ matrix.suites }}",
                            flavor: "${{ matrix.flavors }}",
                            "release-id": "${{ needs.prepare_release.outputs.release_id }}",
                            "github-token": "${{ secrets.GITHUB_TOKEN }}",
                        }
                    }
                ]
            }
        }
    },
    quote_keys=false
)

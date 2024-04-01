local product_data = import "../../../lib/product_data.libjsonnet";

function(
    product,
) std.manifestYamlDoc(
    {
        name: "Build image for Test channel",
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
                        name: "Generate changelog",
                        uses: "radxa-repo/rbuild-changelog@main",
                        with: {
                            product: product
                        }
                    },
                    {
                        name: "Create empty release",
                        id: "release",
                        uses: "softprops/action-gh-release@v2",
                        with: {
                            tag_name: "t${{ github.run_number }}",
                            body: "This is a test build for internal development.\nOnly use when specifically instructed by Radxa support.\n",
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
                        product: [ product ],
                    }
                },
                steps: [
                    {
                        name: "Checkout",
                        uses: "actions/checkout@v4"
                    },
                    {
                        name: "Build image",
                        uses: "RadxaOS-SDK/rsdk/.github/actions/build@main",
                        with: {
                            product: "${{ matrix.product }}",
                            "release-id": "${{ needs.prepare_release.outputs.release_id }}",
                            "github-token": "${{ secrets.GITHUB_TOKEN }}",
                            "test-repo": true,
                            timestamp: "t${{ github.run_number }}",
                        }
                    }
                ]
            }
        }
    },
    quote_keys=false
)

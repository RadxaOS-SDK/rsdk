local product_data = import "../configs/product_data.libjsonnet";

function(
    target,
    build_org,
) |||
    # %(product_full_name)s
    [![Build image for Release channel](https://github.com/%(build_org)s/%(product)s/actions/workflows/build.yaml/badge.svg)](https://github.com/%(build_org)s/%(product)s/actions/workflows/build.yaml) [![Build image for Test channel](https://github.com/%(build_org)s/%(product)s/actions/workflows/test.yaml/badge.svg)](https://github.com/%(build_org)s/%(product)s/actions/workflows/test.yaml)

    ## What is this?

    This repo is the central location for Radxa-built system images for %(product_full_name)s.

    ## Which image should I use?

    For most systems, Radxa now only supports the Debian Desktop image.

    Other variants that were previously provided AS-IS are no longer provided. Interested users need to build those by themselves.

    Please also always use [the latest release](https://github.com/%(build_org)s/%(product)s/releases/latest) instead of any pre-release / test builds. Those will not be supported.

    ## Where is the source code?

    This repository is only for hosting the GitHub workflows that build the image. As such, you will need to examine the workflow to find the builder.

    ## Help! Something doesn't work!

    For other questions, please first take a look at [our Documentation](https://docs.radxa.com), which covers the most basic usages.

    Should you have any additional questions, please visit [our forum](https://forum.radxa.com/) or [our Discord](https://rock.sh/go), and we are willing to help.
||| % {
    product: product_data(target).product,
    product_full_name: product_data(target).product_full_name,
    build_org: build_org
}

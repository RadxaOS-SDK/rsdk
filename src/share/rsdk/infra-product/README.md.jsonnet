local product_data = import "../configs/product_data.libjsonnet";

function(
    target,
    build_org,
) |||
    # %(product_full_name)s
    [![Build image for Release channel](https://github.com/%(build_org)s/%(product)s/actions/workflows/build.yml/badge.svg)](https://github.com/%(build_org)s/%(product)s/actions/workflows/build.yml) [![Build image for Test channel](https://github.com/%(build_org)s/%(product)s/actions/workflows/test.yml/badge.svg)](https://github.com/%(build_org)s/%(product)s/actions/workflows/test.yml)

    ## What is this?

    This repo is the central location for Radxa-built system images for %(product_full_name)s.

    ## What images are provided?

    Please also always use [the latest release](https://github.com/%(build_org)s/%(product)s/releases/latest) instead of any pre-release / test builds. Those will not be supported.

    ## Help! Something doesn't work!

    For other questions, please first take a look at [our Documentation](https://docs.radxa.com), which covers the most basic usages.

    Should you have any additional questions, please visit [our forum](https://forum.radxa.com/) or [our Discord](https://rock.sh/go), and we are willing to help.
||| % {
    product: product_data(target).product,
    product_full_name: product_data(target).product_full_name,
    build_org: build_org
}

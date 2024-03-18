local README_md = import "README.md.jsonnet";
local dependabot_yml = import ".github/dependabot.yml.jsonnet";
local build_yml = import ".github/workflows/build.yml.jsonnet";
local test_yml = import ".github/workflows/test.yml.jsonnet";

function(
    product,
    build_org
) {
    "README.md": README_md(product, build_org),
    ".github/dependabot.yml": dependabot_yml(product, build_org),
    ".github/workflows/build.yml": build_yml(product, build_org),
    ".github/workflows/test.yml": test_yml(product, build_org),
}

local README_md = import "README.md.jsonnet";
local dependabot_yml = import ".github/dependabot.yml.jsonnet";
local workflow = import ".github/workflows/workflow.jsonnet";
local test_yml = import ".github/workflows/test.yml.jsonnet";

function(
    product,
    build_org,
) {
    "README.md": README_md(product, build_org),
    ".github/dependabot.yml": dependabot_yml(),
    ".github/workflows/build.yml": workflow(product, "release"),
    ".github/workflows/test.yml": workflow(product, "test"),
}

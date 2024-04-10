local README_md = import "README.md.jsonnet";
local dependabot_yml = import ".github/dependabot.yml.jsonnet";
local workflow = import ".github/workflows/workflow.jsonnet";
local dependabot_workflow = import ".github/workflows/dependabot.yml.jsonnet";

function(
    product,
    build_org,
) {
    "README.md": README_md(product, build_org),
    ".github/dependabot.yml": dependabot_yml(),
    ".github/workflows/build.yml": workflow(product, "release"),
    ".github/workflows/test.yml": workflow(product, "test"),
    ".github/workflows/dependabot.yml": dependabot_workflow(),
}

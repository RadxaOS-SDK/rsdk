local README_md = import "README.md.jsonnet";
local dependabot_yaml = import "../common/dependabot/dependabot.yaml.jsonnet";
local workflow = import ".github/workflows/workflow.jsonnet";
local dependabot_workflow = import ".github/workflows/dependabot.yaml.jsonnet";

function(
    target,
    build_org,
    repo_org,
    pkg_org,
    git_rev,
) {
    "README.md": README_md(target, build_org),
    ".github/dependabot.yaml": dependabot_yaml(),
    ".github/workflows/build.yaml": workflow(target, "release"),
    ".github/workflows/test.yaml": workflow(target, "test"),
    ".github/workflows/dependabot.yaml": dependabot_workflow(),
}

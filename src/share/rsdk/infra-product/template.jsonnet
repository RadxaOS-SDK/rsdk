local LICENSE = import "../common/licenses/GPLv3.jsonnet";
local CODEOWNERS = import "../common/codeowners/CODEOWNERS.jsonnet";
local dependabot_yaml = import "../common/dependabot/dependabot.yaml.jsonnet";
local dependabot_workflow = import "../common/dependabot/workflow.jsonnet";
local README_md = import "README.md.jsonnet";
local workflow = import ".github/workflows/workflow.jsonnet";

function(
    target,
    build_org,
    repo_org,
    pkg_org,
    git_rev,
) {
    "LICENSE": LICENSE(),
    "README.md": README_md(target, build_org),
    ".github/CODEOWNERS": CODEOWNERS(),
    ".github/dependabot.yaml": dependabot_yaml(),
    ".github/workflows/build.yaml": workflow(target, "release"),
    ".github/workflows/test.yaml": workflow(target, "test"),
    ".github/workflows/dependabot.yaml": dependabot_workflow(),
}

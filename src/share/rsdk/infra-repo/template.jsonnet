local LICENSE = import "../common/licenses/GPLv3.jsonnet";
local CODEOWNERS = import "../common/codeowners/CODEOWNERS.jsonnet";
local dependabot_yaml = import "../common/dependabot/dependabot.yaml.jsonnet";
local dependabot_workflow = import "../common/dependabot/workflow.jsonnet";
local README_md = import "README.md.jsonnet";
local pkgs_lock = import "pkgs.lock.jsonnet";
local update_yaml = import ".github/workflows/update.yaml.jsonnet";

function(
    target,
    build_org,
    repo_org,
    pkg_org,
    git_rev,
) {
    "LICENSE": LICENSE(),
    "README.md": README_md(target, repo_org, pkg_org),
    //"pkgs.lock": pkgs_lock(),
    ".github/dependabot.yaml": dependabot_yaml(),
    ".github/CODEOWNERS": CODEOWNERS(),
    ".github/workflows/dependabot.yaml": dependabot_workflow(),
    ".github/workflows/update.yaml": update_yaml(target, pkg_org, git_rev),
}

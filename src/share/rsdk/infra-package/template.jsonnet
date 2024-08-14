local LICENSE = import "../common/licenses/GPLv3.jsonnet";
local CODEOWNERS = import "../common/codeowners/CODEOWNERS.jsonnet";
local dependabot_yaml = import "../common/dependabot/dependabot.yaml.jsonnet";
local dependabot_workflow = import "../common/dependabot/workflow.jsonnet";
local check_linked_issue_yaml = import "../common/check_linked_issue/check_linked_issue.yaml.jsonnet";
local docs_yaml = import ".github/workflows/docs.yaml.jsonnet";
local new_version_yaml = import ".github/workflows/new_version.yaml.jsonnet";
local release_yaml = import ".github/workflows/release.yaml.jsonnet";

function(
    target,
    build_org,
    repo_org,
    pkg_org,
    git_rev,
) {
    "LICENSE": LICENSE(),
    ".github/CODEOWNERS": CODEOWNERS(),
    ".github/dependabot.yaml": dependabot_yaml(),
    ".github/workflows/dependabot.yaml": dependabot_workflow(),
    ".github/workflows/docs.yaml": docs_yaml(target),
    ".github/workflows/new_version.yaml": new_version_yaml(),
    ".github/workflows/release.yaml": release_yaml(),
    ".github/workflows/check_linked_issue.yaml": check_linked_issue_yaml(),
}

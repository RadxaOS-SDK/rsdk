local apt_repo_json = import ".apt-repo.json.jsonnet";
local freight_conf = import ".freight.conf.jsonnet";
local LICENSE = import "LICENSE.jsonnet";
local README_md = import "README.md.jsonnet";
local dependabot_yaml = import ".github/dependabot.yaml.jsonnet";
local reset_yaml = import ".github/workflows/reset.yaml.jsonnet";
local update_yaml = import ".github/workflows/update.yaml.jsonnet";
local dependabot_workflow = import ".github/workflows/dependabot.yaml.jsonnet";

function(
    target,
    build_org,
    repo_org,
    pkg_org,
) {
    ".apt-repo.json": apt_repo_json(target),
    ".freight.conf": freight_conf(),
    "LICENSE": LICENSE(),
    "README.md": README_md(target, repo_org, pkg_org),
    ".github/dependabot.yaml": dependabot_yaml(),
    ".github/workflows/dependabot.yaml": dependabot_workflow(),
    ".github/workflows/reset.yaml": reset_yaml(),
    ".github/workflows/update.yaml": update_yaml(pkg_org),
}

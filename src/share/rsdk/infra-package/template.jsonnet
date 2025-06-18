local LICENSE = import "../common/licenses/GPLv3.jsonnet";
local CODEOWNERS = import "../common/codeowners/CODEOWNERS.jsonnet";
local dependabot_yaml = import "../common/dependabot/dependabot.yaml.jsonnet";
local dependabot_workflow = import "../common/dependabot/workflow.jsonnet";
local check_linked_issue_yaml = import "../common/check_linked_issue/check_linked_issue.yaml.jsonnet";
local docs_yaml = import ".github/workflows/docs.yaml.jsonnet";
local new_version_yaml = import ".github/workflows/new_version.yaml.jsonnet";
local release_yaml = import ".github/workflows/release.yaml.jsonnet";
local copyright = import "debian/copyright.jsonnet";
local README_md = import "README.md.jsonnet";
local Makefile = import "Makefile.jsonnet";
local Makefile_linux = import "Makefile.linux.jsonnet";
local Makefile_u_boot = import "Makefile.u-boot.jsonnet";
local changelog = import "debian/changelog.jsonnet";
local control_linux = import "debian/control.linux.jsonnet";
local control_u_boot = import "debian/control.u-boot.jsonnet";

function(
    target,
    build_org,
    repo_org,
    pkg_org,
    git_rev,
    new_repo,
) {
    "LICENSE": LICENSE(),
    ".devenv/.gitignore": importstr ".devenv/.gitignore",
    ".direnv/.gitignore": importstr ".direnv/.gitignore",
    ".devcontainer/.devenv/.gitignore": importstr ".devcontainer/.devenv/.gitignore",
    ".devcontainer/.direnv/.gitignore": importstr ".devcontainer/.direnv/.gitignore",
    ".devcontainer/devcontainer.json": importstr ".devcontainer/devcontainer.json",
    ".github/dependabot.yaml": dependabot_yaml(),
    ".github/workflows/dependabot.yaml": dependabot_workflow(),
    ".github/workflows/docs.yaml": docs_yaml(target),
    ".github/workflows/new_version.yaml": new_version_yaml(),
    ".github/workflows/release.yaml": release_yaml(),
    ".github/workflows/check_linked_issue.yaml": check_linked_issue_yaml(),
    "debian/compat": importstr "debian/compat",
    "debian/copyright": copyright(target),
    "debian/rules": importstr "debian/rules",
    "debian/common-lintian-overrides": importstr "debian/common-lintian-overrides",
    ".envrc": importstr ".envrc",
    "devenv.lock": importstr "devenv.lock",
    "devenv.nix": importstr "devenv.nix",
    "Makefile": Makefile(target),
    "README.md": README_md(target, pkg_org),
} + (if new_repo == true
then
    {
        "debian/.gitignore": importstr "debian/.gitignore",
        "debian/changelog": changelog(target),
        "debian/source/format": importstr "debian/source/format",
        ".github/CODEOWNERS": CODEOWNERS(),
        ".gitignore": importstr ".gitignore",
    }
else
    {}
) + (if std.startsWith(target, "linux")
then
    {
        "debian/patches/linux/0001-feat-Radxa-common-kernel-config.patch": importstr "debian/patches/linux/0001-feat-Radxa-common-kernel-config.patch",
        "Makefile.extra": Makefile_linux(target),
    } + (if new_repo == true
    then
        {
            "debian/patches/series": importstr "debian/patches/series.linux",
            "debian/control": control_linux(target),
        }
    else
        {}
    )
else if std.startsWith(target, "u-boot")
then
    {
        "Makefile.extra": Makefile_u_boot(target),
    } + (if new_repo == true
    then
        {
            "debian/u-boot.install": importstr "debian/u-boot.install",
            "debian/control": control_u_boot(target),
        }
    else
        {}
    )
else
    {}
)

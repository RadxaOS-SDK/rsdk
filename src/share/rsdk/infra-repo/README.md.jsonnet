function(
    target,
    repo_org,
    pkg_org,
) |||
    # %(target)s

    [![Update packages](https://github.com/%(repo_org)s/%(target)s/actions/workflows/update.yaml/badge.svg)](https://github.com/%(repo_org)s/%(target)s/actions/workflows/update.yaml)

    ## Content

    * [Published GitHub Releases](https://%(repo_org)s.github.io/%(target)s/pkgs.json)
    * [File index](https://%(repo_org)s.github.io/%(target)s/files.list)

    ## Report issues

    The issue list for this repository should be strictly related to the package repository service itself.  
    If your issue is related to a specific package's usage, you should file issues under package's repository over at [`%(pkg_org)s`](https://github.com/%(pkg_org)s).

    ## Usage

    ```bash
    # Always review the random shell script from the internet!
    # But, here is a convenient one-liner:
    curl https://%(repo_org)s.github.io/%(target)s/install.sh | sh
    ```
||| % {
    target: target,
    repo_org: repo_org,
    pkg_org: pkg_org,
}

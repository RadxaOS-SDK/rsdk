function(
    target,
    repo_org,
    pkg_org,
) |||
    [View on GitHub](https://github.com/%(repo_org)s/%(target)s)

    ## Usage

    ```bash
    temp=$(mktemp)
    curl -L --output "$temp" "https://github.com/%(pkg_org)s/radxa-archive-keyring/releases/latest/download/radxa-archive-keyring_$(curl -L https://github.com/%(pkg_org)s/radxa-archive-keyring/releases/latest/download/VERSION)_all.deb"
    sudo dpkg -i "$temp"
    rm -f "$temp"
    source /etc/os-release
    sudo tee /etc/apt/sources.list.d/radxa.list <<< "deb [signed-by=/usr/share/keyrings/radxa-archive-keyring.gpg] https://%(repo_org)s.github.io/%(target)s/ $VERSION_CODENAME main"
    sudo apt update
    ```
||| % {
    target: target,
    repo_org: repo_org,
    pkg_org: pkg_org,
}

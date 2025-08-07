function(
    target,
    repo_org,
    pkg_org,
) |||
    #!/usr/bin/env sh
    # Install signing keyring
    keyring="$(mktemp)"
    version="$(curl -L https://github.com/%(pkg_org)s/radxa-archive-keyring/releases/latest/download/VERSION)"
    curl -L --output "$keyring" \
        "https://github.com/%(pkg_org)s/radxa-archive-keyring/releases/latest/download/radxa-archive-keyring_${version}_all.deb"
    sudo dpkg -i "$keyring"
    rm -f "$keyring"
    # Add apt package repo
    echo "deb [signed-by=/usr/share/keyrings/radxa-archive-keyring.gpg] https://%(repo_org)s.github.io/%(target)s/ %(target)s main" | \
        sudo tee /etc/apt/sources.list.d/70-%(target)s.list
    sudo apt-get update
||| % {
    target: target,
    repo_org: repo_org,
    pkg_org: pkg_org,
}

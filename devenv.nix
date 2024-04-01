{ pkgs, lib, config, ... }:

{
  # https://devenv.sh/packages/
  packages = with pkgs; [
    aptly
    bash-completion
    commitizen
    curl
    dosfstools
    file
    git
    gh
    gptfdisk
    guestfs-tools
    jq
    libguestfs-with-appliance
    mdbook
    mdbook-admonish
    mdbook-i18n-helpers
    multipath-tools
    parted
    util-linux
    wget
    xz
    yq
    zx
  ];

  enterShell = ''
    export PATH=$PWD/src/bin:$PWD/node_modules/.bin:$PATH

    if [[ -n "$DEVENV_NIX" ]]
    then
      # Does not work from direnv
      # https://github.com/direnv/direnv/issues/773#issuecomment-792688396
      source $PWD/src/share/bash-completion/completions/rsdk
      rsdk welcome
    else
      rsdk welcome 'Please run `rsdk shell` to enter the full development shell.
'
    fi
  '';

  languages.javascript = {
    enable = true;
    npm.enable = true;
  };
  languages.jsonnet.enable = true;

  pre-commit = {
    hooks = {
      commitizen.enable = true;
      shellcheck = {
        enable = true;
        entry = lib.mkForce "${pkgs.shellcheck}/bin/shellcheck -x";
      };
      shfmt.enable = true;
      statix.enable = true;
      typos = {
        enable = true;
        excludes = [
          "theme/highlight.js"
        ];
      };
    };
  };

  starship.enable = true;
}

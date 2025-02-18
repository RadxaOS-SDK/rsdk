{ pkgs, lib, config, ... }:

{
  # https://devenv.sh/packages/
  packages = with pkgs; [
    bash-completion
    mdbook
    mdbook-admonish
    mdbook-cmdrun
    mdbook-i18n-helpers
    mdbook-linkcheck
    mdbook-toc
    ncurses
  ];

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
        ];
        settings.ignored-words = [
          "Synopsys"
          "HSI"
        ];
      };
    };
  };

  starship.enable = true;
}

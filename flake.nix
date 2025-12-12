{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default-linux";
    devshell.url = "github:numtide/devshell";

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} (_: {
      imports = [
        inputs.devshell.flakeModule
      ];
      systems = import inputs.systems;
      perSystem = {
        inputs',
        pkgs,
        ...
      }: {
        packages.default = pkgs.callPackage ./package.nix {
          quickshell = inputs'.quickshell.packages.default;
          inherit (pkgs) brightnessctl networkmanagerapplet pavucontrol blueman qt6 makeFontsConf nerd-fonts atkinson-hyperlegible-next texlivePackages;
        };

        devshells.default = {
          env = [
            {
              name = "SHEEZ_DEBUG";
              value = true;
            }
          ];
          commands = [
            {
              help = "run quickshell ipc commands";
              name = "ipc";
              command = "qs -c $PRJ_ROOT ipc $*";
            }
          ];
          serviceGroups.dev.services = {
            sheez-dev = {
              command = "qs -c $PRJ_ROOT";
            };
          };
          packages = [
            # nix
            pkgs.alejandra
            pkgs.statix
            pkgs.deadnix

            inputs'.quickshell.packages.default
            pkgs.kdePackages.qtdeclarative
          ];
        };
      };
    });
}

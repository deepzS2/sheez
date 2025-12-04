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
          inherit (pkgs) brightnessctl networkmanagerapplet pavucontrol blueman qt6 makeFontsConf;
          nerd-fonts = pkgs.nerd-fonts;
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
              help = "run quickshell in current directory";
              name = "dev";
              command = "qs -c $PRJ_ROOT";
            }
          ];
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

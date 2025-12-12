{
  lib,
  stdenvNoCC,
  makeFontsConf,
  # build
  quickshell,
  qt6,
  # runtime
  brightnessctl,
  networkmanagerapplet,
  pavucontrol,
  blueman,
  # fonts
  nerd-fonts,
  atkinson-hyperlegible-next,
  texlivePackages,
}: let
  runtimeDeps = [
    brightnessctl
    networkmanagerapplet
    pavucontrol
    blueman
    nerd-fonts.jetbrains-mono
  ];

  fontconfig = makeFontsConf {
    fontDirectories = [nerd-fonts.jetbrains-mono atkinson-hyperlegible-next texlivePackages.alfaslabone];
  };
in
  stdenvNoCC.mkDerivation {
    inherit runtimeDeps;

    pname = "sheez";
    version = "1.0.0";

    src = ./.;

    buildInputs = [
      qt6.qtbase
      qt6.qtmultimedia
    ];
    nativeBuildInputs = [qt6.wrapQtAppsHook];

    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/share/sheez

      cp -r . $out/share/sheez

      ln -s ${quickshell}/bin/qs $out/bin/sheez
    '';

    preFixup = ''
      qtWrapperArgs+=(
        --prefix PATH:${lib.makeBinPath runtimeDeps}
        --set FONTCONFIG_FILE ${fontconfig}
        --add-flags "-p $out/share/sheez"
      )
    '';

    meta = {
      description = "Lazy shell by deepz";
      homepage = "https://github.com/deepzS2/sheez";
      license = lib.licenses.mit;
      mainProgram = "sheez";
    };
  }

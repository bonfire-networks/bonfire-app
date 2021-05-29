{ pkgs, self }:
let
  beamPackages = with pkgs; beam.packagesWith beam.interpreters.erlang;
in
beamPackages.mixRelease rec {
  pname = "bonfire";
  version = "1.0.0";
  mixEnv = "prod";

  src = self;

  mixFodDeps = beamPackages.fetchMixDeps {
    pname = "mix-deps-${pname}";
    inherit src mixEnv version;
    LANG = "en_US.UTF-8";
    # override needed here since bonfire dependencies rely on git
    installPhase = ''
      runHook preInstall
      mix deps.get --only ${mixEnv}
      cp -r --no-preserve=mode,ownership,timestamps $TEMPDIR/deps $out
      runHook postInstall
    '';
    # TODO add sha256
    # since I didn't know exactly what dependencies where being pulled
    # I went for the quick hack of not checking for dependency integrity
    # This has the downside of triggering a rebuild on every deployment
    sha256 = null;
  };

  frontendAssets = with pkgs; stdenvNoCC.mkDerivation {
    pname = "frontend-assets-${pname}";
    nativeBuildInputs = [ nodejs cacert git ];

    inherit version src;

    configurePhase = ''
      export HOME=$(mktemp -d)
      cp -r ${mixFodDeps} ./deps
      cd assets
      npm install --quiet
    '';

    buildPhase = ''
      npm run deploy
      cd ..
    '';

    installPhase = ''
      cp -r priv/static $out
    '';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    # TODO add sha256
    # since I didn't know exactly what dependencies where being pulled
    # I went for the quick hack of not checking for dependency integrity
    # This has the downside of triggering a rebuild on every deployment
    outputHash = null;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars;
  };

  nativeBuildInputs = with pkgs; [ rustc cargo gcc ]; # for NIFs

  postBuild = ''
    cp -r ${frontendAssets} priv/static
    # digest needs to write files
    chmod -R u+w priv/static
    mix phx.digest
  '';
}

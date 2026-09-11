{
  description = "pedalboard project site";

  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        zolaSrc = pkgs.fetchFromGitHub {
          owner = "getzola";
          repo = "zola";
          rev = "v0.23.2";
          hash = "sha256-pdePZ8w+cUXA62wkCqtSBwtHNCBSmJQ0kqyOq+0k06o=";
        };

        zola = pkgs.zola.overrideAttrs {
          version = "0.23.2";
          src = zolaSrc;
          doCheck = false;
          cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
            src = zolaSrc;
            hash = "sha256-KTDsj6mOh8x4JtUL52lLARszmvMyvC49+MlnwHYaSq4=";
          };
        };

        site = pkgs.stdenvNoCC.mkDerivation {
          pname = "pedalboard-site";
          version = "0.1.0";
          src = pkgs.lib.cleanSource ./site;
          nativeBuildInputs = [ zola pkgs.cacert ];

          buildPhase = ''
            runHook preBuild
            zola check --skip-external-links
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            zola build --output-dir $out
            runHook postInstall
          '';
        };
      in
      {
        packages = {
          default = site;
          inherit site;
        };
        checks = { inherit site; };
        devShells.default = pkgs.mkShell {
          packages = [ pkgs.just pkgs.nodejs pkgs.wrangler zola ];
        };
      })
    // (let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      deploySite = pkgs.stdenvNoCC.mkDerivation {
        name = "deploy-pedalboard-site";
        isEffect = true;
        secretsMap = builtins.toJSON {
          cloudflare = "cloudflare";
        };
        nativeBuildInputs = [ pkgs.cacert pkgs.jq pkgs.wrangler ];
        phases = [ "initPhase" "effectPhase" ];

        initPhase = ''
          exec </dev/null
          export HOME=/build/home
          mkdir -p "$HOME"
        '';

        effectPhase = ''
          export CLOUDFLARE_API_TOKEN="$(${pkgs.jq}/bin/jq -er \
            '.cloudflare.data.api_token' "$HERCULES_CI_SECRETS_JSON")"
          export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
          export NODE_EXTRA_CA_CERTS="$SSL_CERT_FILE"

          work=$(mktemp -d)
          mkdir "$work/public"
          cp -R ${self.packages.x86_64-linux.site}/. "$work/public/"
          cp ${./site/wrangler.toml} "$work/wrangler.toml"

          cd "$work"
          ${pkgs.wrangler}/bin/wrangler deploy
        '';
      };
    in
    {
      herculesCI = { primaryRepo, ... }: {
        onPush.default.outputs.effects.deploy =
          if primaryRepo.branch or null == "main" then
          { run = deploySite; }
          else
            {
              dependencies = deploySite.inputDerivation // {
                isEffect = false;
                buildDependenciesOnly = true;
              };
            };
      };
    });
}

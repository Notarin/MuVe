{
  description = "A mutable install manager for Vencord";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    js-beautify-treewrapped.url = "github:notarin/js-beautify-treewrapped";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    treefmt-nix,
    js-beautify-treewrapped,
    ...
  }:
    flake-utils.lib.eachDefaultSystemPassThrough (
      system: let
        pkgs =
          import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          }
          // {
            js-beautify-treewrapped = js-beautify-treewrapped.packages.${system}.default;
          };
        lib = pkgs.lib;
        # Formatter config, we use treefmt. Config is found in `treefmt.nix`.
        treefmt-config = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      in {
        formatter.${system} = treefmt-config.config.build.wrapper;
        checks.${system} = {
          formatting = treefmt-config.config.build.check self;
        };
        packages.${system} = rec {
          default = MuVe;
          MuVe = pkgs.discord.overrideAttrs {
            postInstall = ''
              # We move the original app.asar to _app.asar because that is where
              # Vencord expects it to be. The discord code still needs to be
              # executed, so vencord runs the original app.asar from there after
              # it sets up its own resources.
              mv $out/opt/Discord/resources/app.asar $out/opt/Discord/resources/_app.asar

              # The asar is just an archive, and thankfully we can just replace
              # it with a directory and it'll read the package.json and run
              # our index.js instead.
              cp -r ${custom_asar} $out/opt/Discord/resources/app.asar
            '';
          };
          custom_asar = let
            # Fetching and patching sources
            packageJson = builtins.readFile ./asar/package.json;
            indexJs = builtins.readFile ./asar/index.js;
            patchedIndexJs = builtins.replaceStrings ["~curl~"] [(lib.getExe pkgs.curl)] indexJs;

            # Declaring what we pass in
            package = packageJson;
            index = patchedIndexJs;
          in (
            pkgs.runCommand "custom-asar" {
              inherit package index;
            } ''
              # Setup workdir
              echo -E "$index" > index.js
              echo -E "$package" > package.json

              # Package workdir to output
              ${lib.getExe pkgs.asar} p . $out
            ''
          );
        };
        devShells.${system}.default = pkgs.mkShell {
          shellHook = ''
            oldHookDir=$(git config --local core.hooksPath)

            if [ "$oldHookDir" != "$PWD/.githooks" ]; then
              read -rp "Set git hooks to $PWD/.githooks? (y/n) " answer
              if [ "$answer" = "y" ]; then
                git config core.hooksPath "$PWD"/.githooks
                echo "Set git hooks to $PWD/.githooks"
              else
                echo "Skipping git hooks setup"
              fi
            fi
          '';
        };
      }
    );
}

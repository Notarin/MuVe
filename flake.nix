{
  description = "A mutable install manager for Vencord";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    treefmt-nix,
    ...
  }:
    flake-utils.lib.eachDefaultSystemPassThrough (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        lib = pkgs.lib;
        treefmt-config = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      in {
        formatter.${system} = treefmt-config.config.build.wrapper;
        checks.${system} = {
          formatting = treefmt-config.config.build.check self;
        };
        packages.${system} = rec {
          discord_patched = pkgs.discord.overrideAttrs {
            postInstall = ''
              mv $out/opt/Discord/resources/app.asar $out/opt/Discord/resources/_app.asar
              mkdir -p $out/opt/Discord/resources/app.asar
              cp -r ${./asar}/* $out/opt/Discord/resources/app.asar
            '';
          };
          wrapper = pkgs.stdenv.mkDerivation (let
            script_raw = builtins.readFile ./resources/wrapper.nu;
            script_patched =
              builtins.replaceStrings
              [
                "~Nu_bin~"
                "~Discord_bin~"
              ]
              [
                (lib.getExe pkgs.nushell)
                (lib.getExe discord_patched)
              ]
              script_raw;
          in {
            pname = "vencord-wrapper";
            version = discord_patched.version;
            src = ./.;
            output_bin = script_patched;
            installPhase = ''
              mkdir -p "$out/bin"
              printf "$output_bin" > "$out/bin/$pname"
              chmod +x "$out/bin/$pname"
            '';
          });
          default = wrapper;
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

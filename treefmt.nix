{pkgs, ...}: {
  projectRootFile = ".git/config";
  settings = {
    allow-missing-formatter = false;
    formatter = {
      # Javascript formatter
      "jsbeautifier" = {
        command = pkgs.lib.getExe pkgs.js-beautify-treewrapped;
        includes = ["*.js"];
      };
    };
  };
  programs = {
    # Nix formatter
    alejandra = {
      enable = true;
      package = pkgs.alejandra;
    };
    # JSON formatter
    jsonfmt = {
      enable = true;
      package = pkgs.jsonfmt;
    };
  };
}

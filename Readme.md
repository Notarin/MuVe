# MuVe - Mutable Vencord for Nix

**MuVe** (pronounced *movie*) stands for **Mutable Vencord**. It’s a custom Nix flake that installs Vencord in a mutable location, allowing it to self-update outside the constraints of the Nix store.

## Problem

The standard Nix method of installing Vencord:

```nix
pkgs.discord.override { withVencord = true; }
```

places everything, including Vencord, inside the immutable Nix store. This breaks Vencord's update model. While the Discord client loads most of its resources live at runtime and remains usable even when outdated, Vencord quickly falls out of sync, causing breakages.

## Solution

MuVe replaces Discord’s `app.asar` with a thin loader that downloads Vencord runtime files into `$XDG_DATA_HOME/Vencord`. This allows Vencord to keep pace with Discord updates while leaving the rest of the client immutable.

## Usage

To try it out:

```bash
nix run github:notarin/muve
```

The flake's default package output is the patched Discord client. You can consume it directly or integrate it into your own flake setup as needed.

## License

This project is licensed under MIT. All external resources are under their individual license.
# steam-dbusmenu-export

[![CI](https://github.com/kud3n013/steam-dbusmenu-export/actions/workflows/ci.yml/badge.svg)](https://github.com/kud3n013/steam-dbusmenu-export/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/github/license/kud3n013/steam-dbusmenu-export)](LICENSE)
[![Release](https://img.shields.io/github/v/release/kud3n013/steam-dbusmenu-export)](https://github.com/kud3n013/steam-dbusmenu-export/releases/latest)

A lightweight C daemon that exports the Steam client menu and recent games to KDE Plasma's Global Menu via DBusMenu.

> **Naming:** the repository is `steam-dbusmenu-export`, but the binary, the systemd unit and the Arch package are all still called `steam-globalmenu`, so existing installs and scripts keep working.

## What and why

Steam's CEF-based UI does not export its menu bar over DBusMenu, so Plasma's Global Menu applet stays empty while Steam is focused. This daemon watches Steam's windows and publishes a menu for them instead.

Features, as implemented in `src/steam-globalmenu.c`:

- Publishes a menu on the session bus as `com.canonical.dbusmenu` and registers it with `com.canonical.AppMenu.Registrar`.
- Binds the menu to Steam's windows through the `_KDE_NET_WM_APPMENU_SERVICE_NAME` and `_KDE_NET_WM_APPMENU_OBJECT_PATH` window properties.
- Reads Steam's `libraryfolders.vdf` and `localconfig.vdf` to list recent and installed games.
- Navigates by sending `steam://` URLs.
- Adds Millennium entries when the Millennium modding framework is detected.

## Requirements

KDE Plasma with the Global Menu applet, and Steam running on X11 or XWayland. Build and runtime libraries: `glib2`, `libdbusmenu-glib`, `libx11`.

## Install

### Arch Linux (archrepo)

Packages and the database are signed with the repository key
`CFB7 9154 3B4B 2D28 21E9  127A C012 A947 6C17 0A37`.

1. Import and locally sign the key:
   ```bash
   curl -sSfL -o /tmp/archrepo.asc https://github.com/kud3n013/archrepo/releases/download/packages/archrepo.asc
   sudo pacman-key --add /tmp/archrepo.asc
   sudo pacman-key --lsign-key CFB791543B4B2D2821E9127AC012A9476C170A37
   ```

2. Add the repository configuration to `/etc/pacman.conf`:
   ```ini
   [archrepo]
   SigLevel = Required
   Server = https://github.com/kud3n013/archrepo/releases/download/packages
   ```

3. Synchronize and install: `sudo pacman -Syy steam-globalmenu`

### From source

```bash
make
sudo make install
```

`PREFIX` (default `/usr`) and `DESTDIR` are honored. This installs `bin/steam-globalmenu`, `lib/systemd/user/steam-globalmenu.service`, `share/doc/steam-globalmenu/quickcss.css` and the license.

## Usage

```bash
systemctl --user daemon-reload
systemctl --user enable --now steam-globalmenu.service
```

or run it directly: `steam-globalmenu --silent &` (`--quiet` is an alias, `--version` prints the version).

## Quick CSS companion

`contrib/millennium/quickcss.css` (installed to `/usr/share/doc/steam-globalmenu/quickcss.css`) is a Quick CSS file for Millennium / CSSLoader. It hides Steam's own menu bar and window controls and merges the header into one bar, since the menu now lives in the Global Menu. Paste it into Millennium's Quick CSS.

## Development

```bash
make test
```

It checks `--version` and `--help`, and, when `xvfb-run` and `dbus-run-session` are installed, starts the daemon headless, checks it stays alive and stops it with SIGTERM. Without a KDE registrar on the bus the daemon is expected to keep running.

## Releases

The version is the `#define VERSION` in `src/steam-globalmenu.c`. To release, update it and `CHANGELOG.md`, merge, then push a tag `vX.Y.Z`. The release workflow checks the tag against the source, runs the tests and publishes `steam-dbusmenu-export-X.Y.Z.tar.gz` with its `.sha256`. The Arch package builds from that asset.

## Origin and license

This code was moved here from [`kud3n013/archrepo`](https://github.com/kud3n013/archrepo) (`packages/steam-globalmenu`) without changes. Licensed under the [MIT License](LICENSE).

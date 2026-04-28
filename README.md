# qtBar

**qtBar** is a lightweight World of Warcraft add-on that shows a small bar for **attunement** on your equipped gear. The core add-on works on its own; optional plugins connect it to popular UI packages.

- License: [GNU General Public License v3](LICENSE.md) (or later; see license file).
- Community: [Contributing](CONTRIBUTING.md) · [Code of Conduct](CODE_OF_CONDUCT.md) · [Security](SECURITY.md)

## Requirements

- A client that matches the add-on’s **Interface** build. The main TOC currently declares `## Interface: 33300` (update the number when you retarget a new patch).
- **qtBar** (required for any setup).

## Install

1. Copy the add-on folders into your World of Warcraft **Interface/AddOns** directory (see [Blizzard’s guide](https://us.support.blizzard.com/en/article/world-of-warcraft-installing-addons)).
2. In the add-ons list, enable what you use:
  - **qtBar** — always, for the main bar and settings.
  - **qtBar ElvUI** and/or **qtBar cDF** — only if you use [ElvUI](https://www.tukui.org/download.php?ui=elvui) or cDF (Chromie Dragonflight UI) and want the bar anchored to those layouts.

### Folder layout

Unzip or clone so you have, for example:

- `.../Interface/AddOns/qtBar/` (contains `qtBar.toc` and the Lua files)
- Optionally `.../Interface/AddOns/qtBar_ElvUI/`
- Optionally `.../Interface/AddOns/qtBar_cDF/`

## Optional plugins


| Folder                                     | Purpose                                                     | Depends on           |
| ------------------------------------------ | ----------------------------------------------------------- | -------------------- |
| [qtBar_ElvUI](qtBar_ElvUI/qtBar_ElvUI.toc) | Parents the bar to ElvUI’s experience/data bar when present | **qtBar**, **ElvUI** |
| [qtBar_cDF](qtBar_cDF/qtBar_cDF.toc)       | Anchors the overlay when using cDF                          | **qtBar**, **cDF**   |


Load **qtBar** first; the bridge add-ons are thin glue and will not help without the matching UI.

## In-game use

- Slash: `/qtbar` (opens options), `/qtbar refresh`, `/qtbar color …`, `/qtbar resetpos` — see the in-game usage line when you run `/qtbar` with no subcommand.
- `contrib/` holds small reference fragments for development; it is not required for normal play.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). PRs and issues are welcome; please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) first.

## Security

See [SECURITY.md](SECURITY.md) for how to report sensitive issues.
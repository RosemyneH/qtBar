# Contributing to qtBar

Thank you for helping improve qtBar. This project is released under the [GNU General Public License v3](LICENSE.md). By contributing, you agree that your contributions are licensed under the same terms.

## How to contribute

- **Bug reports**: Open an issue and use the bug report template when possible. Include your WoW client version, other add-ons that might interact (especially UI replacements), and steps to reproduce.
- **Feature ideas**: Open an issue and describe the use case; maintainers may ask for mockups or in-game behavior details.
- **Pull requests**: Keep changes focused on one concern. Reference any related issue in the PR description.

## Code style (Lua)

- Match the style of existing files: consistent indentation (tabs as in the current tree), clear names, minimal unnecessary abstraction.
- Section headers may use the project’s TextEmoji comment style when adding new top-level sections (see existing `main.lua` / `bar.lua` for examples).
- Avoid drive-by refactors or unrelated formatting in the same change as a fix or feature.

## Reviews

Maintainers may request changes before merge. Be respectful; see [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Project layout

- **Core add-on**: `qtBar/` — main TOC and Lua modules.
- **Optional bridges**: `qtBar_ElvUI/`, `qtBar_cDF/` — anchor qtBar when those UIs are present.
- **contrib/**: reference snippets for maintainers; not always loaded by the add-on.

If you are unsure whether a change belongs in core or a bridge, ask in an issue before large refactors.
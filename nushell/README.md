# Nushell Configuration

A port of `~/.config/zsh` to [Nushell](https://www.nushell.sh/), targeting an
Arch Linux box (an old iMac). Runs **alongside** zsh, not in place of it —
zsh stays the default shell; this is opt-in via `nu`.

## Structure

```
~/.config/nushell/
├── env.nu               # env vars, PATH, tool-init cache generation (runs first)
├── config.nu             # settings + sources everything below
└── custom/
    ├── theme.nu           # Tokyo Night syntax highlighting (color_config)
    ├── aliases.nu         # ported aliases/*.zsh
    ├── functions.nu       # ported functions/*.zsh
    └── hooks.nu           # ported hooks/directory.zsh (onefetch on cd)
```

Nushell has no oh-my-zsh equivalent and no `zstyle`; completion styling and
syntax highlighting are just fields on `$env.config`, set directly in
`config.nu`/`theme.nu`.

## What got dropped vs. the zsh config

All macOS-only and now-irrelevant pieces, since this targets Arch:

- **Homebrew, Arduino, sketchybar, iTerm/AppleScript, yazi** — excluded outright (per your call — no homebrew/arduino/sketchybar/iterm/yazi on this box).
- **`functions/gh.zsh`** — the hand-rolled zsh completion script for `gh` isn't portable. Install `carapace` instead (see below) — it ships a `gh` completer and covers most other CLIs zsh needed manual completions for.
- **Apple Music controls, `diskutil`, `aerospace`, `/usr/libexec/java_home`, `DYLD_LIBRARY_PATH`, MATLAB/Unity `.app` paths, BSD `sed -i ''`, `pbcopy`/`pbpaste`** — all macOS-specific; either no Arch equivalent was wired up, or one was substituted (GNU `sed -i`, `xdg-open`, `wl-copy`/`xclip` auto-detection in `clip-copy`/`clip-paste`).
- **`thefuck`** — no official Nushell shell integration exists, so the `f` alias was dropped.

## Nushell quirk worth knowing: `source` is parse-time

Nushell's `source` command needs its target file to exist **on disk before
the file containing it is parsed** — even inside a runtime `if` guard that
never fires. That breaks the usual "only source a tool's init script if the
tool is installed" pattern zsh uses everywhere (`command -v foo && source
...`).

The fix used throughout `env.nu`: always regenerate a (possibly empty) cache
file per tool in `~/.cache/nushell/*.nu` — `env.nu` runs and finishes before
`config.nu` is ever parsed, so by the time `config.nu`'s unconditional
`source ~/.cache/nushell/zoxide.nu` (etc.) is parsed, the file is guaranteed
to exist, whether or not `zoxide` itself is installed.

## Dependencies (Arch package names)

Core: `eza`, `btop`, `fzf`, `zoxide`, `atuin`, `bat`, `fastfetch`, `onefetch`,
`fd`, `tree`, `lazygit`, `neovim`.

Optional / context-specific:

- `oh-my-posh` — AUR (`oh-my-posh-bin`). Shares the same theme file as the
  zsh config (`~/.config/zsh/external/oh-my-posh/default.json`), so the
  prompt looks identical in both shells.
- `carapace` — AUR (`carapace-bin`), recommended replacement for the old
  hand-written `gh` completion script. Not wired up here; add
  `source (carapace _carapace nushell | str join "\n")`-style init to
  `config.nu` if you install it (check `carapace --help` for the current
  Nushell invocation, it's changed across versions).
- `wl-clipboard` (Wayland) or `xclip` (X11) — for `clip-copy`/`clip-paste`
  and `batcopy` in `custom/functions.nu`.
- `xdg-utils` — for `xdg-open` (`github` alias, `web` function).
- `go`, `rust`/`rustup`, `dotnet-sdk`, [ghcup](https://www.haskell.org/ghcup/)
  — only needed if you actually use those toolchains; `env.nu` adds their
  bin dirs to PATH unconditionally, harmless if absent.
- `miniconda`/`anaconda` — not packaged on Arch; install manually. `env.nu`
  tries `conda shell.nu hook` first (newer conda versions), falling back to
  just adding `~/miniconda3/bin` to PATH if that subcommand doesn't exist.

## Installing

```sh
git clone <this repo> ~/.config/nushell   # or however you're syncing it over
nu   # launch it — env.nu + config.nu run automatically
```

Reload after editing: `ns` (alias in `custom/aliases.nu`, restarts the nu
process — Nushell doesn't support clean in-place config reloads the way
`source ~/.zshrc` does).

## Customizing

Same philosophy as the zsh config: each `custom/*.nu` file is self-contained
and topical. Add a new file and `source` it from `config.nu` for anything
that doesn't fit the existing ones — there's no `local.nu` / untracked
override file set up yet (the zsh config's `local.zsh` has no port here);
add one following the same pattern if you need machine-specific overrides
that shouldn't be committed.

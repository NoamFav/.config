# Zen Browser Customization — Reference

Zen is a Firefox fork (currently tracking Firefox ESR/rapid-release core, e.g. "Firefox 148 core" as of the 2026 releases). It inherits **all** of Firefox's chrome-customization machinery (`userChrome.css`, `userContent.css`, `about:config`, DevTools Style Editor) and layers its own preference namespace (`zen.*`) and a mod/theme marketplace on top. So: anything written for Firefox userChrome customization works here with zero or trivial changes; anything Zen-specific (workspaces, compact mode, sidebar, glance, split view, accent-color engine) needs the Zen docs specifically.

---

## 1. Where things live

**Profile folder (macOS):** `~/Library/Application Support/zen/Profiles/<hash>.<profile-name>/`
Fastest way to find it without guessing the hash: open Zen → address bar → `about:support` → *Application Basics* → **Open Profile Folder**. (`about:profiles` → **Root Directory** → Open Folder also works and lets you see all profiles at once.)

Inside that profile folder, customization files live in a subfolder you create yourself:

```
<profile>/chrome/
├── userChrome.css      # styles the browser UI (tabs, sidebar, toolbar, urlbar…)
└── userContent.css     # styles web content / internal pages (about:*, new tab, etc.)
```

Your repo's [userChrome.css](Zen/userChrome.css) is presumably meant to be symlinked into that `chrome/` folder — same pattern as the rest of your `.config` (clone/symlink to match the tool's expected path).

> Note: the file currently in this dir has `root: {}` as its only content — that's not valid CSS (should be `:root { }` if you want a variable block). Flagging it since it'll silently no-op once linked in; happy to fix when we start writing real rules.

## 2. Turning customization on

Two prefs gate everything, set via `about:config`:

| Preference | Purpose | Default |
|---|---|---|
| `toolkit.legacyUserProfileCustomizations.stylesheets` | Master switch — without `true` here, `userChrome.css`/`userContent.css` are never even read | `false` (Firefox ≥69, inherited by Zen) |
| `devtools.chrome.enabled` | Lets DevTools inspect/edit browser **chrome**, not just page content | `false` on some Zen builds pre-1.0.0-a.31 |
| `devtools.debugger.remote-enabled` | Needed alongside the above to open the Browser Toolbox | varies |

After flipping the stylesheets pref, **restart the browser once**. After that, edits to the CSS files apply live (see §3) without further restarts in most cases.

## 3. Live-editing workflow (Zen's own guide)

Source: [Live Editing Zen Theme](https://docs.zen-browser.app/guides/live-editing)

1. `about:support` → Open Profile Folder → create `chrome/userChrome.css` (blank file) → restart Zen.
2. Open the Browser Toolbox: `Ctrl+Shift+Alt+I` (this is the *chrome-privileged* DevTools, separate from the normal per-page inspector `Cmd+Opt+I`).
3. In the Toolbox, go to the **Style Editor** tab and find your `userChrome.css` in the list — you can edit and `Ctrl/Cmd+S` to save, and changes paint immediately.
4. Use the **Inspect** (element picker) button in the Toolbox to click any bit of chrome UI and read its `id`/`class`/tag to target in CSS.
5. If a rule silently doesn't apply, append `!important` — a lot of Zen/Firefox chrome nodes have inline or high-specificity XUL styling.
6. If you're targeting something that only appears transiently (a popup, a hover menu), enable **"Disable Popup Auto-Hide"** in the Toolbox's settings (gear icon) so it stays open while you inspect it.

This is functionally identical to the classic Firefox workflow (MDN / support.mozilla.org's [Contributors guide on advanced customization with CSS](https://support.mozilla.org/en-US/kb/contributors-guide-firefox-advanced-customization)) — same Style Editor, same Browser Toolbox shortcut, same `!important` caveat. One real Firefox limitation carries over unchanged: **CSS can only restyle/hide/reposition elements that already exist in the DOM** — it cannot fabricate new buttons or toolbars from nothing. For that you need an actual mod/extension, not pure CSS.

## 4. Zen's CSS variable system (the part that's genuinely Zen-specific)

Under the hood, `src/zen/common/zenThemeModifier.js` (a `ZenThemeModifier` class) watches a set of `zen.*` prefs and pushes live values onto CSS custom properties at `:root`, specifically to work around shadow-DOM style-inheritance breakage. The variables worth knowing when writing your own `userChrome.css`:

| CSS variable | Driven by / meaning |
|---|---|
| `--zen-primary-color` | The accent color, mirrors `zen.theme.accent-color` |
| `--zen-border-radius` | Global corner rounding (platform defaults: 10–14px macOS, 8px Win/Linux) |
| `--zen-element-separation` | Gap between sidebar and content, recalculated for fullscreen / compact mode / split view |
| `--zen-toolbar-height` | Nav toolbar height (default 34px) |
| `--zen-native-inner-radius`, `--zen-big-shadow` | Used by `.browserSidebarContainer` for the content-panel look |
| `--zen-essential-tab-icon` | Favicon-driven variable for essential/pinned tabs |

Practical upshot: if you override `--zen-primary-color` (or set `zen.theme.accent-color` directly) your whole chrome re-tints coherently instead of you hand-patching every element — this is the natural hook for matching Zen to your Tokyo Night palette ([tokyo_night.json](../tokyo_night.json)) elsewhere in your dotfiles.

There's an open (not yet shipped, as of the [Zen Palette discussion](https://github.com/zen-browser/desktop/discussions/5047)) request for a fuller Arc-style `--zen-palette-*` variable set (background/foreground/title tokens etc.) plus an upcoming "Boosts" feature for injecting custom CSS more officially. Not available yet — for now direct `userChrome.css` is still the way.

## 5. Relevant `about:config` flags

Full list: [Hidden/Advanced Preferences](https://docs.zen-browser.app/guides/about-config-flags). Highlights by category:

**Theme / accent**
- `zen.theme.accent-color` — hex value for the primary accent
- `zen.theme.content-element-separation` — border thickness around the content area (default 8)
- `zen.theme.gradient` / `zen.theme.gradient.show-custom-colors` — sidebar gradient + custom hex sidebar color
- `zen.theme.essentials-favicon-bg` — colored bg behind essential-tab favicons
- `zen.view.grey-out-inactive-windows` — desaturate theme on blur
- `zen.watermark.enabled` — startup splash

**Compact mode**
- `zen.view.compact.animate-sidebar`, `.color-sidebar`, `.color-toolbar`
- `zen.view.compact.show-sidebar-and-toolbar-on-hover`
- `zen.view.compact.toolbar-flash-popup`

**Sidebar**
- `zen.view.sidebar-collapsed.hide-mute-button`
- `zen.view.sidebar-expanded.max-width`
- `zen.view.sidebar-height-throttle` (perf, default 200)

**Window chrome**
- `zen.view.hide-window-controls`
- `zen.view.experimental-force-window-controls-left`
- `zen.view.experimental-no-window-controls`
- `zen.view.experimental-rounded-view`

**Workspaces**
- `zen.workspaces.swipe-actions`, `.wrap-around-navigation`, `.natural-scroll`
- `zen.workspaces.scroll-modifier-key` (`ctrl`/`alt`/`shift`)

## 6. Feature surface (what you're theming/scripting around)

From the [User Manual](https://docs.zen-browser.app/user-manual): Workspaces (per-project tab containers), Compact Mode, Glance (peek a link without leaving your tab), Split View, Window Sync/Recovery, essential/pinned tabs, folders, Picture-in-Picture, plus the usual Firefox bookmark/extension/profile management underneath.

## 7. Mods / Themes Marketplace

- Browse/install: [zen-browser.app/mods](https://zen-browser.app/mods) — three-step install: browse, click install, done (it just drops the mod's CSS + prefs into your profile behind the scenes).
- Canonical registry repo: [zen-browser/theme-store](https://github.com/zen-browser/theme-store) — `themes.json` is the index; each entry has:
  ```
  id, name, description, homepage, style (URL to the CSS), readme,
  image (preview PNG), author, version, createdAt, updatedAt, tags, preferences (optional URL to a prefs schema)
  ```
- To publish your own: [Submission Guidelines](https://docs.zen-browser.app/themes-store/themes-marketplace-submission-guidelines) — open a GitHub issue via their template (name ≤25 chars, description ≤100 chars, screenshot PNG 600×400, README required); a bot validates and opens the PR. Preferences (user-configurable options in a mod) are defined as a JSON object — see [marketplace-preferences docs](https://docs.zen-browser.app/themes-store/themes-marketplace-preferences) for the schema.

Good real-world examples to read (not just install) for structure:
- [catppuccin/zen-browser](https://github.com/catppuccin/zen-browser) — one `themes/<flavor>/` folder per palette variant, each with its own `userChrome.css` + `userContent.css` + a re-branded logo asset. Clean example of shipping multiple variants and of concatenating community CSS onto your own file rather than replacing it.
- [KiKaraage/Zen-Mods-Store](https://github.com/KiKaraage/Zen-Mods-Store), [Archer7x/Zen-Themes](https://github.com/Archer7x/Zen-Themes), [rsiebertdev/zen-themes](https://github.com/rsiebertdev/zen-themes) — grab-bag personal mod repos, useful for scavenging specific snippets (e.g. "hide the mute button", "flatten the tab bar").

## 8. Plain-Firefox resources (apply with "small variation")

Since Zen only reskins the chrome and doesn't remove the underlying Firefox XUL structure wholesale, these are still directly useful — just verify selectors still match (Zen renames/wraps a handful of elements, e.g. its own `.browserSidebarContainer`, essentials tray, workspace switcher):

- [MrOtherGuy/firefox-csshacks](https://github.com/MrOtherGuy/firefox-csshacks) — huge, well-maintained collection of drop-in userChrome snippets (hide elements, compact tabs, single-toolbar layouts, etc.), each in its own file with a comment header explaining what it does and which Firefox version it was verified against.
- [Aris-t2/CustomCSSforFx](https://github.com/Aris-t2/CustomCSSforFx) — same idea, different curator, broader/older snippet library.
- [support.mozilla.org: Contributors guide on advanced customization with CSS](https://support.mozilla.org/en-US/kb/contributors-guide-firefox-advanced-customization) — the closest thing Mozilla has to "official" docs on this (it's community/contributor-maintained, not core product docs, which is why the feature still works despite being officially discouraged).
- [How-To Geek: customize Firefox's UI with userChrome.css](https://www.howtogeek.com/334716/how-to-customize-firefoxs-user-interface-with-userchrome.css/) — good plain intro to the concept if you want the beginner framing.

## 9. Gotchas worth remembering

- Nothing loads until `toolkit.legacyUserProfileCustomizations.stylesheets = true` **and** the browser has been restarted once after creating `chrome/`.
- `userChrome.css` = browser UI; `userContent.css` = page/internal-page content (new tab, about: pages). Don't mix them up when a rule "isn't working."
- `!important` is frequently necessary, not a sign you did something wrong.
- CSS-only customization can't add new UI elements — only restyle/hide/reposition existing ones. Net-new functionality needs a mod (which can ship JS) or an extension.
- Zen re-derives a lot of chrome color from `--zen-primary-color` / `zen.theme.accent-color` — prefer setting that one lever over overriding colors element-by-element, it'll stay consistent across sidebar/toolbar/folders/etc. automatically.
- Flatpak Linux path differs (`~/.var/app/app.zen_browser.zen/.zen`) if you ever set this up cross-platform — not relevant on your Mac setup, but noted since some snippets/discussions assume it.

## 10. Link index

- Docs home: https://docs.zen-browser.app/
- Live editing guide: https://docs.zen-browser.app/guides/live-editing
- Hidden prefs: https://docs.zen-browser.app/guides/about-config-flags
- User manual: https://docs.zen-browser.app/user-manual
- Mods marketplace (browse): https://zen-browser.app/mods
- Marketplace docs: https://docs.zen-browser.app/themes-store/themes-marketplace
- Submission guidelines: https://docs.zen-browser.app/themes-store/themes-marketplace-submission-guidelines
- Theme-store registry (source of truth JSON): https://github.com/zen-browser/theme-store
- Zen Palette variables discussion (future work): https://github.com/zen-browser/desktop/discussions/5047
- Theme system internals (DeepWiki reverse-engineered notes): https://deepwiki.com/zen-browser/desktop/3.2-theme-system-and-customization
- Zen desktop source: https://github.com/zen-browser/desktop
- Firefox CSS hack collections: https://github.com/MrOtherGuy/firefox-csshacks · https://github.com/Aris-t2/CustomCSSforFx
- Mozilla contributor guide: https://support.mozilla.org/en-US/kb/contributors-guide-firefox-advanced-customization

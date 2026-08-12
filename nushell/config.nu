# ~/.config/nushell/config.nu
#
# Ported from ~/.config/zsh's modular setup. env.nu already ran (it sets
# $env.OMP_PATH, PATH, and regenerates the tool-init caches this file
# sources below) — see that file first if something here looks unexplained.

source custom/theme.nu
source custom/aliases.nu
source custom/functions.nu
source custom/hooks.nu

$env.config.show_banner = false

# --- external tool integrations --------------------------------------------
# Generated fresh at every startup by env.nu; always exist (possibly empty)
# so `source` — a parse-time keyword — never fails here even when the
# underlying tool isn't installed.

source ~/.cache/nushell/zoxide.nu
source ~/.cache/nushell/atuin.nu
source ~/.cache/nushell/oh-my-posh.nu
source ~/.cache/nushell/conda.nu

# ~/.config/nushell/env.nu
#
# Environment variables + PATH. Runs once at shell startup, before config.nu
# is parsed — anything config.nu's `source` calls depend on existing on disk
# (tool init scripts, see the bottom of this file) has to be created here.
#
# Ported from ~/.config/zsh for an Arch Linux box. macOS-only pieces
# (DYLD_LIBRARY_PATH, /usr/libexec/java_home, Homebrew paths, MATLAB/Unity.app,
# pbcopy/pbpaste) were dropped rather than translated — see the repo README.

$env.REPO_HUB = ($env.HOME | path join "Neoware")
$env.PROJECT_DIR = $env.REPO_HUB
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

# Shared with the zsh config so both shells prompt identically.
$env.OMP_PATH = ($env.HOME | path join ".config" "zsh" "external" "oh-my-posh" "default.json")
$env.EZA_CONFIG_DIR = ($env.HOME | path join ".config" "eza")

# --- PATH -----------------------------------------------------------------

$env.PATH = (
    $env.PATH
    | prepend [
        ($env.HOME | path join "go" "bin")                       # Go binaries
        ($env.HOME | path join ".local" "bin")                   # Local user binaries
        ($env.HOME | path join ".cargo" "bin")                   # Rust/cargo binaries
        ($env.HOME | path join ".ghcup" "bin")                   # Haskell (ghcup)
        ($env.HOME | path join ".cabal" "bin")                   # Haskell (cabal)
        ($env.HOME | path join ".local" "share" "omnisharp")     # OmniSharp (C#/Unity tooling)
        ($env.HOME | path join ".dotnet" "tools")                # dotnet global tools
    ]
    | uniq
)

$env.MANPATH = $"($env.HOME | path join ".local" "share" "man"):($env.MANPATH? | default '')"
$env.DOCKER_CONFIG = ($env.HOME | path join ".dev" "docker")

# Wine/DXVK (relevant on Linux, unlike the rest of the macOS export list)
$env.DXVK_LOG_LEVEL = "none"
$env.WINEDLLOVERRIDES = "d3d11,dxgi=n"

# Java — Arch's jdk packages live under /usr/lib/jvm; picks the
# lexicographically-last entry (works for single-digit version bumps like
# java-17-openjdk -> java-21-openjdk; sanity-check if you install a JDK >= 100).
if ("/usr/lib/jvm" | path exists) {
    let jvms = (ls "/usr/lib/jvm" | where type == dir | get name | sort | reverse)
    if ($jvms | is-not-empty) {
        $env.JAVA_HOME = ($jvms | first)
    }
}

# .NET — Arch's dotnet-sdk package puts the SDK under /usr/share/dotnet or
# /usr/lib/dotnet depending on version; only set DOTNET_ROOT if dotnet is
# actually installed.
if (which dotnet | is-not-empty) {
    $env.DOTNET_ROOT = if ("/usr/share/dotnet" | path exists) {
        "/usr/share/dotnet"
    } else if ("/usr/lib/dotnet" | path exists) {
        "/usr/lib/dotnet"
    } else {
        ""
    }
}

# Tokyo Night file colors (GNU LS_COLORS format — works with GNU ls and eza;
# didn't work on macOS's BSD ls, so this is a straight net win on Arch).
# Kept identical to exports/paths.zsh in the zsh config.
$env.EZA_COLORS = "di=38;2;122;162;247:ln=38;2;42;195;222:ex=38;2;158;206;106:pi=38;2;65;72;104:so=38;2;65;72;104:bd=38;2;224;175;104:cd=38;2;224;175;104:or=38;2;255;0;124"
$env.LS_COLORS = "di=38;2;122;162;247:ln=38;2;42;195;222:ex=38;2;158;206;106:pi=38;2;65;72;104:so=38;2;65;72;104:bd=38;2;224;175;104:cd=38;2;224;175;104:or=38;2;255;0;124:*.go=38;2;42;195;222:*.rs=38;2;255;158;100:*.c=38;2;61;89;161:*.cpp=38;2;122;162;247:*.sh=38;2;158;206;106:*.bash=38;2;158;206;106:*.zsh=38;2;158;206;106:*.ts=38;2;122;162;247:*.js=38;2;224;175;104:*.java=38;2;247;118;142:*.lua=38;2;187;154;247:*.html=38;2;255;158;100:*.py=38;2;224;175;104:*.swift=38;2;255;158;100:*.ino=38;2;26;188;156:*.md=38;2;115;122;162:*.hs=38;2;157;124;216:*.ml=38;2;255;158;100:*.ex=38;2;187;154;247:*.fnl=38;2;42;195;222:*.rb=38;2;219;75;75:*.php=38;2;157;124;216:*.cs=38;2;157;124;216:*.d=38;2;219;75;75:*.f90=38;2;157;124;216:*.fs=38;2;122;162;247:*.gleam=38;2;247;118;142:*.groovy=38;2;122;162;247:*.hc=38;2;224;175;104:*.kt=38;2;187;154;247:*.nim=38;2;224;175;104:*.pl=38;2;61;89;161:*.r=38;2;122;162;247:*.scm=38;2;219;75;75:*.sass=38;2;187;154;247:*.styl=38;2;187;154;247:*.sv=38;2;158;206;106:*.v=38;2;122;162;247:*.tex=38;2;122;162;247:*.asm=38;2;115;122;162:*.clj=38;2;158;206;106:*.cljs=38;2;158;206;106:*.coffee=38;2;224;175;104:*.dart=38;2;42;195;222:*.elm=38;2;122;162;247:*.erl=38;2;219;75;75:*.jl=38;2;157;124;216:*.nix=38;2;42;195;222:*.zig=38;2;255;158;100:*.vue=38;2;158;206;106:*.svelte=38;2;255;158;100:*.twig=38;2;158;206;106:*.yml=38;2;247;118;142:*.yaml=38;2;247;118;142:*.json=38;2;224;175;104:*.toml=38;2;255;158;100:*.xml=38;2;255;158;100:*.sql=38;2;122;162;247:*.graphql=38;2;187;154;247:*.vim=38;2;158;206;106:*.ps1=38;2;61;89;161:*.tf=38;2;187;154;247"

# --- External tool integrations --------------------------------------------
#
# Nushell's `source` is a parse-time keyword: it needs the target file to
# exist on disk *before config.nu is parsed*, even inside a runtime `if`
# guard. So instead of conditionally sourcing each tool's init script, we
# always regenerate a (possibly empty) cache file here in env.nu — which
# runs and finishes before config.nu is ever parsed — and unconditionally
# `source` those cache files from config.nu.

let cache_dir = ($env.HOME | path join ".cache" "nushell")
mkdir $cache_dir

def generate-init [name: string, check: string, cmd: closure] {
    let target = ($cache_dir | path join $"($name).nu")
    if (which $check | is-not-empty) {
        (do $cmd) | save -f $target
    } else {
        "" | save -f $target
    }
}

generate-init "zoxide" "zoxide" { ^zoxide init nushell --cmd cd }
generate-init "atuin" "atuin" { ^atuin init nu }
generate-init "oh-my-posh" "oh-my-posh" { ^oh-my-posh init nu --config $env.OMP_PATH --print }

# Conda: newer conda ships a nushell hook (`shell.nu hook`); older ones don't.
# Falls back to just putting conda's own bin dir on PATH (matches the zsh
# config's fallback) — `conda activate` needs the real hook to work, this
# fallback only gets you the bare `conda` command.
let conda_target = ($cache_dir | path join "conda.nu")
if (which conda | is-not-empty) {
    try {
        (^conda "shell.nu" "hook") | save -f $conda_target
    } catch {
        "" | save -f $conda_target
        $env.PATH = ($env.PATH | prepend ($env.HOME | path join "miniconda3" "bin"))
    }
} else {
    "" | save -f $conda_target
}

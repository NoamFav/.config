# Ported from ~/.config/zsh/functions/*.zsh. Dropped entirely: arduino.zsh,
# functions/homebrew.zsh (sketchybar + brew, no homebrew on Arch), y() (yazi),
# closeiterm/quititerm (iTerm/AppleScript), functions/gh.zsh's hand-rolled gh
# completion script — use carapace instead (it ships a gh spec out of the
# box), see the README.

# --- files ----------------------------------------------------------------

# Find/replace a string across every file under the cwd, GNU-sed flavored
# (BSD's zsh original used `sed -i ''`; Arch's sed just wants `-i`).
def replace_text [old: string, new: string] {
    print $"searching for files containing: '($old)'"
    let files = (^grep -rl --binary-files=without-match $old . | lines)

    if ($files | is-empty) {
        print $"no files found containing '($old)'"
        return
    }

    print $"found ($files | length) file\(s\). replacing '($old)' with '($new)'..."
    $files | each {|f| ^sed -i $"s/($old)/($new)/g" $f }
    print "replacement completed"
}

# Fuzzy-cd into a project under ~/Neoware.
def repo [] {
    let base = ($env.HOME | path join "Neoware")
    let target = (
        ^fd -t d . $base
        | lines
        | where {|d| not ($d | str contains "/.git") }
        | str join (char nl)
        | ^fzf --prompt "repo> "
    )
    if ($target | is-not-empty) { cd $target }
}

# Project tree quicklook.
def ptree [depth: int = 2] {
    ^tree -L $depth -d -I ".git"
}

# Copy the contents of fzf-picked files (or 1-level-deep files under a picked
# dir) to the clipboard via bat. Auto-detects Wayland vs X11 clipboard tool.
def clip-copy [] {
    if (which wl-copy | is-not-empty) {
        ^wl-copy
    } else if (which xclip | is-not-empty) {
        ^xclip -selection clipboard
    } else {
        error make { msg: "no clipboard tool found (install wl-clipboard or xclip)" }
    }
}

def clip-paste [] {
    if (which wl-paste | is-not-empty) {
        ^wl-paste
    } else if (which xclip | is-not-empty) {
        ^xclip -selection clipboard -o
    } else {
        error make { msg: "no clipboard tool found (install wl-clipboard or xclip)" }
    }
}

def batcopy [] {
    let sel = (^fzf -m --preview '([[ -d {} ]] && tree -L 2 {}) || bat --color=always -- {}' | lines)
    if ($sel | is-empty) { return }

    let files = ($sel | each {|f|
        if ($f | path type) == "dir" {
            ls $f | where type == file | get name
        } else {
            [$f]
        }
    } | flatten)

    if ($files | is-empty) { return }
    ^bat --color=always -- ...$files | clip-copy
}

def goup [] {
    let gopath = (^go env GOPATH | str trim)
    let bin_dir = ($gopath | path join "bin")
    if not ($bin_dir | path exists) { return }

    ls $bin_dir | where type == file | get name | each {|bin|
        let pkg = (^go version -m $bin | lines | find "path " | first | split row " " | last)
        if ($pkg | is-not-empty) { ^go install $"($pkg)@latest" }
    }
}

# --- onefetch --------------------------------------------------------------

def onelist [] {
    print "select a language theme for onefetch"
    ^onefetch -l | ^fzf --prompt "language theme: " --preview 'onefetch -a (echo {1} | tr "[:upper:]" "[:lower:]")' --preview-window "right:70%" --border rounded
}

# --- dynamic web alias ------------------------------------------------------
#
# zsh redefined the `web` alias on every chpwd. Nu aliases are parse-time, so
# instead this looks the mapping up at call time — same effect, no hook needed.

const web_aliases = {
    Psycho: "https://noamfav.github.io/Psycho"
    Resume: "https://noamfav.github.io/Resume"
    bitvoyager: "https://noamfav.github.io/bitvoyager"
    NF-Software: "https://nf-software.com"
}

def web [] {
    let project = ($env.PWD | path basename)
    let url = ($web_aliases | get -o $project)
    if ($url | is-empty) {
        print $"no web alias for '($project)'"
    } else {
        print $"opening ($project)..."
        ^xdg-open $url
    }
}

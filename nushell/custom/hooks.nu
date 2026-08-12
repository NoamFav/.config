# Ported from ~/.config/zsh/hooks/directory.zsh. The dynamic web-alias half
# of that file doesn't need a hook in nu — see custom/functions.nu's web().

$env.config.hooks.env_change.PWD = ($env.config.hooks.env_change.PWD? | default [] | append {|before, after|
    if ($after | path join ".git" | path exists) {
        ^onefetch
        ls
    }
})

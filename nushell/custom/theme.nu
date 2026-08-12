# Tokyo Night syntax highlighting + completion-menu colors.
#
# Ported from ~/.config/zsh/core/oh-my-zsh.zsh (ZSH_HIGHLIGHT_STYLES). Nushell
# has no plugin system for this — it's built into the `color_config` record —
# so shape_* keys are matched to their closest zsh-syntax-highlighting
# equivalent rather than translated 1:1 (nu's shape vocabulary is coarser).

$env.config.color_config = ($env.config.color_config | merge {
    shape_garbage: { fg: "#f7768e" attr: "b" }      # unknown-token
    shape_keyword: "#bb9af7"                        # reserved-word
    shape_bool: "#bb9af7"
    shape_internalcall: "#7aa2f7"                    # arg0 / builtin commands
    shape_external: "#9ece6a"                        # precommand
    shape_external_resolved: "#9ece6a"
    shape_externalarg: "#9ece6a"
    shape_literal: "#7aa2f7"                         # history-expansion
    shape_operator: "#e0af68"                        # globbing / redirection
    shape_redirection: "#e0af68"
    shape_signature: "#9ece6a"
    shape_string: "#9ece6a"                          # single/double-quoted-argument
    shape_raw_string: "#9ece6a"
    shape_string_interpolation: "#2ac3de"            # rc-quote / back-quoted
    shape_datetime: "#7aa2f7"
    shape_list: "#bb9af7"
    shape_table: "#bb9af7"
    shape_record: "#bb9af7"
    shape_block: "#bb9af7"                           # command-substitution-delimiter
    shape_closure: "#9ece6a"
    shape_filepath: "#2ac3de"
    shape_directory: "#7aa2f7"                       # autodirectory
    shape_globpattern: "#e0af68"
    shape_glob_interpolation: "#e0af68"
    shape_variable: "#bb9af7"                        # assign
    shape_vardecl: "#bb9af7"
    shape_flag: "#bb9af7"                            # single/double-hyphen-option
    shape_custom: "#9ece6a"                           # suffix-alias
    shape_nothing: "#565f89"
    shape_binary: "#bb9af7"
    shape_matching_brackets: { attr: "u" }
    shape_pipe: "#bb9af7"
    shape_match_pattern: "#9ece6a"
    shape_int: "#e0af68"
    shape_float: "#e0af68"
    shape_range: "#e0af68"
})

# Completion menu chrome (mirrors core/completion.zsh's zstyle colors:
# blue descriptions, yellow messages, red "no matches" warnings).
$env.config.menus = ($env.config.menus | each {|menu|
    if $menu.name == "completion_menu" {
        $menu | upsert style {
            text: "#c0caf5"
            selected_text: { fg: "#1a1b26" bg: "#7aa2f7" attr: "b" }
            description_text: "#e0af68"
        }
    } else {
        $menu
    }
})

$env.config.completions.case_sensitive = false
$env.config.completions.algorithm = "fuzzy"
$env.config.completions.quick = true
$env.config.completions.partial = true

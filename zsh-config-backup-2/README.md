# ZSH Modular Configuration

This directory contains a modular ZSH configuration that replaces the monolithic `.zshrc` file.

## Directory Structure

```
~/.config/zsh/
├── aliases/
│   ├── development.zsh  # Development tool aliases
│   ├── git.zsh         # Git and project management
│   ├── multimedia.zsh  # AI, music, and gaming aliases
│   └── system.zsh      # System and file management aliases
├── core/
│   ├── completion.zsh  # ZSH completion styling
│   ├── environment.zsh # Environment variables and basic settings
│   └── oh-my-zsh.zsh  # Oh My Zsh configuration
├── exports/
│   ├── libraries.zsh  # Library paths and dev environments
│   └── paths.zsh      # PATH and development tool paths
├── external/
│   ├── completions.zsh # Auto-completion setup
│   ├── conda.zsh      # Conda initialization
│   └── tools.zsh      # Shell enhancement tools
├── functions/
│   ├── arduino.zsh    # Arduino development tools
│   ├── files.zsh      # File management utilities
│   ├── git.zsh        # Git repository management
│   ├── homebrew.zsh   # Homebrew utilities
│   └── misc.zsh       # Miscellaneous utilities
├── hooks/
│   └── directory.zsh  # Directory change hooks
├── startup/
│   └── welcome.zsh    # Welcome message and startup
├── local.zsh          # Local customizations (not tracked)
└── README.md          # This file
```

## Module Loading Order

Modules are loaded in dependency order by the main `.zshrc` file:

1. **Core modules** - Basic environment and Oh My Zsh
2. **Exports** - PATH and library configurations  
3. **Aliases** - Command shortcuts and replacements
4. **Functions** - Custom shell functions
5. **Hooks** - Directory change automation
6. **External tools** - Third-party integrations
7. **Startup** - Welcome messages and final setup

## Customization

### Local Changes
- Edit `local.zsh` for machine-specific customizations
- This file is not tracked in git and won't be overwritten

### Module Changes
- Edit individual modules for specific functionality
- Each module is self-contained and documented

### Adding New Modules
1. Create the new module file in the appropriate directory
2. Add it to the `modules` array in `~/.zshrc`
3. Source your configuration: `source ~/.zshrc`

## Quick Commands

- `zc` - Edit the main .zshrc file
- `zs` - Reload ZSH configuration
- `nv ~/.config/zsh/` - Browse all modules with Neovim

## Troubleshooting

If a module fails to load:
1. Check the error message for the specific module
2. Verify the file exists and has correct permissions
3. Test the module in isolation: `source ~/.config/zsh/path/to/module.zsh`

## Backup

Your original `.zshrc` was backed up during the split process. Check for backup files in your home directory.

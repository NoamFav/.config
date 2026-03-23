#!/bin/zsh

DOTFILES_DIR="$HOME/dotfiles"

echo "🔗 Symlinking core dotfiles..."
ln -sf "$DOTFILES_DIR/.zshrc" ~/.zshrc
ln -sf "$DOTFILES_DIR/.zshenv" ~/.zshenv
ln -sf "$DOTFILES_DIR/.gitconfig" ~/.gitconfig
ln -sf "$DOTFILES_DIR/.gitignore_global" ~/.gitignore_global

echo "🔗 Symlinking configs..."
mkdir -p ~/.config
for config in "$DOTFILES_DIR"/configs/*; do
    name=$(basename "$config")
    ln -sf "$config" ~/.config/"$name"
done

echo "✅ Done! Don't forget to run 'brew bundle' if needed."

#!/usr/bin/env bash
# Bootstrap the 42 branch on a cluster account: Linux, no sudo, ~5GB home.
# Everything lands in $HOME (~/.local, ~/.dev); safe to re-run.
#
#   git clone --recurse-submodules -b 42 https://github.com/NoamFav/.config ~/.config
#   bash ~/.config/script/system/setup-42.sh
set -euo pipefail

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
LOCAL="$HOME/.local"
ZSH_DIR="$HOME/.dev/oh-my-zsh"
NODE_MAJOR=22

mkdir -p "$LOCAL/bin" "$LOCAL/opt"
export PATH="$LOCAL/bin:$PATH"

step() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

step "submodules"
git -C "$CONFIG" submodule update --init --recursive

step "zsh"
ln -sfn "$CONFIG/zsh/.zshrc" "$HOME/.zshrc"
if [[ ! -d "$ZSH_DIR" ]]; then
    git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh "$ZSH_DIR"
fi
plugins=(
    "zsh-users/zsh-syntax-highlighting"
    "zsh-users/zsh-autosuggestions"
    "zsh-users/zsh-completions"
    "Aloxaf/fzf-tab"
)
for repo in "${plugins[@]}"; do
    dest="$ZSH_DIR/custom/plugins/${repo#*/}"
    [[ -d "$dest" ]] || git clone --depth 1 "https://github.com/$repo" "$dest"
done

# lsp/servers.lua uses vim.lsp.config, which needs 0.11+; the cluster's
# packaged nvim is usually older than that
step "neovim"
nvim_ok() {
    have nvim && nvim --headless -c 'if has("nvim-0.11") | qa | else | cq | endif' >/dev/null 2>&1
}
if ! nvim_ok; then
    rm -rf "$LOCAL/opt/nvim"
    curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
        | tar -xz -C "$LOCAL/opt"
    mv "$LOCAL/opt/nvim-linux-x86_64" "$LOCAL/opt/nvim"
    ln -sfn "$LOCAL/opt/nvim/bin/nvim" "$LOCAL/bin/nvim"
fi
nvim --version | head -1

step "oh-my-posh"
if ! have oh-my-posh; then
    curl -fsSL -o "$LOCAL/bin/oh-my-posh" \
        https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64
    chmod +x "$LOCAL/bin/oh-my-posh"
fi

# mason installs pyright, bashls, dockerls, jsonls, yamlls and prettier
# through npm, so node has to exist before the first nvim launch
step "node (for mason's npm-based servers)"
if ! have npm; then
    base="https://nodejs.org/dist/latest-v${NODE_MAJOR}.x"
    tarball=$(curl -fsSL "$base/SHASUMS256.txt" | awk '/linux-x64\.tar\.xz$/ {print $2}')
    rm -rf "$LOCAL/opt/node"
    mkdir -p "$LOCAL/opt/node"
    curl -fsSL "$base/$tarball" | tar -xJ --strip-components=1 -C "$LOCAL/opt/node"
    ln -sfn "$LOCAL/opt/node/bin/node" "$LOCAL/bin/node"
    ln -sfn "$LOCAL/opt/node/bin/npm" "$LOCAL/bin/npm"
    ln -sfn "$LOCAL/opt/node/bin/npx" "$LOCAL/bin/npx"
fi
node --version

step "neovim plugins + language servers"
nvim --headless "+Lazy! restore" +qa
nvim --headless "+lua require('lazy').load({plugins={'mason-tool-installer.nvim'}})" "+MasonToolsInstallSync" +qa

step "done"
du -sh "$HOME" 2>/dev/null | awk '{print "home is now " $1}'
echo "open a new shell (or: exec zsh) to pick everything up"

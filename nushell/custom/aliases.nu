# Ported from ~/.config/zsh/aliases/*.zsh. Dropped: Apple Music (mm/mn/mp —
# AppleScript/macOS only), dh (diskutil), switch (aerospace), omzc (no
# oh-my-zsh on nu), f (thefuck has no nushell integration).

# --- system -----------------------------------------------------------

alias ls = eza --icons always
alias lt = eza --icons --tree
alias top = btop
alias c = clear
alias e = exit
alias ff = fastfetch
alias of = onefetch
alias fucking = sudo
alias cdhist = zoxide query -l -s | bat

alias nv = nvim
alias nc = nvim ~/.config/nushell/config.nu     # edit nu config (was zc)
def ns [] { exec nu }                           # reload nu config (was zs) — restarts the shell process

# --- development --------------------------------------------------------

alias g++ = g++ -std=c++23
alias clang++ = clang++ -std=c++23
alias mvnfx = mvn clean javafx:run
alias msbuild = dotnet msbuild

def dotnet-version [] {
    ^dotnet --version
    ^msbuild --version
}

alias nrd = npm run dev
alias nrb = npm run build
alias nrs = npm run start
alias nrt = npm run test
alias nru = npm run update
alias nrdp = npm run deploy

alias cmr = ./run.sh
alias ws = whisper-stream -m ~/.models/whisper/ggml-large-v3-turbo.bin --step 1000 --length 5000 -vth 0.7 -t 8

# --- git & project navigation -------------------------------------------

alias i = iskra
alias is = iskra status
alias ie = iskra exec
alias iss = iskra sync
alias issa = iskra sync-all
alias il = iskra log
alias ii = iskra info
alias idi = iskra diff
alias ib = iskra branch
alias ig = iskra gh
alias ip = iskra pulse
alias auto = iskra
alias lg = lazygit

alias rp = cd ~/Neoware
alias nlp = cd ~/Neoware/NLP_project
alias apps = cd ~/Neoware/00-apps
alias webs = cd ~/Neoware/01-websites
alias games = cd ~/Neoware/02-games
alias plugs = cd ~/Neoware/03-editor-plugins
alias study = cd ~/Neoware/04-coursework
alias research = cd ~/Neoware/05-research
alias cfg = cd ~/Neoware/06-configs
alias exp = cd ~/Neoware/07-experiments

alias github = xdg-open https://github.com/NoamFav

# --- multimedia / misc ---------------------------------------------------

alias llama3 = llama-cli -hf unsloth/Llama-3.3-70B-Instruct-GGUF
alias starwars = ssh starwarstel.net
alias idle = pipes.sh -p 10 -t 9 -r 100000 -R

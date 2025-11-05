# ~/bin/launch_project.sh
#!/bin/zsh -f
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export TERM="xterm-256color"

proj="$1"   # first argument = which project to launch

cd "$HOME/Neoware/$proj" || {
  echo "Project $proj not found"
  exit 1
}

exec "$HOME/configs.sh/aerospace/run.sh" "$proj"

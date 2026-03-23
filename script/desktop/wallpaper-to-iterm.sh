#!/bin/bash
LOCKFILE="/tmp/wallpaper-to-iterm.lock"
if [[ -f "$LOCKFILE" ]] && ps -p $(cat "$LOCKFILE") >/dev/null 2>&1; then
    echo "Script is already running (PID: $(cat "$LOCKFILE")). Exiting..."
    exit 1
fi
echo $$ >"$LOCKFILE"
# Paths
PREFS_JSON="$HOME/Library/Containers/whbalzac.Huajian/Data/Documents/Setting/Preferences.json"
ITERM_BACKGROUND="$HOME/Pictures/iterm-wallpaper.png"
SCREEN_SAVER_DIR=$HOME/Library/Containers/com.apple.ScreenSaver.Engine.legacyScreenSaver/Data/Documents

# Fetch the wallpaper path using a background process (avoids permission issues)
get_wallpaper_path() {
    /usr/bin/osascript -e "do shell script \"jq -r '.screen_video_path_dict.main_screen' '$PREFS_JSON' 2>/dev/null\"" 2>/dev/null
}

update_iterm_wallpaper() {
    WALLPAPER_PATH=$(get_wallpaper_path)

    # If fetching failed, skip update
    if [[ -z "$WALLPAPER_PATH" || ! -f "$WALLPAPER_PATH" ]]; then
        echo "Error: Unable to fetch wallpaper path."
        return
    fi

    echo "New wallpaper detected: $WALLPAPER_PATH"

    # Extract a frame using ffmpeg
    /opt/homebrew/bin/ffmpeg -y -i "$WALLPAPER_PATH" -vf "select=eq(n\,150)" -frames:v 1 -update 1 "$ITERM_BACKGROUND" -loglevel quiet

    # Apply the new wallpaper to iTerm2
    osascript -e "
    tell application \"iTerm2\"
        repeat with aWindow in windows
            repeat with aTab in tabs of aWindow
                repeat with aSession in sessions of aTab
                    set background image of aSession to POSIX file \"$ITERM_BACKGROUND\"
                end repeat
            end repeat
        end repeat
    end tell"

    echo "iTerm2 background updated!"
}

update_screen_saver() {
    SCREEN_SAVER_PATH=$(get_wallpaper_path)

    # If fetching failed, skip update
    if [[ -z "$SCREEN_SAVER_PATH" || ! -f "$SCREEN_SAVER_PATH" ]]; then
        echo "Error: Unable to fetch screensaver path."
        return
    fi

    echo "New screensaver detected: $SCREEN_SAVER_PATH"

    # Remove the old screensaver
    find "$SCREEN_SAVER_DIR" -type f -delete

    # Define the output file without audio
    SCREEN_SAVER_NO_AUDIO="$SCREEN_SAVER_DIR/$(basename "$SCREEN_SAVER_PATH" .mp4)_no_audio.mp4"

    # Remove audio using ffmpeg
    /opt/homebrew/bin/ffmpeg -i "$SCREEN_SAVER_PATH" -c copy -an "$SCREEN_SAVER_NO_AUDIO"

    # Copy the modified screensaver to the screensaver directory
    mv "$SCREEN_SAVER_NO_AUDIO" "$SCREEN_SAVER_DIR"

    echo "Screensaver updated without sound!"
}
# Watch for wallpaper changes
echo "Watching for wallpaper changes..."
/opt/homebrew/bin/fswatch -o "$PREFS_JSON" | while read; do
    update_iterm_wallpaper
    update_screen_saver
done

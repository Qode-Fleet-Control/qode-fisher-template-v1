# config.fish — the versioned fish setup this repo ships. Plugins are listed in
# fish_plugins and installed by Fisher (`fisher update`); this file and functions/ are
# the setup's own config.

if status is-interactive
    set -g fish_greeting ""          # no banner
    set -gx EDITOR vi
    abbr --add --global gst "git status"
    abbr --add --global ll "ls -lah"
end

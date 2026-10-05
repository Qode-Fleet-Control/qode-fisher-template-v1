#!/bin/sh
# Install this repo's fish setup into a fish config dir, then let Fisher install the
# plugins listed in fish_plugins (`fisher update`), the way Fisher's README bootstraps:
#   curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
# — here pinned to Fisher's release tag.
#
#   FISH_CONFIG_ROOT (default ./.xdg)  ->  the setup lands in $FISH_CONFIG_ROOT/fish
#
# A dedicated variable, not XDG_CONFIG_HOME, so a local run never touches your real
# ~/.config/fish. The Dockerfile passes FISH_CONFIG_ROOT=/home/app/.config.
set -eu
FISHER_REF="${FISHER_REF:-4.4.8}"
here=$(cd "$(dirname "$0")/.." && pwd)
root="${FISH_CONFIG_ROOT:-$here/.xdg}"
mkdir -p "$root/fish"
cp -R "$here/fish/." "$root/fish/"
XDG_CONFIG_HOME="$root" fish -c "
  curl -fsSL https://raw.githubusercontent.com/jorgebucaran/fisher/$FISHER_REF/functions/fisher.fish | source
  and fisher update
"
XDG_CONFIG_HOME="$root" fish -c 'fisher list'

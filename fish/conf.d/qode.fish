# conf.d/qode.fish — loaded before config.fish. Records which setup is active.
set -g qode_fish_version (string trim < $__fish_config_dir/VERSION 2>/dev/null; or echo unknown)

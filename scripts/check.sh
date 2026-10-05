#!/bin/sh
# The job: start an INTERACTIVE fish with the installed setup and check that the plugins
# Fisher installed are there and load — Fisher itself, autopair.fish (its interactive
# conf.d ran), replay.fish — plus the setup's own function and prompt.
# Exits 0 when every check passes.
set -u
here=$(cd "$(dirname "$0")/.." && pwd)
export XDG_CONFIG_HOME="${FISH_CONFIG_ROOT:-$here/.xdg}"
export TERM="${TERM:-xterm-256color}"

errfile=$(mktemp)
fish -i -c '
  set -g fail 0
  function ok;  echo "ok   $argv"; end
  function bad; echo "FAIL $argv"; set -g fail 1; end
  echo "qode fish setup $qode_fish_version, $(fish --version)"
  set -l plugins (fisher list)
  for p in (string match -rv "^\s*(#|\$)" < $__fish_config_dir/fish_plugins)
    contains -- $p $plugins; and ok "fisher installed $p"; or bad "fisher did not install $p"
  end
  functions -q fisher;            and ok "fisher loaded";                    or bad "fisher not loaded"
  set -q autopair_pairs;          and ok "autopair.fish loaded (conf.d ran)"; or bad "autopair.fish conf.d did not run"
  functions -q _autopair_insert_left; and ok "autopair.fish functions";      or bad "autopair.fish functions missing"
  functions -q replay;            and ok "replay.fish loaded";               or bad "replay.fish not loaded"
  test (replay "set -gx QODE_REPLAYED yes"; echo $QODE_REPLAYED) = yes
                                  and ok "replay runs a bash line";          or bad "replay did not work"
  test (qode_hello) = "hello from qode"; and ok "qode_hello works";         or bad "qode_hello output"
  set -l rendered (fish_prompt | string replace -ra "\e\[[0-9;]*m" "" | string replace -ra "\e\(B" "")
  string match -q "qode *>*" -- "$rendered"; and ok "prompt renders: $rendered"; or bad "prompt not from the setup: $rendered"
  exit $fail
' 2>"$errfile"
rc=$?
if [ -s "$errfile" ]; then
  echo "FAIL fish wrote to stderr while loading:"; sed 's/^/  | /' "$errfile"; rc=1
fi
rm -f "$errfile"
[ $rc -eq 0 ] && echo PASS || echo FAILED
exit $rc

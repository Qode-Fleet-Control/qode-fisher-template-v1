# Fisher template

Provisioned from [`Qode-Fleet-Control/fleet-template-v1`](https://github.com/Qode-Fleet-Control/fleet-template-v1) — the fleet
lifecycle contract (`bin/`, `fleet.conf`, `compose.yaml`, deploy workflows) with a
Fisher starter laid on top. **A job, not a service**: the image's default command runs the
check and exits 0 on success; nothing listens on `$PORT`.

## What it is

A versioned [fish](https://fishshell.com) setup whose plugins are managed by
[Fisher](https://github.com/jorgebucaran/fisher):

| path | what |
|---|---|
| `fish/fish_plugins` | the plugin list Fisher installs: Fisher itself, autopair.fish, replay.fish — each pinned to a tag |
| `fish/config.fish` | interactive config (no greeting, abbreviations) |
| `fish/conf.d/qode.fish`, `fish/VERSION` | records the setup version (1.0.0) |
| `fish/functions/` | the setup's own functions: `qode_hello`, `fish_prompt` (`qode <cwd> (<branch>) >`) |
| `scripts/install.sh` | copies `fish/` into a fish config dir and runs `fisher update` |
| `scripts/check.sh` | **the job**: interactive fish, checks every plugin is installed and loads |

Add a plugin: add a line to `fish/fish_plugins` and rebuild (or `fisher install owner/repo`
and commit the updated `fish_plugins`).

## Run it

**With docker** (what the fleet does):

    docker compose build
    docker compose run --rm app          # the check; exit 0 = plugins load
    docker compose run --rm app fish     # try the shell itself

**Without docker** (needs fish 3.4+ and curl; your `~/.config/fish` is left alone):

    sh scripts/install.sh                # = fleet.conf INSTALL_CMD -> ./.xdg/fish
    sh scripts/check.sh
    XDG_CONFIG_HOME="$PWD/.xdg" fish     # use it

## Origin

Fisher's documented bootstrap (its README), pinned to Fisher 4.4.8, driven by `fish_plugins`:

    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/4.4.8/functions/fisher.fish | source && fisher update

The fish config itself is hand-written to fish's config-dir layout (`config.fish`,
`conf.d/`, `functions/`).

## Deviations from stock output, and why

- `fisher update` (install everything in `fish_plugins`) instead of
  `fisher install jorgebucaran/fisher`: the plugin list is the versioned source.
- The install target is `$FISH_CONFIG_ROOT/fish` (default `./.xdg/fish`), a dedicated
  variable rather than `XDG_CONFIG_HOME`, so a local run can never overwrite your real
  fish config. The image uses `/home/app/.config/fish` — the normal location.
- fish comes from Debian bookworm's package (fish 3.6); there is no official fish image.
## Verified

**The docker image has NOT been built or run yet**: on 2026-10-05 the shared build host's docker disk was full (0-2 GB free for over 8 hours), so `docker compose build` was never attempted. Run `docker compose build && docker compose run --rm app` once before trusting it.

Without docker it has not been run either: fish is not installed on the build host.
Nothing in this template has been executed yet.


## Fleet lifecycle

`fleet.conf` drives every script in `bin/` (see `docs/fleet-lifecycle.md`). On the fleet
the docker runtime runs `DOCKER_BUILD_CMD` (`docker compose build`) and, because this is
a job and not a service, stops there: `DOCKER_START_CMD` is empty, the same as
`START_CMD`. Run the job itself with `docker compose run --rm app`.

    ./bin/run                    # docker runtime: builds the image, then stops (no server)
    docker compose run --rm app  # runs the job; exit code 0 = pass
    FLEET_RUNTIME=process ./bin/run   # no docker: runs INSTALL_CMD, then stops at start

`bin/run` ends with the template's own "no START_CMD" message — that is intentional.

## Serving over HTTP

Fleet apps are served at the root of their own hostname
(`https://<hash>.<FLEET_APP_DOMAIN>/`). **This repo has no HTTP surface**: `PORT`,
`HEALTH_PATH` and `START_CMD` are empty and `compose.yaml` publishes nothing. If you add
an HTTP endpoint, listen on `0.0.0.0:$PORT` (read at runtime), serve at `/`, set `PORT`,
`HEALTH_PATH`, `START_CMD` and `DOCKER_START_CMD='docker compose up --remove-orphans'`
in `fleet.conf`, and publish `"${PORT:-N}:${PORT:-N}"` in `compose.yaml`.

`compose.yaml` passes the fleet's variables (`DATABASE_URL`, `REDIS_URL`, `S3_*`,
`SMTP_*` …) through to the container without values; this template reads none of them.

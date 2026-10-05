# Built by .github/workflows/deploy.yml (context ., file Dockerfile) and pushed
# to Artifact Registry.
#
# A job image, not a server: fish (Debian's package), this repo's fish setup installed as
# a non-root user's ~/.config/fish, and the plugins in fish_plugins installed by Fisher
# (pinned release — scripts/install.sh). The default command starts an interactive fish
# and checks the plugins load (scripts/check.sh). Exits 0 when they do.

FROM debian:bookworm-slim
ARG BUILD_ID=""
RUN apt-get update \
 && apt-get install -y --no-install-recommends fish curl ca-certificates git \
 && rm -rf /var/lib/apt/lists/*
RUN useradd -m -u 10001 -s /usr/bin/fish app && mkdir /app && chown app:app /app
ENV BUILD_ID=$BUILD_ID FISH_CONFIG_ROOT=/home/app/.config TERM=xterm-256color

WORKDIR /app
USER app
COPY --chown=app:app . .
RUN sh scripts/install.sh
CMD ["sh", "scripts/check.sh"]

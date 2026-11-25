#!/usr/bin/env bash
# Pull a Tension Board 2 logbook to CSV. Interactive by default; the
# monthly scheduler sets USERNAME and TENSION_PASSWORD env vars and
# skips the prompts.
#
# Optional: set GIT_REPO_PATH to a clone of the comp's GitHub repo.
# The script then copies the fresh CSV into data/ there and git-pushes
# it. Needs write access on that laptop (gh auth login, or an SSH key).
set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/Library/Python/3.9/bin:$PATH"

OUTDIR="$HOME/Desktop/tension-comp"
LOGFILE="$OUTDIR/pull.log"
mkdir -p "$OUTDIR"
DBFILE="$OUTDIR/tension.sqlite3"

: "${USERNAME:=}"
: "${TENSION_PASSWORD:=}"
: "${GIT_REPO_PATH:=}"
: "${GIT_REMOTE_NAME:=origin}"

if [[ -z "$USERNAME" ]]; then
  read -rp "Tension username (or account email): " USERNAME
fi
if [[ -z "$TENSION_PASSWORD" ]]; then
  read -rsp "Tension password for $USERNAME: " TENSION_PASSWORD
  echo
fi
export TENSION_PASSWORD

SLUG=$(printf '%s' "$USERNAME" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '_' | sed 's/^_//;s/_$//')
OUTFILE="$OUTDIR/${SLUG}_sends.csv"

{
  echo
  echo "=== $(date -Iseconds) ==="
  echo "User: $USERNAME"
} >> "$LOGFILE"

echo "==> Syncing Tension Board climb database"
boardlib database tension "$DBFILE" 2>&1 | tee -a "$LOGFILE"

echo "==> Pulling logbook for $USERNAME"
boardlib logbook tension \
  --username="$USERNAME" \
  --database-path "$DBFILE" \
  --output "$OUTFILE" 2>&1 | tee -a "$LOGFILE"

unset TENSION_PASSWORD

echo "Saved to: $OUTFILE"

# Optional: copy into the comp repo and push.
if [[ -n "$GIT_REPO_PATH" && -d "$GIT_REPO_PATH/.git" ]]; then
  REPO_DATA="$GIT_REPO_PATH/data"
  mkdir -p "$REPO_DATA"
  cp "$OUTFILE" "$REPO_DATA/${SLUG}_sends.csv"
  pushd "$GIT_REPO_PATH" >/dev/null
  git add "data/${SLUG}_sends.csv"
  if ! git diff --cached --quiet; then
    git -c user.name="$(git config user.name || echo "$USER")" \
        -c user.email="$(git config user.email || echo "$USER@$(hostname -s)")" \
        commit -m "Monthly pull: $SLUG ($(date -I))"
    git push "$GIT_REMOTE_NAME" HEAD:main
    echo "Pushed to $GIT_REMOTE_NAME/main"
  else
    echo "No change in CSV; nothing to push."
  fi
  popd >/dev/null
fi

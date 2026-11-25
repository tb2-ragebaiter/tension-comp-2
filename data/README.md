# data/

CSVs that the live site auto-loads on every page view.

- `manifest.json` — the list of climbers and their CSV filenames. Edit
  this when you add or remove a climber.
- `<climber>_sends.csv` — one BoardLib export per climber, written by
  `scripts/pull-logbook.sh`.

## Adding or updating a climber

1. Drop a fresh CSV in here (overwrite the old one).
2. Make sure `manifest.json` has a matching entry.
3. Commit and push:
   ```
   git add data/
   git commit -m "Update Ben Ryan's logbook"
   git push
   ```
4. GitHub Pages rebuilds in ~60 seconds. Next page view picks up the
   new numbers; the page fetches with `cache: "no-store"`, so no
   hard-refresh is needed.

## Automating the monthly refresh

See `scripts/setup-monthly-pull.sh` for the macOS launchd job that
runs `pull-logbook.sh` on the 1st of each month. Two ways to get the
resulting CSV into this folder:

- **By hand:** AirDrop / email the CSV to whoever runs the repo, who
  drops it in here and pushes.
- **Automatic:** set `GIT_REPO_PATH` and `GIT_REMOTE_NAME` env vars
  before running `pull-logbook.sh`. It'll copy the CSV into
  `$GIT_REPO_PATH/data/`, commit, and push. Only works if that laptop
  has write access to the repo (git credential helper, SSH key, or a
  `gh auth login` session).

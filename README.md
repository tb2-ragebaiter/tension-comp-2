# Tension Board 2 Comp

A tiny static leaderboard for a Tension Board 2 comp among friends.
The page lives on GitHub Pages, reads BoardLib CSVs out of `data/`,
and calls a Chad (top) and a Chud (bottom) for every calendar month.
The leaderboard rolls over automatically on the 1st.

The comp opens **January 2027**. Until then the page is in preseason
mode — step through recent months to test scoring with friends.

Nothing on this site talks to Tension or asks for a password. Each
climber pulls their own logbook on their own Mac, then the CSV ends
up under `data/` here (manually, or via the scheduled pull script).

## What's in this repo

- `index.html` — the leaderboard. Month nav, Chad/Chud cards, season
  totals, monthly roll call, drop zone for one-off CSV uploads.
- `data/manifest.json` — the list of climbers the site auto-loads on
  every page view, with one file name per climber.
- `data/<climber>_sends.csv` — one BoardLib export per climber.
- `scripts/install-boardlib.sh` — one-time BoardLib install for macOS.
- `scripts/pull-logbook.sh` — run on a climber's Mac to pull their
  logbook. Optionally copies the CSV into a repo clone and pushes.
- `scripts/setup-monthly-pull.sh` — a macOS launchd scheduler that
  runs `pull-logbook.sh` on the 1st of every month.

## Hosting on GitHub Pages

1. Push this folder to a GitHub repo.
2. **Settings → Pages → Deploy from a branch → `main` → `/`**. Save.
3. In a minute: `https://<your-user>.github.io/<repo-name>/`.

The site fetches `data/manifest.json` and every CSV it names with
`cache: "no-store"`, so a new push is visible on the next page view
with no hard-refresh.

## Workflow once the comp is running

### For each climber (one-time)

1. Grab `scripts/install-boardlib.sh` and `scripts/pull-logbook.sh`.
2. In Terminal, from the folder with those files:
   ```
   chmod +x install-boardlib.sh pull-logbook.sh
   ./install-boardlib.sh
   ```
   Open a fresh Terminal window after it finishes.
3. **To auto-pull every month**, also run:
   ```
   chmod +x setup-monthly-pull.sh
   ./setup-monthly-pull.sh
   ```
   It asks for Tension username, password, and (optionally) the path
   to a clone of the comp repo on that laptop. Password is stored
   only in a plist file under `~/Library/LaunchAgents`, `chmod 600`,
   never leaving that account.

### Each month (automatic if you set up the schedule)

On the 1st at 9:05 AM, the launchd job runs `pull-logbook.sh`:
- Writes `~/Desktop/tension-comp/<username>_sends.csv`.
- If `GIT_REPO_PATH` was set, also copies the CSV into the repo's
  `data/` folder and pushes to the default remote.

If `GIT_REPO_PATH` wasn't set, that climber AirDrops / iMessages the
CSV to the comp runner, who drops it into `data/` and pushes.

### Pushing a CSV by hand

```
cd ~/path/to/the/repo
# Put the CSV where it belongs, then:
git add data/
git commit -m "Monthly update"
git push
```
Add a new entry to `data/manifest.json` the first time you add a
climber.

## Scoring rules (short version)

| Font | V | Points | Classic (+25%) |
| ---- | -- | ------ | -------------- |
| 4 | V0 | 1 | 1 |
| 5 | V1 | 2 | 3 |
| 5+ | V2 | 3 | 4 |
| 6a | V3 | 5 | 6 |
| 6a+ | V3 | 7 | 9 |
| 6b | V4 | 10 | 13 |
| 6b+ | V4 | 14 | 18 |
| 6c | V5 | 20 | 25 |
| 6c+ | V5 | 28 | 35 |
| 7a | V6 | 40 | 50 |
| 7a+ | V7 | 56 | 70 |
| 7b | V8 | 80 | 100 |
| 7b+ | V8 | 110 | 138 |
| 7c | V9 | 150 | 188 |
| 7c+ | V10 | 210 | 263 |
| 8a | V11 | 290 | 363 |
| 8a+ | V12 | 400 | 500 |
| 8b | V13 | 550 | 688 |

- **Benchmarks** on Tension score as classics: +25% over the base.
- **Mirrors** of a climb you've already sent are worth 90%. Earliest
  non-mirror ascent decides, so the order you log things in doesn't
  matter.
- **Repeats** (`is_repeat=true`) show up but score 0. Each climb only
  counts once per climber.

## Known caveats

- BoardLib is unofficial. It drives Aurora Climbing's private API; a
  Tension app update could break it.
- The auto-push flow requires git credentials on each laptop that
  runs the scheduler. Use `gh auth login` (easiest), SSH keys, or a
  personal access token.
- Browser storage (`localStorage`) only holds climbers you drop in by
  hand on this browser. Everyone sees the same leaderboard numbers
  from `data/` on GitHub Pages — local uploads are just overlays.

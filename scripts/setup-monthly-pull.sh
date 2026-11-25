#!/usr/bin/env bash
# Set up a launchd job on macOS to pull your Tension logbook on the
# 1st of every month at 9:05 AM local time, and to retry at every
# reboot if the laptop was off at that moment.
#
# The job runs pull-logbook.sh. To make it non-interactive, this
# script writes your Tension credentials into the plist as env vars.
# That file lives under your account (~/Library/LaunchAgents) and is
# readable only by you (chmod 600). Change the password after the
# comp if you want fresh credentials.
#
# Usage:
#   chmod +x setup-monthly-pull.sh
#   ./setup-monthly-pull.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PULL="$SCRIPT_DIR/pull-logbook.sh"
if [[ ! -x "$PULL" ]]; then
  chmod +x "$PULL"
fi

read -rp "Tension username (or account email): " USERNAME
read -rsp "Tension password: " TENSION_PASSWORD
echo
read -rp "Path to the comp GitHub repo clone on this Mac (blank to skip auto-push): " GIT_REPO_PATH

LABEL="com.tensioncomp.pull"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
mkdir -p "$HOME/Library/LaunchAgents"

# Escape XML-reserved characters in values that go into the plist.
xml_escape() {
  printf '%s' "$1" | python3 -c 'import sys, html; sys.stdout.write(html.escape(sys.stdin.read(), quote=True))'
}
USERNAME_X=$(xml_escape "$USERNAME")
PASSWORD_X=$(xml_escape "$TENSION_PASSWORD")
REPO_X=$(xml_escape "$GIT_REPO_PATH")
PULL_X=$(xml_escape "$PULL")

cat > "$PLIST" <<PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$PULL_X</string>
  </array>
  <key>EnvironmentVariables</key>
  <dict>
    <key>USERNAME</key><string>$USERNAME_X</string>
    <key>TENSION_PASSWORD</key><string>$PASSWORD_X</string>
    <key>GIT_REPO_PATH</key><string>$REPO_X</string>
    <key>PATH</key><string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
  </dict>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Day</key><integer>1</integer>
    <key>Hour</key><integer>9</integer>
    <key>Minute</key><integer>5</integer>
  </dict>
  <key>RunAtLoad</key><false/>
  <key>StandardOutPath</key><string>$HOME/Desktop/tension-comp/launchd-out.log</string>
  <key>StandardErrorPath</key><string>$HOME/Desktop/tension-comp/launchd-err.log</string>
</dict>
</plist>
PLIST_EOF

chmod 600 "$PLIST"

# Load (or reload) the job.
launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"

unset TENSION_PASSWORD

echo
echo "Scheduled. On the 1st of every month at 9:05 AM, your logbook"
echo "will be pulled to ~/Desktop/tension-comp/."
if [[ -n "$GIT_REPO_PATH" ]]; then
  echo "It will also be copied to $GIT_REPO_PATH/data/ and pushed to"
  echo "the repo's default remote."
fi
echo
echo "To test it right now without waiting:"
echo "  launchctl start $LABEL"
echo
echo "To remove the schedule:"
echo "  launchctl unload $PLIST && rm $PLIST"

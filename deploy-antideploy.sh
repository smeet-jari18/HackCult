#!/usr/bin/env bash
# Build the Flutter web app and push it to Antideploy as a static site.
#
#   bash deploy-antideploy.sh
#
# Needs: Flutter SDK, curl, tar.
# Needs: an Antideploy token at ~/.antideploy/config.json  (mode 0600)
#        or the ANTIDEPLOY_TOKEN environment variable.
#
# The token is never printed.
set -euo pipefail
cd "$(dirname "$0")"

APP_ID=$(python3 -c "import json;print(json.load(open('.antideploy.json'))['applicationId'])")
API="https://antideploy.com/api/v1"

if [ -n "${ANTIDEPLOY_TOKEN:-}" ]; then
  TOKEN="$ANTIDEPLOY_TOKEN"
elif [ -s "$HOME/.antideploy/config.json" ]; then
  TOKEN=$(sed -n 's/.*"token"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$HOME/.antideploy/config.json")
else
  echo "ERROR: no Antideploy token. Put one in ~/.antideploy/config.json"; exit 1
fi
[ -n "$TOKEN" ] || { echo "ERROR: token file had no token field"; exit 1; }

echo "==> 1/4  flutter pub get"
flutter pub get

echo "==> 2/4  analyze + tests"
flutter analyze
flutter test test/

echo "==> 3/4  build web (release)"
# --no-wasm-dry-run skips the extra dart2wasm dry-run compile: less memory, faster.
flutter build web --release --no-wasm-dry-run

# Carry the application id into the pushed folder so the association is explicit.
cp .antideploy.json build/web/.antideploy.json

echo "==> 4/4  push to Antideploy"
tar czf /tmp/hackcult-web.tar.gz -C build/web .

RESP=$(curl -fsS -X POST "$API/deploy?applicationId=$APP_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -F "archive=@/tmp/hackcult-web.tar.gz")
rm -f /tmp/hackcult-web.tar.gz

TASK=$(printf '%s' "$RESP" | python3 -c "import sys,json;print(json.load(sys.stdin).get('taskId',''))")
printf '%s\n' "$RESP" | python3 -c "
import sys,json
d=json.load(sys.stdin)
print('status  :', d.get('status'))
print('taskId  :', d.get('taskId'))
print('files   :', d.get('fileCount'))
print('account :', (d.get('account') or {}).get('label'))
"
[ -n "$TASK" ] || { echo "Nothing queued (probably unchanged content)."; exit 0; }

echo
echo "==> watching the deploy"
for i in $(seq 1 120); do
  S=$(curl -fsS "$API/deployments/$TASK" -H "Authorization: Bearer $TOKEN")
  ST=$(printf '%s' "$S" | python3 -c "import sys,json;print(json.load(sys.stdin).get('status',''))")
  echo "  [$i] $ST"
  case "$ST" in
    succeeded|failed)
      printf '%s' "$S" > /tmp/antideploy-last.json
      printf '%s\n' "$S" | python3 -c "
import sys,json
d=json.load(sys.stdin)
print()
print('summary :', d.get('summary'))
print('error   :', d.get('error'))
sec=d.get('security') or {}
print('security:', sec.get('status'), sec.get('issues') or '')
"
      [ "$ST" = succeeded ] || exit 1
      exit 0 ;;
  esac
  sleep 5
done
echo "Still running; check the dashboard."

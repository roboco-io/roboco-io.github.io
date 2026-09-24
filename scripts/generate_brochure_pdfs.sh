#!/usr/bin/env bash
# Render the three A4 brochures using Chrome, Python 3, and Poppler.
# Keep the editable copies and the website downloads byte-identical.
set -euo pipefail

BROCHURE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BROCHURE_CHROME="${BROCHURE_CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
BROCHURE_WORK="$(mktemp -d)"
trap 'rm -rf "$BROCHURE_WORK"' EXIT

if [[ ! -x "$BROCHURE_CHROME" ]]; then
  echo 'Chrome was not found. Set BROCHURE_CHROME to its executable path.' >&2
  exit 1
fi
command -v pdfinfo >/dev/null
command -v python3 >/dev/null

for slug in roboco-brochure roboco-brochure.en roboco-brochure.ja; do
  python3 - "$BROCHURE_CHROME" "$BROCHURE_ROOT/docs/brochure/$slug.html" \
    "$BROCHURE_WORK/$slug.pdf" "$BROCHURE_WORK/profile-$slug" \
    "$BROCHURE_WORK/$slug.log" <<'PY'
from pathlib import Path
import os
import signal
import subprocess
import sys
import time

chrome, source, output, profile, log_path = sys.argv[1:]
args = [chrome, '--headless', '--disable-gpu', f'--user-data-dir={profile}',
        '--no-pdf-header-footer', f'--print-to-pdf={output}', Path(source).as_uri()]
with open(log_path, 'w') as log:
    process = subprocess.Popen(args, stdout=log, stderr=log, start_new_session=True)
    try:
        deadline = time.monotonic() + 45
        while time.monotonic() < deadline:
            if Path(output).is_file():
                info = subprocess.run(['pdfinfo', output], capture_output=True, timeout=5)
                if info.returncode == 0:
                    break
            if process.poll() is not None:
                break
            time.sleep(0.2)
    finally:
        # Some Chrome versions remain alive after writing the complete PDF.
        # Stop only this isolated renderer and its children, never the user's browser.
        try:
            os.killpg(process.pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
        cleanup_deadline = time.monotonic() + 5
        while time.monotonic() < cleanup_deadline:
            process.poll()  # Reap the parent even when its children outlive it.
            try:
                os.killpg(process.pid, 0)
            except ProcessLookupError:
                break
            time.sleep(0.1)
        else:
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
        process.wait(timeout=5)
# Also cover Chrome exiting between the file check and process.poll().
final_info = subprocess.run(['pdfinfo', output], capture_output=True, timeout=5)
if final_info.returncode != 0:
    print(Path(log_path).read_text()[-3000:], file=sys.stderr)
    raise SystemExit(f'PDF rendering did not finish: {source}')
PY
  pages="$(pdfinfo "$BROCHURE_WORK/$slug.pdf" | awk '/^Pages:/ {print $2}')"
  if [[ "$pages" != "4" ]]; then
    echo "$slug: expected 4 pages, got $pages. Check the layout before publishing." >&2
    exit 1
  fi
done

mkdir -p "$BROCHURE_ROOT/static/brochure"
for slug in roboco-brochure roboco-brochure.en roboco-brochure.ja; do
  install -m 644 "$BROCHURE_WORK/$slug.pdf" "$BROCHURE_ROOT/docs/brochure/$slug.pdf"
  install -m 644 "$BROCHURE_WORK/$slug.pdf" "$BROCHURE_ROOT/static/brochure/$slug.pdf"
  echo "Generated $slug.pdf (4 pages; source and download copies synchronized)"
done

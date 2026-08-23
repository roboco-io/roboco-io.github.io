#!/usr/bin/env bash
# Privacy Policy·DPA 양식을 PDF로 생성해 static/docs/ 에 저장한다.
# 소스: content/{ko,en,ja}/privacy.md, docs/legal/dpa-template.{ko,en,ja}.md
# 요구 도구: pandoc, Google Chrome (headless)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
OUT_DIR="$ROOT/static/docs"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

mkdir -p "$OUT_DIR"

CSS='
@page { margin: 25mm 20mm; }
body {
  font-family: "Apple SD Gothic Neo", "Hiragino Sans", "Helvetica Neue", sans-serif;
  font-size: 10.5pt; line-height: 1.7; color: #1a1a1a;
  max-width: 100%; margin: 0;
}
h1 { font-size: 17pt; border-bottom: 2px solid #1a1a1a; padding-bottom: 8px; }
h2 { font-size: 12.5pt; margin-top: 1.6em; }
blockquote {
  margin: 1em 0; padding: 8px 14px; border-left: 3px solid #888;
  background: #f5f5f5; color: #444; font-size: 9.5pt;
}
table { border-collapse: collapse; width: 100%; margin: 1em 0; }
th, td { border: 1px solid #999; padding: 6px 10px; text-align: left; font-size: 10pt; }
a { color: #1a1a1a; }
hr { border: none; border-top: 1px solid #999; margin: 2em 0; }
.doc-footer { margin-top: 3em; font-size: 9pt; color: #666; border-top: 1px solid #ccc; padding-top: 8px; }
'

# md_to_pdf <md파일> <출력pdf> <lang> [--strip-frontmatter]
md_to_pdf() {
  local src="$1" out="$2" lang="$3" strip="${4:-}"
  local slug base body html
  base="$(basename "$out" .pdf)"
  body="$WORK_DIR/$base.md"
  html="$WORK_DIR/$base.html"

  if [[ "$strip" == "--strip-frontmatter" ]]; then
    # frontmatter의 title을 H1으로 승격하고 본문만 추출
    local title
    title="$(awk -F'"' '/^title:/ {print $2; exit}' "$src")"
    # 웹 전용 PDF 다운로드 안내 줄(📄)은 PDF 본문에서 제외
    { echo "# $title"; echo; awk 'c==2 {print} /^---$/ {c++}' "$src" | grep -v '^📄'; } > "$body"
  else
    cp "$src" "$body"
  fi

  # PDF 내 내부 링크를 절대 URL로 변환
  sed -i '' -E 's#\]\(/#](https://roboco.io/#g' "$body"

  printf '\n\n<div class="doc-footer">ROBOCO · https://roboco.io · contact@roboco.io</div>\n' >> "$body"

  pandoc "$body" -f gfm -t html5 -s \
    --metadata title="$base" --metadata lang="$lang" \
    -V "header-includes=<style>$CSS</style>" \
    -o "$html"
  # pandoc -s 가 넣는 자동 제목 블록 제거(본문 H1 사용)
  perl -0pi -e 's#<header id="title-block-header">.*?</header>##s' "$html"

  "$CHROME" --headless --disable-gpu --no-pdf-header-footer \
    --print-to-pdf="$out" "file://$html" 2>/dev/null
  echo "generated: ${out#$ROOT/}"
}

for lang in ko en ja; do
  for pair in "content/$lang/privacy.md:roboco-privacy-policy-$lang.pdf:--strip-frontmatter" \
              "docs/legal/dpa-template.$lang.md:roboco-dpa-template-$lang.pdf:"; do
    IFS=':' read -r src out strip <<< "$pair"
    if [[ -f "$ROOT/$src" ]]; then
      md_to_pdf "$ROOT/$src" "$OUT_DIR/$out" "$lang" $strip
    else
      echo "skip (missing source): $src" >&2
    fi
  done
done

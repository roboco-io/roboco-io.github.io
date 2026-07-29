# 다국어(영어/일어) 인프라 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Hugo 사이트에 ko(루트)/en(/en/)/ja(/ja/) 다국어 인프라를 구축하고 정적 페이지 4개를 영/일로 번역한다. 포스트 번역은 범위 밖.

**Architecture:** 언어별 contentDir(`content/ko|en|ja`) 방식. 기존 콘텐츠는 `git mv`로 `content/ko/`에 이동하고 `defaultContentLanguageInSubdir: false`로 한국어 URL을 그대로 보존한다. 언어 전환은 테마 내장 메뉴(`enableGlobalLanguageMenu`)를 사용한다.

**Tech Stack:** Hugo v0.143.1, hello-friend-ng 테마(서브모듈), GitHub Pages/Actions

## Global Constraints

- 한국어 기존 URL은 1바이트도 바뀌면 안 됨 (`/about`, `/posts/...`, `/posts/images/...` 등)
- 스펙: `docs/superpowers/specs/2026-07-29-multilingual-design.md`
- 푸시는 사용자 승인 후에만. 로컬 검증(빌드 + 페이지 확인)이 모든 태스크의 완료 조건
- 커밋 메시지는 기존 컨벤션(`feat(content):`, `docs(content):` 등) 준수
- 이 저장소에 테스트 프레임워크는 없음 — "테스트"는 `hugo` 빌드와 빌드 산출물(`public/`) 검사로 대체

---

### Task 1: 다국어 설정 + 콘텐츠 재배치 (ko URL 보존 검증 포함)

**Files:**
- Modify: `hugo.yaml`
- Move: `content/{about,solutions,products,contact}.md`, `content/posts/` → `content/ko/`
- Create: `content/en/posts/_index.md`, `content/ja/posts/_index.md`

**Interfaces:**
- Produces: `content/en/`, `content/ja/` 디렉토리 (Task 2·3이 여기에 번역 파일 생성), 언어별 params(`languages.<lang>.params.homeSubtitle`)

- [ ] **Step 1: 마이그레이션 전 ko 빌드 스냅샷 생성 (비교 기준)**

```bash
cd /Users/dohyunjung/Workspace/roboco-io/company/roboco-io.github.io
rm -rf public && hugo --quiet && (cd public && find . -type f | sort) > /tmp/claude-501/-Users-dohyunjung-Workspace-roboco-io-company-roboco-io-github-io/87ae508c-e02c-456d-af31-fbb6a6ae4882/scratchpad/before.txt
wc -l < .../scratchpad/before.txt  # 파일 수 기록
```

- [ ] **Step 2: 콘텐츠를 content/ko/ 로 이동**

```bash
mkdir content/ko
git mv content/about.md content/solutions.md content/products.md content/contact.md content/posts content/ko/
```

- [ ] **Step 3: hugo.yaml에 다국어 설정 추가**

최상단 블록에 추가/수정 (기존 `languageCode: "ko-kr"` 라인은 삭제하고 languages 블록으로 이관):

```yaml
defaultContentLanguage: "ko"
defaultContentLanguageInSubdir: false

languages:
  ko:
    languageName: "한국어"
    languageCode: "ko-kr"
    weight: 1
    contentDir: "content/ko"
    title: "ROBOCO"
    params:
      homeSubtitle: "로보코는 검증된 솔루션과 프로세스로 바이브 코딩을 통한 비즈니스 혁신을 돕는 IT 컨설팅 파트너입니다."
  en:
    languageName: "English"
    languageCode: "en-us"
    weight: 2
    contentDir: "content/en"
    title: "ROBOCO"
    params:
      homeSubtitle: "ROBOCO is an IT consulting partner that helps you transform your business through vibe coding, backed by proven solutions and processes."
  ja:
    languageName: "日本語"
    languageCode: "ja"
    weight: 3
    contentDir: "content/ja"
    title: "ROBOCO"
    params:
      homeSubtitle: "ROBOCOは、実績あるソリューションとプロセスでバイブコーディングによるビジネス変革を支援するITコンサルティングパートナーです。"
```

기존 `params.homeSubtitle`(한국어 문장)은 `languages.ko.params`로 옮겼으므로 `params:` 블록에서 삭제. `params.enableGlobalLanguageMenu`를 `true`로 변경.

주의: 최상위 `menu.main`은 그대로 둔다(메뉴명이 이미 영문). Step 6 검증에서 en/ja 페이지에 메뉴가 안 나오면 `languages.<lang>.menu`로 각 언어에 동일 블록을 복제하는 폴백을 적용.

- [ ] **Step 4: en/ja의 빈 posts 섹션 생성 (메뉴 404 방지)**

`content/en/posts/_index.md`:
```yaml
---
title: "Posts"
---
```

`content/ja/posts/_index.md`:
```yaml
---
title: "Posts"
---
```

- [ ] **Step 5: 빌드 후 ko URL 보존 검증 (핵심 테스트)**

```bash
rm -rf public && hugo --quiet && (cd public && find . -type f | sort) > .../scratchpad/after.txt
# ko 산출물이 전부 동일 경로에 존재하는지: before에 있던 파일 중 after에 없는 것 = 0건이어야 함
comm -23 .../scratchpad/before.txt <(grep -v '^\./en/\|^\./ja/' .../scratchpad/after.txt | sort)
```

Expected: 출력 없음(누락 0건). sitemap.xml은 다국어 전환 시 루트 sitemap이 sitemap index로 바뀌므로 내용 차이는 허용, 경로 누락만 검사. 누락이 있으면 원인 분석 후 수정(대표 의심점: `url:` frontmatter, 이미지 경로).

- [ ] **Step 6: en/ja 산출물 존재 확인**

```bash
ls public/en/index.html public/ja/index.html public/en/posts/index.html public/ja/posts/index.html
grep -o 'homeSubtitle 각 언어 문장 일부' public/en/index.html public/ja/index.html  # 예: "consulting partner", "コンサルティング"
```

Expected: 4개 파일 존재, 각 언어 index.html에 해당 언어 subtitle 렌더링. 메뉴(About/Solutions/...)가 en/ja 페이지에도 렌더링되는지 `grep -c 'menu__inner' public/en/index.html`로 확인 — 없으면 Step 3의 폴백(언어별 menu 복제) 적용 후 재검증.

- [ ] **Step 7: 커밋**

```bash
git add -A && git commit -m "feat(i18n): add multilingual infrastructure (ko root, /en/, /ja/)"
```

---

### Task 2: 정적 페이지 영어 번역

**Files:**
- Create: `content/en/about.md`, `content/en/solutions.md`, `content/en/products.md`, `content/en/contact.md`

**Interfaces:**
- Consumes: `content/ko/{about,solutions,products,contact}.md` (원문), Task 1의 en 언어 설정

- [ ] **Step 1: 원문 4개를 읽고 자연스러운 영어로 전체 번역하여 생성**

frontmatter 규칙 (본문은 원문 의미·구조·마크다운 서식을 유지한 전문 번역, 기계번역 투 금지):
- `title`, `summary`, `description`: 영어로 번역
- `url:` 필드는 **제거** (기본 경로 `/en/about/` 등을 사용 — url frontmatter는 언어 프리픽스와 충돌 위험)
- `layout`, `draft`, `date`는 원문 그대로 유지
- 고유명사: ROBOCO, 바이브 코딩→vibe coding, 회사 서비스명은 원문 페이지의 기존 영문 표기 우선

- [ ] **Step 2: 빌드 검증**

```bash
hugo --quiet && ls public/en/about/index.html public/en/solutions/index.html public/en/products/index.html public/en/contact/index.html
```

Expected: 4개 파일 존재, 빌드 에러 없음. `grep -l '한글이 남아있는지'` 식으로 en 페이지에 한국어 잔존 여부 검사: `grep -o '[가-힣]\{2,\}' public/en/about/index.html | head` → 출력 없어야 함(단, 언어 전환 메뉴의 "한국어" 표기는 허용).

- [ ] **Step 3: 커밋**

```bash
git add content/en && git commit -m "feat(content): add English translations of static pages"
```

---

### Task 3: 정적 페이지 일어 번역

**Files:**
- Create: `content/ja/about.md`, `content/ja/solutions.md`, `content/ja/products.md`, `content/ja/contact.md`

**Interfaces:**
- Consumes: `content/ko/{about,solutions,products,contact}.md` (원문), Task 1의 ja 언어 설정

- [ ] **Step 1: 원문 4개를 자연스러운 일본어(비즈니스 경어체, です・ます調)로 전체 번역하여 생성**

frontmatter 규칙은 Task 2와 동일: `title`/`summary`/`description` 번역, `url:` 제거, `layout`/`draft`/`date` 유지. 바이브 코딩→バイブコーディング.

- [ ] **Step 2: 빌드 검증**

```bash
hugo --quiet && ls public/ja/about/index.html public/ja/solutions/index.html public/ja/products/index.html public/ja/contact/index.html
grep -o '[가-힣]\{2,\}' public/ja/about/index.html | head  # 한국어 잔존 검사(언어 메뉴 제외 0건)
```

- [ ] **Step 3: 커밋**

```bash
git add content/ja && git commit -m "feat(content): add Japanese translations of static pages"
```

---

### Task 4: 로컬 서버 종합 검증 및 최종 리포트

**Files:** 없음 (검증 전용; 발견된 결함은 해당 파일 수정)

**Interfaces:**
- Consumes: Task 1~3의 전체 결과

- [ ] **Step 1: 로컬 서버 기동 및 페이지 스모크 테스트**

```bash
hugo server --port 1414 &  # background
sleep 3
for p in / /about/ /posts/ /en/ /en/about/ /en/solutions/ /en/products/ /en/contact/ /en/posts/ /ja/ /ja/about/ /ja/solutions/ /ja/products/ /ja/contact/ /ja/posts/; do
  echo "$p $(curl -s -o /dev/null -w '%{http_code}' http://localhost:1414$p)"
done
```

Expected: 전부 200. (`/about`은 기존 url frontmatter 유지로 `/about` 직접 응답도 200 확인)

- [ ] **Step 2: 언어 전환 메뉴 확인**

```bash
curl -s http://localhost:1414/en/about/ | grep -A3 'dropdown-content'
```

Expected: ko/ja 페이지로의 번역 링크 존재. 정적 페이지 4개는 3개 언어 모두 존재하므로 상호 링크가 나와야 함.

- [ ] **Step 3: RSS/사이트맵 확인**

```bash
for p in /posts/index.xml /en/posts/index.xml /ja/posts/index.xml /sitemap.xml; do
  echo "$p $(curl -s -o /dev/null -w '%{http_code}' http://localhost:1414$p)"
done
```

Expected: 전부 200. 루트 sitemap.xml이 언어별 sitemap을 가리키는 index인지 확인.

- [ ] **Step 4: 서버 종료 및 사용자 보고**

검증 결과 표(URL별 상태)와 함께 사용자에게 보고하고, 브라우저로 직접 확인하도록 안내(`hugo server -D` 재기동 방법 포함). **푸시는 사용자 승인 후에만 진행.**

- [ ] **Step 5: (사용자 승인 후) 푸시**

```bash
git push origin main && git log origin/main --oneline -3  # 푸시 성공 확인
```

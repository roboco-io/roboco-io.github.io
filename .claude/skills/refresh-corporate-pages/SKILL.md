---
name: refresh-corporate-pages
description: roboco-io.github.io의 about.md / solutions.md / products.md를 최근 활동으로 보강할 초안을 생성. "about 업데이트", "solutions 갱신", "products 갱신", "회사 페이지 최신화", "최근 프로젝트 반영", "refresh-corporate-pages" 등의 키워드로 트리거. 원본은 절대 덮어쓰지 않고 docs/drafts/ 에 초안 파일을 만든다. about/solutions는 로컬 roboco-io/ 워크스페이스 스캔, products는 GitHub roboco-io org 스캔. 프로젝트 선택과 소개 문구는 모두 AskUserQuestion으로 사용자 확인을 거친다.
---

# refresh-corporate-pages

`roboco-io.github.io` 사이트의 세 페이지를 최근 활동을 근거(proof point)로 업데이트할 **초안**을 생성한다.

| 대상 | 데이터 소스 | 분류 기준 |
|---|---|---|
| `content/about.md` | 로컬 `/Users/dohyunjung/Workspace/roboco-io/` 카테고리 디렉토리 | 카테고리 → 핵심 역량/주도성 근거 |
| `content/solutions.md` | 동일 (로컬 워크스페이스) | 카테고리 → 서비스 티어 |
| `content/products.md` | **GitHub `roboco-io` org**(gh CLI) | 6개월 내 활동한 public 리포지토리 |

이 스킬은 **원본 파일을 절대 덮어쓰지 않는다.** `docs/drafts/` 아래에 초안 파일을 만들고, 사용자가 직접 검토 후 반영한다.

## 사전 조건

- 현재 작업 디렉토리가 `roboco-io.github.io` 저장소 루트여야 한다. 아니면 사용자에게 알리고 중단한다.
- about/solutions 흐름: 워크스페이스 루트는 `/Users/dohyunjung/Workspace/roboco-io/` 로 가정.
- products 흐름: `gh auth status` 통과 필요. 실패 시 사용자에게 `gh auth login` 을 안내하고 중단.

## 0단계 — 어느 페이지를 갱신할지 선택

자연어 트리거에서 명시되지 않았으면 **AskUserQuestion(multiSelect=true)** 으로 묻는다.

옵션: `about.md`, `solutions.md`, `products.md`, `세 페이지 모두`.

선택된 페이지만 흐름을 진행한다. about과 solutions은 같은 스캔 결과를 공유하므로 한 번만 스캔한다.

---

## 흐름 A — about.md / solutions.md (로컬 워크스페이스 스캔)

### A1) 스캔 범위 결정

대상 카테고리(고정): `tools/`, `education/`, `research/`, `consulting/`, `services/`, `demos/`
**제외**: `company/` (자기 자신), 그리고 사용자가 명시적으로 빠뜨리라고 한 디렉토리.

윈도우 기본값은 **최근 6개월**. 사용자가 인자로 다르게 지시했으면 그 값을 쓴다.

### A2) 후보 수집 (Bash)

각 카테고리 아래의 모든 1단계 하위 디렉토리에 대해 다음을 수집한다:

```bash
for dir in /Users/dohyunjung/Workspace/roboco-io/{tools,education,research,consulting,services,demos}/*/; do
  name=$(basename "$dir")
  last_commit=$(git -C "$dir" log -1 --format=%cI 2>/dev/null || echo "")
  echo "$last_commit|$dir|$name"
done | sort -r
```

- `git log` 가 실패하는(저장소 아님) 디렉토리는 후보에서 제외하고 사유를 부록에 적는다.
- 윈도우(예: 6개월) 밖 프로젝트도 제외 + 부록 기록.

### A3) 비공개 프로젝트 자동 필터

다음 중 하나라도 해당하면 자동 제외하고 사유를 부록에 기록:
- README/CLAUDE.md에 `Confidential`, `Private`, `비공개`, `대외비` 표시
- `git remote -v` 결과가 비어있거나 private 조직
- 디렉토리명에 클라이언트 식별자가 보이지만 README 부재

`consulting/` 아래 항목은 **기본적으로 보수적으로** 다룬다 — 익명화된 표현이 안전한지 사용자에게 별도 확인.

### A4) products.md 중복 회피

이미 `content/products.md` 에서 다루는 프로젝트는 케이스 스터디 신규 섹션에 다시 쓰지 않는다. 본문 보강용 짧은 인용은 가능. 스킬 실행 시 `content/products.md` 를 다시 읽어 최신 목록을 확정한다.

### A5) 프로젝트 선택 — **AskUserQuestion 필수**

3·4단계까지 거른 후보를 카테고리별로 묶어 사용자에게 선택받는다. **AskUserQuestion 도구를 multiSelect=true 로 호출**.

권장 묶음 방식(질문 수가 도구 한도 4개를 넘기지 않도록 카테고리를 묶을 것):

- 질문 1: "AI 부트캠프" 사례 후보 (`education/`, `demos/` 묶음)
- 질문 2: "AI 파트너십" 사례 후보 (`consulting/`, `services/` 묶음)
- 질문 3: "AI 트랜스포메이션 자문 / 핵심 역량 근거" 후보 (`research/`, `tools/` 묶음)

각 옵션의 `label`은 프로젝트명, `description`은 한 줄 요약. 옵션이 5개를 넘으면 활동 순으로 상위 4개만 노출하고, "Other"로 추가 항목을 받는다.

### A6) 소개 문구 확인 — **AskUserQuestion 필수**

선택된 각 프로젝트에 대해, README/CLAUDE.md/INTENT.md 를 근거로 **2~3문장 소개 문구 초안**을 생성한 뒤, 사용자에게 확인받는다. 옵션: 초안 그대로 / 약간 수정(Other) / 빼기.

질문은 프로젝트당 1개씩. 한 번에 최대 4개씩 묶어 처리.

### A7) 카테고리 → 활용처 매핑

| 워크스페이스 카테고리 | about.md 활용처 | solutions.md 활용처 |
|---|---|---|
| `education/`, `demos/` | "교육과 역량 이전" 역량 근거 | **AI 부트캠프** 티어 — "실제 적용 사례" |
| `consulting/`, `services/` | "주도권은 귀사에 있습니다" 근거 | **AI 파트너십** 티어 — "실제 적용 사례" |
| `research/`, `tools/` | "AI 활용 전문성", "글로벌 빅테크 경험" 근거 | **AI 트랜스포메이션 자문** 티어 — "실제 적용 사례" |

추가 분류 축(선택): **"고객 비즈니스에 직접 기여"** vs **"AI를 연구원으로 활용한 자체 실험"** 로 사례를 두 그룹으로 분리해 보여주는 패턴이 톤상 더 잘 먹는 경우가 많다 — 사용자가 톤(비즈니스 임팩트 / 기술의 민주화 / 주도성 / 피드백 루프)을 강조할 때 활용.

### A8) 초안 파일 생성

원본 `content/about.md`, `content/solutions.md` 를 다시 읽어 중복을 회피한 뒤:

- `docs/drafts/about-update-YYYY-MM-DD.md`
- `docs/drafts/solutions-update-YYYY-MM-DD.md`

각각 **A. 신규 케이스 스터디 섹션**, **B. 본문 보강 패치 제안(변경 전/후 형식)**, **C. 부록 — 스캔 메타데이터** 구조로 작성. 파일이 이미 있으면 덮어쓸지 사용자에게 확인.

---

## 흐름 B — products.md (GitHub roboco-io org 스캔)

### B1) gh 인증 확인

```bash
gh auth status
```

실패 시: "GitHub CLI 인증이 필요합니다. `gh auth login` 후 다시 실행해 주세요." 안내하고 흐름 B를 중단한다(다른 흐름은 계속 가능).

### B2) org 리포지토리 메타 수집

```bash
gh repo list roboco-io \
  --limit 200 \
  --visibility public \
  --json name,description,url,pushedAt,isArchived,isFork,primaryLanguage,stargazerCount \
  > /tmp/roboco-io-repos.json
```

후보 필터:
- `isArchived == true` → 제외
- `isFork == true` → 제외 (단, 사용자가 fork 포함을 명시했으면 포함)
- `pushedAt` 가 윈도우(기본 6개월) 밖 → 제외
- `name` 이 `roboco-io.github.io` 자기 자신이거나 사이트 인프라성 리포지토리 → 제외

### B3) products.md 중복 회피

`content/products.md` 를 읽어 이미 언급된 리포지토리 이름을 추출한다. 다음과 같은 슬러그가 본문에 등장하면 후보에서 제외하고 부록에 기록:

- H2/H3 제목, GitHub 링크(`github.com/roboco-io/<name>`), 자체 도메인(intent.roboco.io, vibemap.roboco.io 등)

현재 시점 제외 대상(검증 필요): `intent-engineering`, `vibemap`, `roboco-cli`, `awesome-vibecoding`, `hwp2md`, `plugins`.

### B4) 후보 정렬

`stargazerCount` 내림차순 또는 `pushedAt` 내림차순 중 하나로 정렬. 기본은 **활동성(pushedAt)** 우선 — products 페이지의 톤이 "최근에 다듬어 온 도구"이기 때문.

### B5) 리포지토리 선택 — **AskUserQuestion 필수(multiSelect=true)**

후보를 4개씩 묶어 질문(도구 한도). 각 옵션 `label`은 리포지토리 이름, `description`은 GitHub `description` 필드(없으면 README 첫 문장 발췌)와 마지막 활동 월(`YYYY-MM`).

후보가 많을 때는 활동순 상위만 우선 노출하고 "Other"로 추가 항목 받기 — about/solutions 흐름과 동일.

### B6) 소개 문구 초안 작성

선택된 각 리포지토리의 README 첫 부분을 읽어 소개 문구 초안을 만든다.

```bash
gh api repos/roboco-io/<name>/readme \
  -H "Accept: application/vnd.github.raw" > /tmp/<name>-readme.md
```

또는 `gh repo view roboco-io/<name> --json description,homepageUrl,languages` 로 메타데이터 추가 수집.

초안은 products.md 의 기존 톤에 맞춰 **2~4문장** + 가능하면 **"이런 분에게 유용합니다"** 불릿 2~3개. 자체 사이트(homepageUrl) 가 있으면 링크 섹션에 같이 표기.

### B7) 분류 제안 — H2 vs H3

products.md 는 두 종류 블록으로 구성:
- **H2 풀 제품 블록**: `homepageUrl` 또는 자체 도메인(`*.roboco.io`)이 있고, 인용 카피·"이런 분에게 유용합니다"·링크가 풍부한 형태
- **H3 오픈소스 도구 블록**: "## **오픈소스 도구와 리소스**" 섹션 안에 들어가는 간결한 블록(2~3문장 + GitHub 링크 1줄)

기본 분류 규칙:
- `homepageUrl != null` 이고 (`*.roboco.io` 또는 별도 사이트가 운영 중) → **H2 후보**
- 그 외 → **H3 후보**

분류는 어디까지나 제안. 다음 단계에서 사용자가 옵션으로 바꿀 수 있다.

### B8) 각 항목 컨펌 — **AskUserQuestion 필수**

각 리포지토리당 1개 질문. 옵션:

- "H3 (오픈소스 도구) 블록으로 추가 — 초안 그대로"
- "H2 (풀 제품) 블록으로 추가 — 초안 그대로"
- "약간 수정" (Other)
- "이 리포지토리는 빼기"

기본 추천(첫 번째 옵션) 위치는 B7의 분류 결과에 맞춘다. description 필드에 **초안 본문 전문**을 노출해 사용자가 한 화면에서 판단할 수 있게 한다.

한 번에 최대 4개 리포지토리씩 묶어 묻고, 응답 후 다음 묶음 진행.

### B9) 초안 파일 생성

`docs/drafts/products-update-YYYY-MM-DD.md` 작성. 파일이 이미 있으면 덮어쓸지 확인. 구조:

```markdown
---
source: products.md
generated_at: <ISO-8601>
window: <스캔 윈도우>
candidates_considered: <숫자>
candidates_selected: <숫자>
---

# products.md 업데이트 초안 (YYYY-MM-DD)

> 이 파일은 초안. content/products.md 원본은 수정되지 않음.

## A. 신규 H2 풀 제품 블록 (있는 경우)
> products.md 상단(`## **VibeMap**` 다음, `---` 구분선 뒤)에 추가하는 안.

## **{제품명}**
> *카피.*

{본문 2~4문장}

### 이런 분에게 유용합니다
- ...

### 링크
- 사이트: [...](...)
- GitHub: [roboco-io/{name}](https://github.com/roboco-io/{name})

---

## B. 신규 H3 오픈소스 도구 블록
> `## **오픈소스 도구와 리소스**` 섹션 안에 추가하는 안.

### **{name}**

{본문 2~3문장}

- GitHub: [roboco-io/{name}](https://github.com/roboco-io/{name})

---

## C. 본문 보강 패치 제안 (선택)
> "오픈소스 도구와 리소스" 섹션의 도입 문단 등에서 톤을 보강할 수 있는 작은 변경. about/solutions와 동일한 변경 전/후 형식.

---

## D. 부록 — 스캔 메타데이터
- 스캔 윈도우 / 정렬 기준
- 검토한 후보 (활동 시간순)
- 자동 제외 + 사유 (archived, fork, products.md 중복, 윈도우 밖, 인프라 리포지토리)
- 사용자가 선택에서 제외한 항목
```

---

## 9) 마무리 보고

작성 완료 후 한 줄로 보고:

```
초안 작성 완료
- docs/drafts/about-update-YYYY-MM-DD.md (신규 N건 + 보강 M건)
- docs/drafts/solutions-update-YYYY-MM-DD.md (신규 N건 + 보강 M건)
- docs/drafts/products-update-YYYY-MM-DD.md (H2 N건 + H3 M건)
검토 후 원본에 직접 반영해주세요.
```

진행하지 않은 흐름이 있으면 그 줄은 생략.

---

## 안전장치 (절대 위반 금지)

1. `content/about.md`, `content/solutions.md`, `content/products.md` 는 **읽기만** 한다. 절대 Edit/Write 대상이 아니다.
2. `consulting/` 의 클라이언트 프로젝트는 **익명화 표현**이 사용자에 의해 확정되기 전까지 초안에 실명으로 등장시키지 않는다.
3. AskUserQuestion 없이 임의로 프로젝트/리포지토리 선택·문구 확정 금지. 인터랙션 단계는 건너뛸 수 없다.
4. 흐름 B에서 **private 리포지토리는 절대 products.md 초안에 포함하지 않는다.** products.md 는 공개 페이지다.
5. 스킬 실행 중 원본을 수정해야 한다는 결론이 나오더라도 — **초안만 만들고** 원본 수정은 사용자가 직접 한다.

## 인자 처리

자연어 트리거에 포함될 수 있는 옵션:
- "지난 N개월", "최근 N주" → 스캔 윈도우 변경 (두 흐름 공통)
- "consulting 빼고", "demos만" → 흐름 A 카테고리 필터
- "fork 포함" → 흐름 B에서 fork 리포지토리도 후보에 포함
- "stars 기준" → 흐름 B 정렬 기준을 stargazerCount 로 변경
- "about만", "solutions만", "products만", "세 페이지 모두" → 0단계 분기 직접 지정
- 특정 프로젝트/리포지토리명을 직접 지정 → 5단계 자동 선택값으로 사용 (그래도 소개 문구 확인은 진행)

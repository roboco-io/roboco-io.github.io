---
title: "Karpathy LLM Wiki, 진짜 효과가 있을까 - 72-run 벤치마크와 셋팅 가이드"
date: 2026-05-07T11:00:00+09:00
draft: false
toc: true
images:
tags:
  - llm-wiki
  - karpathy
  - claude-code
  - context-engineering
  - agentic-dev
  - benchmark
  - graphrag
---

> "에이전트가 매번 모든 걸 다시 유도하지 않게 하려면, 컴파일된 지식 아티팩트가 필요하다." — Andrej Karpathy, *LLM Wiki* (GitHub Gist, 2026-04)[^karpathy]

{{< figure src="/posts/images/Dohyun.png" title="정도현 - 로보코 수석 컨설턴트" style=".author-image">}}

---

최근 한 엔터프라이즈 메일 인프라의 클라우드 네이티브 마이그레이션 프로젝트를 진행 중이다. 30개 GitHub 저장소를 git submodule로 단일 워크스페이스에 묶고, In-Scope 10개 저장소에서 약 82개 capability + 5건의 cross-repo 의존을 추적한다. Phase별 작업량은 약 88.7 person-weeks로 추정되며, Claude Code 에이전트가 매일 횡단 분석·계획·결정을 보조한다. 2026-05-05, 이 워크스페이스에서 **8 task × 3 변종 × 3 trial = 72 run** 의 벤치마크를 돌려 컨텍스트 관리 기법 세 가지(**Vanilla** / **LLM Wiki** / **Graphify**)를 정량 비교했다. 결과는 한 방향으로 수렴했고, 그날 저녁 프로젝트의 표준 컨텍스트 검색 도구가 바뀌었다.

이 글은 두 가지 일을 동시에 한다.

1. Andrej Karpathy의 **LLM Wiki 패턴**이 무엇이고, **어떻게 직접 셋팅·운영**하는지를 정리한다.
2. **워크스페이스 내부 72-run 벤치마크** 결과로 패턴의 실제 효과를 검증하고, 어디서 이기고 어디서 지는지를 보여준다.

이론과 실측을 한 글에서 묶는 이유는 단순하다. Karpathy의 제안은 "AI 에이전트가 같은 문서를 반복해서 다시 읽지 말고, **한 번 컴파일된 지식**을 재사용하게 하라"는 것이다. 이게 정말 토큰·시간·품질 모두에서 이익인지는 자기 도메인에서 한 번 측정해 봐야 안다. 우리는 측정했고, 결과를 공개한다.

---

## TL;DR

- **LLM Wiki는 실측에서 우월했다.** 8 task × 3 trial = 24 run 평균에서 **토큰 350K(vanilla 755K, graphify 617K), 시간 101s(vanilla 167s, graphify 180s), 품질 16.00/25(vanilla 15.10, graphify 13.56)**. wiki vs vanilla 토큰 d=+0.842(p_corr=0.0105), wiki vs graphify 품질 d=+0.666(p_corr=0.00678).
- **Karpathy LLM Wiki 패턴**은 raw 소스를 LLM이 능동적으로 읽어 cross-reference된 마크다운 위키로 컴파일하고, 모든 질의를 그 컴파일된 위키에 대해 수행한다. RAG처럼 매 질의마다 청크를 재검색하는 stateless 방식이 아니라, **stateful·compounding** 아티팩트다.
- **3-Layer 구조**: ① raw/ (불변 원본) ② wiki/ (LLM이 생성·갱신하는 마크다운 노트, `[[wikilink]]`) ③ schema (CLAUDE.md/AGENTS.md, 행동 규칙). 일일 작업은 **ingest / query / lint** 세 가지로 정리된다.
- **셋팅은 5분이면 가능**하다. Obsidian + Claude Code 조합이 표준이고, `nashsu/llm_wiki`·`junbjnnn/llm-wiki`·`kepano/obsidian-skills` 같은 오픈소스 구현체가 이미 존재한다.
- **단, vanilla(직접 read)가 이기는 task도 있다**. 답이 단일 source에 명확히 있을 때(우리 T4·T8) 큐레이션 비용이 손해다. Wiki-first가 default이되, 단일 source 회수가 명확한 질문은 그대로 read/grep으로 가는 정책이 합리적이다.

---

## 1. 왜 또 컨텍스트 관리인가

Claude Code, Codex, Cursor 같은 에이전트형 코딩 도구를 본격적으로 쓰기 시작하면 곧 한 가지 사실에 부딪힌다. **에이전트는 매번 같은 일을 다시 유도한다.** 어제 cyrus-imapd의 9folders 패치 규모를 알아내기 위해 4개 파일을 읽었다면, 오늘 비슷한 질문이 들어올 때 또 그 4개 파일을 읽는다. RAG 인덱스를 붙여 놓으면 청크 단위로 재검색은 빨라지지만, **종합·교차참조·모순 처리는 매 질의마다 처음부터 다시 한다**. 토큰은 같은 문장에 반복해서 흘러가고, 답변은 매번 미세하게 다르며, 어제 발견한 contradiction은 오늘 또 발견되거나 잊힌다.

Karpathy는 이 문제를 정조준한다. 2026-04 공개된 GitHub Gist *LLM Wiki*[^karpathy]는 한 문장으로 요약된다.

> "당신의 AI는 매번 모든 걸 다시 유도한다(Your AI re-derives everything it knows every single time)."[^nate]

그리고 해법:

> "지식을 한 번 **컴파일** 하라. 그리고 모든 질의를 그 컴파일된 아티팩트에 대해 수행하라."[^karpathy]

Karpathy는 이 아이디어가 **Vannevar Bush의 1945년 Memex 비전**과 동일 계보임을 명시한다. 차이는 단 하나, **누가 유지보수를 하는가**다.

> "Bush가 풀지 못한 부분은 누가 유지보수를 하는가였다. LLM이 그것을 해결한다."[^karpathy]

지난 80년 동안 개인 지식 큐레이션 도구(zettelkasten, Obsidian, Notion 등)가 진화했지만 모두 **사람의 손**을 요구했다. LLM Wiki는 그 손을 LLM에 위임한다. 사람은 소스를 던지고 질문을 하고 방향을 잡는다. LLM은 종합·연결·인덱싱·정합성 점검의 지루한 작업을 도맡는다.

이 패턴은 출시 몇 주 만에 GitHub Gist 북마크 10만 개를 넘겼고[^nate], 다수의 오픈소스 구현체가 등장했다. 우리도 이 프로젝트에 채택해서 5월 초 8개 위키 노트를 운영하고 있었다. 다만 운영하면서 한 가지 의심이 남았다. **이게 정말 vanilla(직접 read)나 GraphRAG보다 좋은가?** 그 의심이 72-run 벤치마크로 이어졌다.

---

## 2. LLM Wiki 패턴: 구조와 원리

### 2.1 RAG와 무엇이 다른가

RAG는 매 질의마다 동일한 사이클을 돈다.

```
[질의] → 임베딩 → 벡터 DB 검색 → top-k 청크 → LLM 컨텍스트 주입 → 답변
```

이 사이클은 **상태가 없다**. 어제 어떤 청크가 어떤 청크와 충돌한다는 사실을 LLM이 발견했어도, 그 발견은 인덱스에 저장되지 않는다. 오늘 같은 충돌이 다시 표면화되거나, 더 자주, 잊힌다. 또 한 가지 결정적 약점은 **chunking brittleness**다. 청크 경계가 의미 단위와 어긋나면 답변 품질이 흔들리고, 청크 크기 튜닝은 끝없는 작업이 된다.[^particula]

LLM Wiki는 사이클을 뒤집는다.

```
[새 소스] → LLM ingest → wiki 페이지 생성·갱신 + 교차참조 + 충돌 표기
[질의]    → index 읽기 → 관련 wiki 페이지 read → 답변
```

질의 시점에 LLM은 **이미 종합된** 마크다운 페이지를 읽는다. 청크가 아니라 사람이 읽도록 설계된 노트다. 인덱스는 임베딩 검색이 아니라 단순 **마크다운 카탈로그**(`index.md`)이고, LLM이 키워드와 의미로 관련 페이지를 좁힌다. 컴파일은 한 번, 질의는 여러 번. 비대칭 비용 분담이 핵심이다.[^particula]

### 2.2 3-Layer 구조

Karpathy의 spec[^karpathy]은 디렉토리를 세 층으로 나눈다.

| Layer | 디렉토리 | 소유자 | 변경 가능 |
|-------|---------|-------|----------|
| **Layer 1: Raw Sources** | `raw/` | 사람 | LLM은 read-only |
| **Layer 2: Wiki** | `wiki/` | LLM | LLM이 컴파일·갱신 |
| **Layer 3: Schema** | `CLAUDE.md` 또는 `AGENTS.md` | 사람 | 패턴·규칙 정의 |

**Layer 1 — Raw Sources** 는 불변 입력층이다. 논문 PDF, 회의록, 웹 클리핑, 사양서 등을 그대로 보관한다. LLM이 잘못 해석한 게 의심되면 항상 원본으로 돌아갈 수 있다. 출처 audit이 가능하고, 재컴파일이 안전하다.

**Layer 2 — Wiki** 는 LLM 생성층이다. 세부 구조는 도메인마다 다르지만 일반적으로:

```
wiki/
  index.md              # 모든 페이지 카탈로그 (라우팅의 입구)
  log.md                # ingest/query 이력 append-only
  sources/<source>.md   # 원본 한 건당 1 페이지 (요약 + tag)
  concepts/<topic>.md   # 토픽 페이지 (정의 + 관계 + 인용)
  entities/<name>.md    # 인물·조직·제품 페이지
  synthesis/<topic>.md  # 다중 source cross-analysis
```

모든 페이지는 마크다운이고, 페이지 간 링크는 **`[[Page Name]]`** Obsidian 위키링크 문법을 쓴다. 새 source가 들어오면 LLM은 해당 source를 요약한 페이지 1개 + 영향받는 concept/entity 페이지 N개를 한 번에 갱신한다. 기존 concept 페이지가 있으면 새 정보를 통합하고, 충돌이 있으면 **두 입장 모두를 source 인용과 함께 명시**한다.[^karpathy] [^louiswang]

**Layer 3 — Schema** 는 LLM 행동 규칙이다. Claude Code면 `CLAUDE.md`, Codex면 `AGENTS.md`, Gemini면 `GEMINI.md`. 위키 구조 설명, 페이지 명명 규칙, frontmatter 표준, ingest/query/lint 절차, 충돌 처리 규칙 같은 것을 적는다. 잘 만든 schema 없으면 LLM은 "마크다운 파일에 접근 가능한 챗봇"에 그치고, 잘 만든 schema가 있으면 **규율 있는 위키 관리자**가 된다.[^karpathy] [^forrest]

### 2.3 일일 작업 — ingest / query / lint

세 가지 작업으로 모든 운영이 정리된다.[^karpathy] [^louiswang]

**Ingest** — 새 source를 위키에 통합한다. 사용자가 `raw/`에 파일을 떨어뜨리고 `/ingest` 슬래시 명령을 호출한다. LLM은:
1. source를 읽고 high-level 요약을 사용자에게 보고 (검증 체크포인트)
2. 사용자 승인 시 `wiki/sources/<source>.md` 작성
3. 영향받는 concept/entity 페이지 read → 새 정보 통합 → 충돌 시 양쪽 입장 명시
4. `index.md`와 `log.md` 갱신

이 단계에서 LLM이 잘못 해석한 게 있으면 사용자가 즉시 잡는다. 한 번 위키에 commit되면 그 해석은 미래 모든 질의에 영향을 주기 때문에, ingest 단계의 human-in-the-loop는 필수다.

**Query** — 위키에 대해 질문한다. LLM은:
1. `index.md` read → 관련 페이지 식별 (벡터 검색 없이 키워드·의미 매칭)
2. 후보 페이지 read → 위키링크 따라 2-hop까지 확장
3. 답변 작성 (모든 사실에 wiki 페이지 인용)

답변 자체를 다시 `wiki/synthesis/<query>.md`로 적재할 수도 있다. 그러면 다음 비슷한 질의는 그 합성 페이지를 재사용한다. **탐색이 위키에 누적된다.**

**Lint** — 위키 건강도 점검. 정기적으로 LLM이 위키 전체를 훑어서:
- 충돌 조항이 발견됐는데 표기 없는 페이지
- 인바운드 링크 0의 orphan 페이지
- 자주 언급되는데 자체 페이지가 없는 concept (gap)
- 최근 source가 갱신했어야 하는데 stale한 페이지

이 결과를 사용자에게 리포트하고, 사용자 승인 시 정리 commit. 위키가 100 페이지를 넘기 시작하면 lint 없이는 곧 어수선해진다.[^opengitagent]

### 2.4 GraphRAG·MCP·Memory와의 관계

LLM Wiki는 다른 에이전트 인프라를 대체하지 않는다. 보완한다.

- **GraphRAG**: 엔티티-관계 그래프 구조에 강점. cross-component path 쿼리, multi-hop 추론에 유리. LLM Wiki는 토픽 종합과 source 인용에 유리. **둘은 다른 use case다**. 우리 벤치마크에서도 graphify는 T1 같은 path 쿼리에서 wiki를 따라잡았지만, 다른 task에서는 토큰·시간 모두 부담이 됐다.[^singlestore]
- **MCP (Model Context Protocol)**: 위키를 직접 파일 read로 노출하는 대신 MCP 서버로 mediated access를 줄 수 있다. 권한 제어·감사 로그·rate limit이 가능해진다. 기업 환경에서는 MCP 경유가 표준이 될 가능성이 높다.[^homeassistant]
- **Claude Memory / Agent Memory**: 사용자별 선호·과거 대화를 기억한다. LLM Wiki는 도메인 지식, Memory는 개인화. 보통 둘을 함께 쓴다.[^vishal]
- **Agent Skills (kepano/obsidian-skills 등)**: Obsidian의 wikilink·callout·Dataview·canvas 같은 native 기능을 LLM이 능숙하게 쓰도록 가르치는 progressive disclosure형 명령 모음. LLM Wiki schema가 "무엇을 할지" 정의한다면 Skills는 "어떻게 할지" 가르친다.[^kepano] [^agentskills]

---

## 3. 실제 셋팅 — 5분 vs 1시간 vs 1일

### 3.1 최소 셋팅 (5분, 도구 0개)

가장 가벼운 시작은 **터미널과 Claude Code만** 있으면 된다.

```bash
mkdir my-wiki && cd my-wiki
mkdir raw wiki
cat > CLAUDE.md <<'EOF'
# My LLM Wiki

## 디렉토리
- raw/: 원본 소스 (read-only for LLM)
- wiki/index.md: 페이지 카탈로그
- wiki/sources/, wiki/concepts/, wiki/entities/: 노트 폴더

## 작업
- /ingest <file>: raw/<file>을 읽고 wiki에 통합
- /query <question>: wiki를 검색하고 답변 + 출처 인용
- /lint: 위키 건강도 점검

## 규칙
- 모든 페이지 frontmatter에 tags, sources 명시
- 페이지 간 링크는 [[Page Name]] 위키링크
- 충돌 시 양쪽 입장 인용과 함께 명시
EOF
```

이후 Claude Code 세션에서 Karpathy의 [원본 spec](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)[^karpathy]을 통째로 붙여넣고 `/ingest raw/my-paper.pdf` 같은 명령을 시작하면 된다. 5분이면 첫 페이지가 생성된다.[^kunal]

### 3.2 표준 셋팅 — Obsidian + Claude Code (1시간)

더 본격적으로 운영할 거면 **Obsidian** 을 위키 뷰어로 얹는다. Obsidian은 무료이고, wikilink 자동 backlink, 그래프 시각화, 로컬 검색이 강력하다.[^obsidian]

설치 단계:

1. Obsidian을 받고 새 vault를 위 디렉토리에 연다.
2. Obsidian의 **Terminal** 커뮤니티 플러그인을 설치 (vault 안에서 셸 실행 가능).
3. Claude Code를 vault 디렉토리에서 시작한다.
4. `CLAUDE.md`에 Obsidian 관례 섹션을 추가:

```markdown
## Obsidian 관례
- frontmatter는 YAML, 첫 줄 `---` 시작
- 인라인 태그는 #tag 형식
- 위키링크 별칭: [[Page Name|표시 이름]]
- 콜아웃: > [!note] 같은 admonition
```

이 시점부터 **그래프 뷰**에서 위키가 어떻게 연결돼 있는지 한눈에 보인다. orphan 페이지나 isolated cluster가 시각적으로 잡힌다. backlink panel은 "이 페이지를 참조하는 모든 페이지"를 즉시 보여준다.

### 3.3 향상된 셋팅 — Obsidian Skills (1일)

위키가 50 페이지를 넘기 시작하면 **Obsidian-native 기능**을 LLM에 가르치는 게 큰 차이를 만든다. Obsidian CEO Steph Ango가 만든 [`kepano/obsidian-skills`](https://github.com/kepano/obsidian-skills)[^kepano]가 표준이다.

설치하면 Claude는 다음을 능숙하게 쓸 수 있게 된다.

- **Dataview 쿼리**: frontmatter 태그 기반으로 동적 표를 자동 생성. 예: 모든 `cyrus-imapd` 관련 페이지를 표로 모은 인덱스가 매번 자동 갱신.
- **Canvas**: 마인드맵·아키텍처 다이어그램 형태로 페이지를 묶어 시각화.
- **Marp**: 위키 페이지 몇 개를 묶어 슬라이드 덱으로 자동 생성.

이 단계가 되면 위키는 "노트의 폴더"가 아니라 **knowledge platform**이 된다.[^aimaker]

### 3.4 오픈소스 구현체

스크래치 셋팅이 부담스러우면 다음 중 하나를 클론해서 시작할 수 있다. 모두 Karpathy spec을 충실히 구현한다.

| 구현체 | 특징 |
|--------|-----|
| [`nashsu/llm_wiki`](https://github.com/nashsu/llm_wiki) | Cross-platform desktop app. **2-step chain-of-thought ingest** (LLM이 분석 후 페이지 생성), 멀티모달 이미지 ingest, 인크리멘털 캐싱.[^nashsu] |
| [`godstale/llm-wiki`](https://github.com/godstale/llm-wiki) | Claude Code 전용 템플릿. 폴더 구조·템플릿·예시 명령이 즉시 사용 가능.[^godstale] |
| [`junbjnnn/llm-wiki`](https://github.com/junbjnnn/llm-wiki) | Git 기반. 서버·DB 없이 순수 Git + Markdown + Python 스크립트. 팀 협업·코드 리뷰 워크플로 친화.[^junb] |
| [`lucasastorian/llmwiki`](https://github.com/lucasastorian/llmwiki) | MCP 통합. document upload + Claude Code via MCP + 자동 위키 작성.[^lucas] |
| [`forrestchang/andrej-karpathy-skills`](https://github.com/forrestchang/andrej-karpathy-skills) | Karpathy의 코딩 가이드라인을 CLAUDE.md로 전환. 위키 전용은 아니지만 schema 설계 참고.[^forrest] |

우리 위키는 별도 도구 없이 Claude Code + 직접 작성한 `CLAUDE.md` 조합으로 운영 중이다. 8개 노트로 시작했고, 벤치마크 시점에 4개 디렉토리(`components/`, `migration/`, `external/`, `decisions/`) + `index.md`로 구성돼 있다.

---

## 4. 우리가 측정한 것 — 72-run 벤치마크

### 4.1 왜 측정했나

LLM Wiki는 직관적으로 좋아 보이지만, 우리 도메인은 일반 RAG 벤치마크와 다르다.

- 30 저장소 워크스페이스, 단일 코드베이스 아님
- `cyrus-imapd` 한 저장소만 9folders 브랜치에 자체 패치 **4,362 files / +217K lines**
- "거시 결정 + 9folders 패치 분석 + cross-domain 의존성 추적"이 한 task에 섞임

이 워크로드에서 wiki의 컴파일 비용이 회수되는가? graphify 같은 GraphRAG 보조가 더 낫지 않은가? vanilla(직접 read)가 의외로 충분하지 않은가? 답을 추측 말고 측정하기로 했다. 설계 spec은 [`token-experiments-claude/01-design-spec.md`](https://github.com/) 에 정리돼 있다.

### 4.2 실험 설계

**1차 의사결정 질문**: "이 마이그레이션 워크로드에서 Vanilla / Wiki / Graphify 중 토큰 효율과 답변 품질을 동시에 충족하는 기법은 무엇인가?"

**종속변수 우선순위**:

1. 토큰 비용 (input + cache_read + cache_creation + output 합산)
2. 답변 품질 (4 차원 0-25 rubric)
3. 작업 시간 (wall-clock)

**워크로드 — 8 task (T1-T8)**:

| ID | 질문 요지 | 작업 유형 |
|----|---------|----------|
| T1 | cyrup의 9folders 자체 패치 수와 영역 | 패치 분석 |
| T2 | notifier_go ↔ rework-notify 사이 SNS 흐름 | cross-language 의존 |
| T3 | cyrus-imapd 9folders가 master 대비 패치한 파일·라인 규모 | 대규모 패치 분석 |
| T4 | pam-jwt가 production에서 호출되는가 | 전수 grep |
| T5 | cyrus-imapd 4개 브랜치의 활성도 비교 | git history |
| T6 | Stalwart의 JMAP 한국 비즈니스 로직 적합도 | 외부 자료 통합 |
| T7 | R12 PoC 시나리오 6개의 의존 commit SHA | 코드 분석 |
| T8 | X-AUTH-01에 영향 주는 R-항목과 capability ID | cross-domain |

각 task는 ground truth 핵심 사실 N개와 필수 인용 M개를 갖는다. **task prompt에는 ground truth가 노출되지 않는다.** judge만 보유.

**3 변종**:

| 변종 | 추가 노출 자료 | CLAUDE.md 규칙 |
|-----|--------------|--------------|
| **Vanilla** | (없음) | workspace 개요 + R-BR-01만 |
| **Wiki** | `wiki/` 전체 | + wiki 인용 디시플린 |
| **Graphify** | `graphify-out/` + graphify CLI | + graphify-first 규칙 |

세 변종 모두 PRD + 코드 submodule + git은 공통. 차이는 **보조 도구만**.

**격리 — git worktree 3개**:

```
token-experiments-claude/worktrees/
  vanilla/    # main worktree, wiki/와 graphify-out/ 제거
  wiki/       # main worktree, graphify-out/ 제거
  graphify/   # main worktree, wiki/ 제거
```

각 worktree에 변종 전용 CLAUDE.md를 덮어쓴다. submodule은 worktree 간 공유. 이 격리 덕에 prompt cache가 worktree 경로에 자연스럽게 분리되고, trial 간 cache 오염이 없다.

**Judge — codex(GPT-5)**: actor가 Claude(`claude-opus-4-7`)이므로 self-evaluation 편향을 피하려고 외부 모델로 채점. 4 차원 rubric:

| 차원 | 가중치 | 정의 |
|-----|-------|-----|
| 정확성 | 0.4 | ground truth 핵심 사실 일치율 |
| 완결성 | 0.3 | 핵심 사실 누락 없는가 |
| 인용 | 0.2 | `[[wiki/..]]`, `PRD §X`, `9folders <SHA>` 명시 |
| 과잉 (역지표) | 0.1 | 불필요 사변·환각·반복 비율 |

총점 0-25 scale. **자동 cap**: R-BR-01 위반(cyrup/cyrus-imapd/cyruslibs를 master 기준 분석)이면 max 10점, 핵심 결론 반대면 fail(0점).

**Inter-rater agreement**: pilot 단계에서 사용자가 일부 무작위 채점. Cohen's κ는 accuracy `0.750`, completeness `0.897`, citation `1.000`, excess `0.250`. 가중 평균 `0.86` 으로 rubric 통과. excess 차원의 κ만 약하지만 가중치 0.1이라 전체 영향은 작다.

### 4.3 결과 — 변종별 marginal mean

72 run 전체:

| 변종 | tokens_total mean ± SD | time_sec mean | total_25 mean |
|------|----------------------|---------------|---------------|
| **vanilla** | 755,606 ± 635,286 | 166.5 | 15.10 |
| **wiki** | **350,769** ± 241,656 | **101.1** | **16.00** |
| **graphify** | 617,477 ± 604,668 | 179.8 | 13.56 |

Wiki가 **3개 차원 모두에서 1위**다. 토큰은 vanilla 대비 53.6% 절감, 시간은 39.3% 단축, 품질은 graphify 대비 17.9% 우위.

### 4.4 통계적 유의성

Friedman test 주효과:

- tokens_total: p = 0.0930 (한계적)
- time_sec: p = 4.451e-07 (강력)
- total_25: p = 0.001612 (강력)

Wilcoxon pairwise (Bonferroni 보정):

| 비교 | 차원 | p_corr | Cohen's d | 판정 |
|-----|-----|--------|-----------|------|
| vanilla > wiki | 토큰 | 0.0105 | +0.842 | **유의 (large)** |
| vanilla > wiki | 시간 | 3.93e-05 | +0.975 | **유의 (large)** |
| graphify > wiki | 시간 | 3.58e-07 | -1.150 | **유의 (large)** |
| wiki > graphify | 품질 | 0.00678 | +0.666 | **유의 (medium-large)** |
| vanilla vs wiki | 품질 | 0.7312 | -0.216 | 차이 없음 |
| vanilla vs graphify | 품질 | 0.2459 | +0.420 | 차이 없음 |

핵심 시사점:

- **Wiki는 vanilla 대비 토큰·시간을 큰 효과 크기로 절감**한다 (품질은 동등).
- **Wiki는 graphify 대비 품질·시간 모두 우월**하다.
- **graphify-first는 우리 워크로드에서 default로 부적합**하다. 토큰 절감은 vanilla 대비 미미했고, 시간은 오히려 가장 길었으며, 품질은 가장 낮았다.

### 4.5 Task별 winner — 패턴은 단순하지 않다

전체 평균이 Wiki의 손을 들어주지만, task 차원에서 보면 그림이 더 흥미롭다. 평균 점수 기준 task별 1위:

| Task | 1위 | 2위 | 3위 | 비고 |
|------|----|----|----|-----|
| T1 (cyrup 패치) | wiki 17.67 | graphify 17.50 | vanilla 16.33 | 박빙 |
| T2 (cross-language SNS) | **wiki 18.00** | vanilla 14.50 | graphify 13.17 | wiki 압승 |
| T3 (cyrus-imapd 패치 규모) | graphify 9.50 | vanilla 8.33 | wiki 7.83 | **모두 저조** |
| T4 (pam-jwt 사용 여부) | **vanilla 18.17** | wiki 17.50 | graphify 14.83 | vanilla 우세 |
| T5 (cyrus 브랜치 활성도) | wiki 15.83 | vanilla/graphify 14.17 | — | wiki 우세 |
| T6 (Stalwart JMAP 적합도) | **wiki 16.83** | graphify 11.50 | vanilla 11.33 | wiki 압승 |
| T7 (R12 PoC SHA) | wiki 18.00 | vanilla 17.67 | graphify 16.33 | 박빙 |
| T8 (X-AUTH-01 cross-domain) | **vanilla 20.33** | wiki 16.33 | graphify 11.50 | vanilla 압승 |

해석:

- **Wiki는 mixed task에서 robust**하다. T1·T2·T5·T6·T7 — 5개 task에서 1위. 특히 T6(외부 자료 통합)과 T2(cross-language)처럼 "여러 source를 종합해야 하는 task"에서 강하다. 큐레이션이 효과를 본다.
- **Graphify는 T3 1개만 1위, 그것도 9.50/25로 절대 점수가 낮다.** GraphRAG가 강점을 보일 거라 기대했던 영역(cross-language 의존 T2)에서 wiki에게 큰 차이로 졌다. graphify의 INFERRED edge가 noise를 추가했고, 추가 query overhead가 시간 비용을 키웠다.
- **Vanilla가 이기는 task가 두 개 있다.** T4(전수 grep)와 T8(cross-domain 분석). 둘 다 **답이 단일 source에 명확히 있고 큐레이션이 오히려 손실인 경우**다. T4는 pam-jwt 호출 흔적을 코드 전체에서 grep하면 끝나고, T8은 PRD §14.2 표를 직접 읽는 게 가장 정확하다. wiki는 같은 정보를 거쳐서 가는 비용을 지불한다.

### 4.6 캐비엇

- **excess 차원의 IRR이 약하다** (κ=0.250). 모든 변종의 transcript+answer를 함께 본 채점 방식이라 excess 점수가 모든 변종에서 가혹하게 나왔다. 가중치가 0.1이라 전체 결론에는 영향이 작지만, 절대값은 보수적으로 봐야 한다.
- **Graphify가 살아남는 영역**: T1형 cross-component path 쿼리. wiki에 cross-link이 모자랄 때 `graphify path A B`가 INFERRED edge로 새 연결을 발견하기도 한다. **default가 아닌 보조**로 두면 가치가 살아난다.
- **Wiki bias 우려**: 8 task 모두 wiki에 ground truth가 있어서 wiki에 유리할 수 있다. 다만 T2·T8은 wiki에도 partial 정보만 있고, judge는 ground truth 사실 자체를 평가하지 source를 평가하지 않는다.
- **벤치마크는 Claude Code 기반**. 다른 모델·다른 도구 환경에서는 결과가 다를 수 있다. 수치는 우리 환경의 default 정책 근거이지 universal claim이 아니다.

---

## 5. 그래서 어떻게 운영하는가

72-run 결과를 받아 그날 저녁 프로젝트의 컨텍스트 검색 정책이 다음과 같이 정리됐다.

### 5.1 Wiki-first + source verification (default)

| 단계 | 도구 | 사용 시점 |
|------|-----|---------|
| 1 | `wiki/index.md` Read → 관련 노트 Read | **첫 번째 시도**. day-to-day 운영 사실 |
| 2 | PRD 해당 §X.Y Read | 거시 결정·SLA·R-BR·Phase 일정 |
| 3 | submodule 코드 Read/Grep | 구현 상세 검증 |
| 4 | `graphify path A B` | **보조** — cross-component 의존성 |
| 5 | `graphify explain "노드"` | **보조** — 단일 개념 인접 관계 |
| 6 | `graphify query "..." --budget 2000` | **보조** — wiki 진입점이 모호할 때 |

이 순서가 우리 워크로드의 토큰·시간·품질 trade-off를 가장 잘 만족시켰다.

### 5.2 wiki-first가 의미하지 않는 것

- **wiki 맹신 금지**: wiki에 없으면 즉시 PRD → 코드 read. 만들어내지 말 것.
- **graphify 무용 아님**: cross-component path는 graphify가 wiki 단독보다 우수.
- **단일 source 회수가 명확하면 wiki를 거치지 말 것**: T4·T8 형 task에서는 vanilla(직접 read)가 wiki를 이겼다. wiki/index에서 한 노트로 좁혀지지 않으면 빠르게 직접 read로 넘어가는 게 합리적이다.

### 5.3 wiki 인용 디시플린

벤치마크 전 메타 분석에서 한 가지 약점이 발견됐다. **wiki에 기록은 활발했지만(8 노트) 답변 시 `[[..]]` 명시 인용이 ~10% 미만**이었다. wiki의 가치가 staleness가 아니라 **노출 부족**으로 절반밖에 발현되지 않았다. 그래서 schema에 강제 규칙을 박았다.

```markdown
### 자기 검증 질문 (답변 작성 직전)
- [ ] 이 답변에 등장하는 모든 wiki-가능한 사실에 [[..]] 인용이 있는가?
- [ ] 같은 사실이 wiki 여러 노트에 있다면 가장 적합한(또는 모두) 인용했는가?
- [ ] wiki에 없는 새 사실이 답변에 있는데 wiki 갱신을 누락하지 않았는가?
- [ ] PRD의 거시 결정을 인용할 때 PRD §X.Y 형식을 지켰는가?
→ 4개 모두 ✅ 인 답변만 제출.
```

이 규칙 하나로 답변의 인용률이 즉시 정상화됐다. **wiki를 만드는 것보다, 매번 인용하게 만드는 게 더 어렵고 더 중요하다**는 게 우리 교훈이다.

---

## 6. 정리 — 패턴은 옳고, 디테일은 도메인이 결정한다

Karpathy의 LLM Wiki 패턴은 우리 도메인에서 **토큰 53.6% 절감, 시간 39.3% 단축, 품질 동등 이상**의 효과를 냈다. 통계적으로도 large effect size로 유의하다. **default 도구를 wiki로 바꾼 결정은 데이터가 뒷받침한다.**

다만 패턴을 직역하면 안 된다는 것도 데이터가 보여준다. T4·T8처럼 **단일 source에 답이 명확한 task**에서는 wiki 큐레이션 비용이 손해다. graphify는 default로는 부적합하지만 cross-component path 쿼리에서는 wiki 단독보다 우수하다. 패턴을 받아들이되, 자기 워크로드의 **task 분포**와 **source 구조**를 함께 봐야 한다.

이 글이 두 가지로 쓰이길 바란다.

1. **패턴을 처음 듣는 분**: 5분 셋팅에서 시작해 Obsidian + Claude Code로 확장하시라. 오픈소스 구현체가 이미 충분하다.
2. **이미 운영 중인 분**: 자기 도메인에서 한 번 측정해 보시라. 우리 결과는 universal claim이 아니다. 8 task × 3 변종 × 3 trial = 72 run이면 1-2일 안에 answer가 나온다.

LLM Wiki는 80년 전 Bush의 Memex 비전이 마침내 자동화된 결과다. 그 자동화의 가치를 측정하는 일은 이제 시작이고, 우리 결과는 한 도메인의 한 데이터 포인트일 뿐이다. 더 많은 측정이 쌓이면, 컨텍스트 관리는 직관이 아니라 **공학** 의 영역으로 넘어간다. 그게 context engineering이 의미하는 바일 것이다.

---

## 참고 자료

- 실험 raw data, 분석 스크립트, decision.md: 본 프로젝트 `token-experiments-claude/` 디렉토리에 commit돼 있다 (raw run JSON과 transcript는 의도적으로 local-only).

[^karpathy]: Andrej Karpathy, *LLM Wiki* (GitHub Gist, 2026-04). https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
[^nate]: Nate's Newsletter, "Your AI Re-Derives Everything It Knows Every Single Time" (2026-04). https://natesnewsletter.substack.com/p/your-ai-re-derives-everything-it
[^particula]: Particula, "Karpathy LLM Wiki: Compiled Knowledge vs RAG" (2026). https://particula.tech/blog/karpathy-llm-wiki-compiled-knowledge-vs-rag
[^louiswang]: Louis Wang, "Building an LLM Knowledge Base with Claude Code" (2026). https://louiswang524.github.io/blog/llm-knowledge-base/
[^forrest]: Forrest Chang, *andrej-karpathy-skills/CLAUDE.md*. https://github.com/forrestchang/andrej-karpathy-skills/blob/main/CLAUDE.md
[^opengitagent]: Open Git Agent, *examples/llm-wiki/skills/wiki-lint/SKILL.md*. https://github.com/open-gitagent/gitagent
[^singlestore]: SingleStore, "Rethinking RAG: How GraphRAG Improves Multi-Hop Reasoning" (2025). https://www.singlestore.com/blog/rethinking-rag-how-graphrag-improves-multi-hop-reasoning-/
[^homeassistant]: Home Assistant Community, "Filesystem MCP Server: Expose Local Directory to Claude (Karpathy LLM Wiki for Home Assistant)" (2026). https://community.home-assistant.io/t/filesystem-mcp-server-expose-your-local-directory-to-claude-karpathy-llm-wiki-for-home-assistant/1005762
[^vishal]: Vishal Mysore, "RAG vs Agent Memory vs LLM Wiki: A Practical Comparison" (dev.to, 2026). https://dev.to/vishalmysore/rag-vs-agent-memory-vs-llm-wiki-a-practical-comparison-1oo6
[^kepano]: Steph Ango, *kepano/obsidian-skills*. https://github.com/kepano/obsidian-skills
[^agentskills]: Agent Skills Specification. https://agentskills.io/home
[^obsidian]: Obsidian Help, "Internal links". https://obsidian.md/help/links
[^kunal]: Kunal Ganglani, "LLM Wiki: Karpathy's Local Knowledge Base" (2026). https://www.kunalganglani.com/blog/llm-wiki-karpathy-local-knowledge-base
[^aimaker]: AI Maker Substack, "LLM Wiki + Obsidian Knowledge Base by Andrej Karpathy" (2026). https://aimaker.substack.com/p/llm-wiki-obsidian-knowledge-base-andrej-karphaty
[^nashsu]: nashsu, *llm_wiki*. https://github.com/nashsu/llm_wiki
[^godstale]: godstale, *llm-wiki*. https://github.com/godstale/llm-wiki
[^junb]: junbjnnn, *llm-wiki*. https://github.com/junbjnnn/llm-wiki
[^lucas]: lucasastorian, *llmwiki*. https://github.com/lucasastorian/llmwiki

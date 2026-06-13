---
title: "Karpathy LLM Wiki, 진짜 효과가 있을까 - 72-run 벤치마크"
date: 2026-05-07T11:00:00+09:00
draft: false
toc: false
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

## TL;DR

- Andrej Karpathy의 **LLM Wiki 패턴**("매번 다시 읽지 말고 한 번 컴파일된 지식을 재사용하라"[^karpathy])이 실제로 이득인지, 30개 저장소 마이그레이션 워크스페이스에서 **8 작업 × 3 기법 × 3 반복 = 72 run** 벤치마크로 측정했다.
- **LLM Wiki가 토큰·시간·품질 3개 차원 모두 1위.** Vanilla 대비 **토큰 54% 절감, 시간 39% 단축**(통계적으로 large effect, §4), 품질은 Vanilla와 동등·Graphify보다 우위.
- **Graphify(GraphRAG)는 기본 도구로 부적합.** 토큰 절감 미미, 시간 최장, 품질 최저.
- **단, 만능은 아니다.** 여러 소스를 종합하는 작업은 Wiki 압승, 답이 단일 소스에 명확한 작업(전수 grep·특정 표 조회)은 직접 read가 더 빠르고 정확(§3).
- 결과를 받아 그날 저녁 프로젝트의 기본 컨텍스트 검색 도구가 LLM Wiki로 바뀌었다.

| 기법 | 토큰 (평균) | 시간 (평균) | 품질 (25점) |
|------|-----------:|-----------:|-----------:|
| Vanilla (직접 read/grep) | 755K | 167s | 15.1 |
| **LLM Wiki** | **350K** | **101s** | **16.0** |
| Graphify (GraphRAG) | 617K | 180s | 13.6 |

아래는 이 결론을 뒷받침하는 실험 설계와 상세 수치다.

---

## 1. 비교한 세 가지 기법

| 기법 | 작동 방식 | 추가 노출 자료 |
|-----|----------|--------------|
| **Vanilla** | 보조 도구 없이 파일을 직접 read/grep | (없음) |
| **LLM Wiki** | LLM이 미리 컴파일해 둔 마크다운 위키를 먼저 읽음 | `wiki/` 전체 + 인용 규칙 |
| **Graphify** | 엔티티-관계 그래프(GraphRAG)를 먼저 질의 | `graphify-out/` + CLI |

LLM Wiki 패턴의 핵심은 RAG와의 차이다. RAG는 매 질의마다 임베딩·벡터검색·청크 주입을 반복하는 **stateless** 사이클이라, 종합·교차참조·모순 처리를 매번 처음부터 다시 한다. LLM Wiki는 이걸 뒤집어 **새 소스가 들어올 때 한 번 컴파일**(요약·교차참조·충돌 표기)해 두고, 질의 시점에는 이미 종합된 마크다운 페이지를 읽는다. **컴파일은 한 번, 질의는 여러 번** — 이 비대칭 비용 분담이 토큰 절감의 원천이다.

---

## 2. 실험 설계

**의사결정 질문**: "이 마이그레이션 워크로드에서 토큰 효율과 답변 품질을 동시에 충족하는 기법은 무엇인가?" 종속변수 우선순위는 ① 토큰 비용 ② 답변 품질 ③ 작업 시간.

**워크로드 — 8개 작업(T1–T8)**:

| ID | 질문 요지 | 작업 유형 |
|----|---------|----------|
| T1 | cyrup의 9folders 자체 패치 수와 영역 | 패치 분석 |
| T2 | notifier_go ↔ rework-notify 사이 SNS 흐름 | cross-language 의존 |
| T3 | cyrus-imapd 9folders가 master 대비 패치한 규모 | 대규모 패치 분석 |
| T4 | pam-jwt가 production에서 호출되는가 | 전수 grep |
| T5 | cyrus-imapd 4개 브랜치의 활성도 비교 | git history |
| T6 | Stalwart JMAP의 한국 비즈니스 로직 적합도 | 외부 자료 통합 |
| T7 | R12 PoC 시나리오 6개의 의존 commit SHA | 코드 분석 |
| T8 | X-AUTH-01에 영향 주는 R-항목과 capability ID | cross-domain |

**격리**: 세 기법을 git worktree 3개로 분리하고, 각 worktree에 전용 CLAUDE.md를 덮어썼다. submodule·PRD·코드·git은 공통, **차이는 보조 도구만**. worktree 경로 분리 덕에 trial 간 prompt cache 오염이 없다.

**채점(Judge) — 외부 모델(codex/GPT-5)**: actor가 Claude이므로 self-evaluation 편향을 피하려 외부 모델로 채점. 4차원 0–25 rubric.

| 차원 | 가중치 | 정의 |
|-----|-------|-----|
| 정확성 | 0.4 | ground truth 핵심 사실 일치율 |
| 완결성 | 0.3 | 핵심 사실 누락 없는가 |
| 인용 | 0.2 | `[[wiki/..]]`, `PRD §X`, `9folders <SHA>` 명시 |
| 과잉 (역지표) | 0.1 | 불필요 사변·환각·반복 비율 |

task prompt에는 ground truth를 노출하지 않고 judge만 보유. Inter-rater agreement(Cohen's κ)는 가중 평균 0.86으로 rubric을 통과했다(excess 차원만 κ=0.25로 약하지만 가중치 0.1).

---

## 3. 작업별 승자 — 패턴은 단순하지 않다

전체 평균은 Wiki의 손을 들어주지만, 작업 유형에 따라 승자가 갈린다. 평균 점수 기준 1위:

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

- **Wiki는 혼합·종합형 작업에서 robust**하다. 8개 중 5개(T1·T2·T5·T6·T7)에서 1위. 특히 여러 소스를 종합해야 하는 T2(cross-language)·T6(외부 자료)에서 강하다. 큐레이션이 제값을 한다.
- **Vanilla가 이기는 작업이 둘 있다.** T4(전수 grep)·T8(cross-domain). 둘 다 **답이 단일 소스에 명확히 있어 큐레이션이 오히려 손실**인 경우다. T4는 코드 전체 grep으로 끝나고, T8은 PRD 표를 직접 읽는 게 가장 정확하다.
- **Graphify는 T3 1개만 1위, 그것도 9.50/25로 절대 점수가 낮다.** 강점을 기대했던 cross-language(T2)에서도 wiki에 크게 졌다 — INFERRED edge가 noise를 더하고 query overhead가 시간을 키웠다.

---

## 4. 통계적 유의성

Friedman 주효과: 시간 p=4.5e-07, 품질 p=0.0016 (둘 다 강력), 토큰 p=0.093 (한계적).

Wilcoxon pairwise (Bonferroni 보정):

| 비교 | 차원 | p_corr | Cohen's d | 판정 |
|-----|-----|--------|-----------|------|
| vanilla > wiki | 토큰 | 0.0105 | +0.842 | **유의 (large)** |
| vanilla > wiki | 시간 | 3.93e-05 | +0.975 | **유의 (large)** |
| graphify > wiki | 시간 | 3.58e-07 | -1.150 | **유의 (large)** |
| wiki > graphify | 품질 | 0.00678 | +0.666 | **유의 (medium-large)** |
| vanilla vs wiki | 품질 | 0.7312 | -0.216 | 차이 없음 |
| vanilla vs graphify | 품질 | 0.2459 | +0.420 | 차이 없음 |

정리하면 **Wiki는 vanilla 대비 토큰·시간을 큰 효과로 절감(품질 동등)하고, graphify 대비 품질·시간 모두 우월**하다. graphify-first는 우리 워크로드에서 기본 도구로 부적합하다.

---

## 5. 그래서 어떻게 운영하는가

벤치마크 결과를 받아 정리한 기본 정책이다.

1. **Wiki-first** — 운영 사실은 `wiki/index.md` → 관련 노트를 먼저 읽는다.
2. **없으면 즉시 원본으로** — 위키에 없으면 PRD → 코드 read/grep. 절대 만들어내지 않는다.
3. **단일 소스 회수가 명확하면 위키를 건너뛴다** — 한 노트로 좁혀지지 않으면 빠르게 직접 read로 넘어간다(T4·T8형).
4. **Graphify는 보조** — cross-component 의존성 추적에만 선택적으로 쓴다.

운영하며 얻은 가장 큰 교훈은 따로 있다. **위키를 만드는 것보다, 답변마다 출처를 인용하게 만드는 게 더 어렵고 더 중요하다.** 초기엔 기록은 활발했지만 답변에 `[[..]]` 인용이 10% 미만이라 위키 가치가 절반밖에 발현되지 않았다. 답변 직전 "이 사실에 위키 인용이 있는가?"를 강제하는 체크 규칙 하나로 인용률이 바로 정상화됐다.

---

## 6. 캐비엇

- **excess 차원의 IRR이 약하다**(κ=0.25). 모든 기법의 transcript를 함께 본 채점이라 excess 점수가 일괄 가혹했다. 가중치 0.1이라 결론 영향은 작지만 절대값은 보수적으로.
- **Wiki bias 우려**: 8개 작업 모두 wiki에 ground truth가 있어 유리할 수 있다. 다만 judge는 source가 아닌 ground truth 사실 자체를 평가한다.
- **Claude Code 기반 측정**이다. 다른 모델·도구 환경에서는 결과가 다를 수 있다. 이 수치는 우리 환경의 정책 근거이지 universal claim이 아니다.

---

## 정리

Karpathy의 LLM Wiki 패턴은 우리 도메인에서 **토큰 54% 절감, 시간 39% 단축, 품질 동등 이상**의 효과를 냈고, 통계적으로도 large effect로 유의했다. 기본 도구를 위키로 바꾼 결정은 데이터가 뒷받침한다.

다만 패턴을 직역하면 안 된다. 답이 단일 소스에 명확한 작업에서는 큐레이션 비용이 손해고, Graphify는 기본 도구로는 부적합하되 특정 경로 질의에서는 위키보다 낫다. **패턴은 받아들이되, 자기 워크로드의 작업 분포와 소스 구조를 함께 봐야 한다.** 8 task × 3 기법 × 3 trial = 72 run이면 1–2일 안에 답이 나오니, 직접 한 번 측정해 보시길 권한다.

---

[^karpathy]: Andrej Karpathy, *LLM Wiki* (GitHub Gist, 2026-04). https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f

---
title: "오픈소스 프로젝트들로부터 배우는 소프트웨어 팩토리 모범사례 (1/4): 판별 기준과 12개 저장소"
date: 2026-10-10T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - software-factory
  - agentic-dev
  - vibe-coding
  - openclaw
  - best-practices
---

> "수정하고 내보낼 권한이 릴리스 권한은 아니다(fix/ship authority is not release authority)." – OpenClaw `AGENTS.md`[^1]

{{< figure src="/posts/images/Dohyun.png" title="정도현 - 로보코 수석 컨설턴트" style=".author-image">}}

---

2026년 3월, OpenClaw 저장소를 분석해 [바이브 코딩 모범 사례 9가지](/posts/openclaw-vibe-coding-best-practices/)를 정리했다.[^2] 한 명의 개발자가 여러 AI 에이전트를 지휘해 대규모 모노레포를 운영하는 방식이었다. 9월에는 [바이브 코딩을 넘어서 소프트웨어 팩토리로](/posts/beyond-vibe-coding-software-factory/)라는 글에서 그다음 단계를 전망했다.[^3] 요구 파악부터 설계, 구현, 검증, 배포, 운영 관찰까지가 하나의 흐름으로 이어지고, 사람은 목표와 제약을 정하고 판단이 필요한 순간에만 개입하는 운영 방식이다. 나는 이것을 **소프트웨어 팩토리** 라고 불렀다.

그 글은 전망이었고 사례는 없었다. 그래서 이번에는 실제로 팩토리처럼 돌아가는 프로젝트를 찾아 나섰다. 방법은 전편과 같다. 공개 저장소에 남은 에이전트 지침 파일, CI 워크플로, 봇 설정, 커밋·PR·이슈 이력을 직접 읽고 운영 방식을 역으로 재구성했다. 일종의 리버스 엔지니어링이다. 운영의 증거는 저장소에서 확인한 것을 중심으로 삼았고, 기업 블로그 같은 자사 설명은 출처를 밝혀 구분해 인용했다. 수치는 2026년 10월 10일에 GitHub API로 조회한 값이며, 표본과 기간은 본문에 함께 적었다.

이 글은 4편으로 구성한 연재 「오픈소스 프로젝트들로부터 배우는 소프트웨어 팩토리 모범사례」의 첫 편이다. 이번 편에서는 판별 기준과 전체 결과, 그리고 프로젝트들에서 반복해서 보인 패턴을 정리한다. 2-4편에서는 그 패턴 중 세 가지를 하나씩 깊게 다룬다.

**연재 구성**

1. 판별 기준과 12개 저장소: 무엇을 팩토리라 부르고, 어디서 돌아가고 있는가 (이 글)
2. [누가 병합하는가: 위험 기반 위임과 권한 구조](/posts/software-factory-who-merges/)
3. [증거로 거르는 팩토리: "수정 전에는 실패한다"는 증명](/posts/software-factory-evidence-before-fix/)
4. [실패를 규칙으로: 자기 개선 루프와 그 한계](/posts/software-factory-failures-into-rules/)

## TL;DR

- 공개 저장소 12곳(Beads와 Gas Town은 따로 셈)을 분석했다. 그중 8곳, 프로젝트로 묶으면 7개(OpenClaw, OpenHands, Beads/Gas Town, mastra, Bun, Astro, Vercel AI SDK)를 소프트웨어 팩토리로 판정했다.
- 봇이 main 브랜치 병합을 대량으로 하는 것을 확인한 곳은 OpenClaw 하나다. 다른 팩토리에서는 사람의 최종 병합이 주로 관찰되었고, 그 병합은 대개 한 사람에게 몰려 있었다.
- 공통 실천은 "수정 전에는 실패한다"는 증거 요구, 권한 구조로 구현한 위임 경계, 실패를 근거와 함께 규칙으로 바꾸는 습관이다. 그리고 이슈에서 병합까지 사람 없이 흘러가게 두기보다, 착수와 확인 지점에 경계를 둔 사례가 많았다.

---

## 1. 무엇을 소프트웨어 팩토리라고 부를 것인가

에이전트가 코드를 많이 쓴다는 사실만으로 팩토리라고 부를 수는 없다. 한 사람이 터미널에서 에이전트와 대화하며 코드를 쓰는 것도 에이전트가 코드를 쓰는 일이다. 팩토리와 바이브 코딩을 가르는 것은 **흐름이 사람의 매번 지시 없이 이어지는가** 다. 그래서 9월 글의 정의를 저장소에서 확인할 수 있는 기준 6개로 바꿨다.

| # | 기준 | 저장소에서 확인한 것 |
|---|---|---|
| 1 | 작업 유입 자동화 | 이슈·피드백·에러가 사람의 매번 지시 없이 에이전트 작업이 되는가 |
| 2 | 다중 병렬 흐름 | 여러 에이전트 작업이 동시에 돌고, 충돌을 막는 규칙이 있는가 |
| 3 | 자동화된 검증 게이트 | 테스트·리뷰 봇·품질 게이트가 병합 가능 여부를 정하는가 |
| 4 | 위험 기반 위임 범위 | 자동 병합이 허용되는 변경과 사람 승인이 필요한 변경이 나뉘는가 |
| 5 | 보고 체계 | 사람이 모든 로그를 읽지 않고도 판단할 수 있는가 |
| 6 | 자기 개선 루프 | 운영 중 실패가 테스트·지침·워크플로 수정으로 되돌아가는가 |

각 기준은 네 단계로 판정했다. **충족** 은 장치와 실제 동작 흔적이 모두 저장소에 있다는 뜻이다. **부분** 은 둘 중 하나만 있거나 핵심 단계를 사람이 한다는 뜻이다. **미충족** 은 반대 증거가 있다는 뜻이고, **미확인** 은 공개 저장소로는 판단할 수 없다는 뜻이다.

종합 판정의 문턱은 두 가지다. 첫째, 제품 코드의 개발 흐름이 공개 저장소에서 관찰되어야 한다. 둘째, 6개 기준 모두에서 장치가 확인되어야 한다. 즉 미충족이나 미확인이 하나도 없어야 한다. 이 문턱을 넘으면 충족이 몇 개인지와 관계없이 팩토리로 판정했다. 충족 개수는 팩토리의 성숙도를 비교하는 데 썼다.

참고로 "소프트웨어 팩토리"라는 말을 앞장서 쓴 StrongDM은 이를 "명세와 시나리오가 코드를 쓰는 에이전트를 움직이는 비대화형 개발(non-interactive development where specs + scenarios drive agents that write code)"로 정의한다.[^4] 사람이 코드를 쓰지도, 리뷰하지도 않아야 한다는 규칙도 둔다. 내 기준과 가장 크게 다른 지점은 4번이다. 나는 위험에 따라 사람의 승인을 남기는 것을 팩토리의 요건으로 보지만, StrongDM은 사람의 리뷰를 없애고 검증 하네스를 강화하는 쪽을 택했다. 이 차이는 2편에서 다시 다룬다.

---

## 2. 12곳을 들여다본 결과

후보는 두 경로로 모았다. 하나는 이미 알려진 사례(OpenClaw, Aider, OpenHands, Codex, Claude Code, StrongDM, Gas Town)이고, 다른 하나는 에이전트 봇이 작성한 병합 PR이 많은 저장소를 GitHub 검색으로 찾은 것(Vercel AI SDK, Astro, mastra, Bun)이다. Beads는 Gas Town과 같은 팀의 저장소여서 함께 조사했다.

| 프로젝트 | 1 유입 | 2 병렬 | 3 게이트 | 4 위임 | 5 보고 | 6 개선 | 종합 판정 |
|---|---|---|---|---|---|---|---|
| [OpenClaw](https://github.com/openclaw/openclaw) | 충족 | 충족 | 충족 | 충족 | 충족 | 충족 | 팩토리 |
| [Beads](https://github.com/gastownhall/beads) | 충족 | 충족 | 충족 | 부분 | 충족 | 충족 | 팩토리 |
| [Gas Town](https://github.com/gastownhall/gastown) | 충족 | 충족 | 충족 | 부분 | 충족 | 부분 | 팩토리 (main은 7월 이후 정지) |
| [mastra](https://github.com/mastra-ai/mastra) | 충족 | 부분 | 충족 | 부분 | 충족 | 충족 | 팩토리 |
| [Bun](https://github.com/oven-sh/bun) | 부분 | 충족 | 충족 | 부분 | 부분 | 충족 | 팩토리 |
| [Astro](https://github.com/withastro/astro) | 충족 | 충족 | 부분 | 부분 | 충족 | 부분 | 팩토리 |
| [Vercel AI SDK](https://github.com/vercel/ai) | 충족 | 부분 | 충족 | 부분 | 충족 | 부분 | 팩토리 (엔진 비공개) |
| [OpenHands](https://github.com/OpenHands/OpenHands) | 부분 | 부분 | 충족 | 부분 | 부분 | 충족 | 팩토리 (착수·병합은 사람) |
| [Aider](https://github.com/Aider-AI/aider) | 부분 | 미충족 | 부분 | 미충족 | 충족 | 부분 | 고도화된 바이브 코딩 |
| [OpenAI Codex](https://github.com/openai/codex) | 부분 | 미확인 | 충족 | 부분 | 부분 | 충족 | 판단 불가 (2026년 8월 말 이후 내부 저장소 미러) |
| [Claude Code](https://github.com/anthropics/claude-code) | 충족 | 부분 | 부분 | 부분 | 부분 | 부분 | 판단 불가 (제품 소스 비공개, 이슈 운영만 관찰) |
| [StrongDM](https://factory.strongdm.ai/) | 미확인 | 부분 | 부분 | 미확인 | 미확인 | 부분 | 관찰 불가 (팩토리 운영 본체 비공개) |

표에서 가장 먼저 눈에 띄는 것은 4번 열이다. 팩토리로 판정한 8곳 중 위험 기반 위임을 충족한 곳은 OpenClaw 하나다. 나머지는 코드 변경을 주로 사람이 병합하기 때문에, 위험에 따라 자동 병합 범위를 다르게 주는 장치가 드러나지 않았다. 문턱을 가장 아슬아슬하게 넘은 곳은 OpenHands다. 충족이 2개뿐이고, 구현 착수와 병합을 모두 사람이 한다.

규모를 보여 주는 수치도 있다. Bun에서는 Claude 기반 에이전트 `robobun`이 2026년 9월 한 달 동안 PR 2,313건을 열었고, 그달 병합된 PR 560건 중 446건을 작성했다.[^5] Vercel AI SDK는 9월 병합 PR 845건 중 294건(34.8%)을 팩토리 봇이 작성했다.[^6] Vercel은 블로그에서 팩토리가 주간 병합 PR의 25-35%를 쓴다고 밝혔는데, 월간 실측치도 이 범위 안에 있다. 다만 기간 단위가 달라 직접 검증한 것은 아니다.[^7] mastra는 9월 병합 PR 1,531건 중 434건을 봇이 썼다.[^8]

판정할 수 없었던 곳도 의미가 있다. OpenAI Codex 저장소에서는 2026년 8월 27일 이후 미러링 봇이 내부 저장소의 변경을 옮겨 온 병합 PR이 2,170건이고, 최근 병합 PR 200건은 모두 이 봇이 올렸다. 9월 30일에는 루트 `AGENTS.md`와 스킬 12개가 공개 저장소에서 삭제되었다.[^9] Claude Code 저장소에는 제품 소스가 없고 이슈 운영 자동화만 공개되어 있다. 리버스 엔지니어링은 공개된 만큼만 볼 수 있다.

---

## 3. 병합 권한과 엔진의 위치

12곳을 두 가지 질문으로 다시 나눠 보면 구조가 더 잘 보인다. 하나는 "누가 main 브랜치에 병합하는가"이고, 다른 하나는 "팩토리를 돌리는 엔진과 설정이 어디에 있는가"다.

| 병합 주체 \ 엔진 위치 | 저장소 밖 (비공개) | 일부 공개 | 공개 저장소 |
|---|---|---|---|
| 봇이 main에 대량 병합 | | | **OpenClaw** (최근 병합 300건 중 203건) |
| 사람의 최종 병합이 주로 관찰됨 | Vercel AI SDK, Bun | OpenHands | mastra, Astro, Beads, Aider(대조 사례) |
| 병합 주체를 확인하지 못함 | OpenAI Codex, Claude Code | StrongDM | Gas Town |

봇에게 main 병합을 대량으로 넘긴 것을 확인한 곳은 엔진까지 공개한 OpenClaw 하나다. OpenClaw는 유지보수 봇 ClawSweeper를 별도 공개 저장소로 운영하고, 봇이 병합해도 되는 조건을 README에 적어 두었다.[^10] Astro도 엔진을 별도 공개 저장소(`withastro/factory`)로 두었지만, 9월 팩토리 PR은 모두 사람이 병합했다.[^11] Gas Town은 병합 PR 200건 중 173건을 한 계정이 병합했는데, 이 계정이 사람인지 에이전트의 통로인지 확인하지 못했다. 사람의 병합이 주로 관찰된 곳에도 예외는 있다. 예를 들어 Bun의 9월 robobun PR 병합 446건 중 1건은 다른 봇 계정이 병합했다.

엔진의 위치는 리버스 엔지니어링으로 볼 수 있는 깊이를 정한다. 오른쪽 열은 에이전트 지침부터 실행 엔진까지 읽을 수 있다. 왼쪽 열은 봇이 남긴 라벨, 코멘트, PR만 보인다. Vercel AI SDK의 팩토리 봇은 비공개 GitHub App이어서, 자기 개선 루프가 실제로 프롬프트를 고쳤는지는 확인할 수 없었다.

---

## 4. 7개월 뒤의 OpenClaw

3월 글은 OpenClaw를 바이브 코딩의 관점에서 분석했다. 이번 기준으로 다시 보니, OpenClaw는 이번 조사에서 6개 기준을 모두 충족한 유일한 프로젝트였다. 그 사이 새로 생긴 장치도 많다. 이 장치들은 2-4편에서 자세히 다루고, 여기서는 3월 글과 달라진 점만 짚는다.

- **유지보수 봇 ClawSweeper**: 2026년 4월 23일에 별도 저장소로 만들어졌다. 이슈·PR 이벤트를 받아 리뷰, 라벨링, 수리, 병합을 한다. 엄격한 버그 조건을 통과한 이슈는 Codex로 PR을 자동 생성하지만, 이렇게 만든 PR은 자동 병합하지 않는다.[^10]
- **위험 등급별 권한**: 문서만 바뀌는 변경은 Docs Agent가 경로 허용 목록을 검사한 뒤 main에 직접 push한다.[^12] 일반 코드는 필수 체크 하나와 봇 리뷰로 병합될 수 있다. 민감한 경로는 정책 파일로 따로 관리하고, 보안 정책 파일 자체는 SecOps 팀이 승인한다.[^13] 릴리스는 사람이 수동으로 실행한다. 이 글 맨 위의 인용문이 이 원칙을 요약한다.
- **실패율 차단기**: 자동 구현 워커의 성공률이 10월 3-9일 16.9%(52회 성공, 256회 실패)로 떨어졌다. 그 뒤 최근 7일 동안 10회 이상 실행되었고 성공률이 50% 미만이면 자동 구현을 멈추는 장치가 추가되었다.[^14]

3월 글의 내용 중 바뀐 것도 있다. `CLAUDE.md` 심볼릭 링크는 2026년 9월 19일에 폐기되어 이제 `AGENTS.md`만 정본이다.[^15] CONTRIBUTING의 AI 사용 공개 의무도 8월 30일에 삭제되었다.[^16] 대신 PR에 동작 증거(Evidence)를 첨부하라고 요구한다. 에이전트가 썼는지를 묻는 대신, 동작한다는 증거를 묻는 쪽으로 바뀐 것이다.

---

## 5. 프로젝트들에서 반복된 6가지 패턴

도구와 규모는 달랐지만, 아래 여섯 가지는 세 곳 이상에서 반복해서 보였다.

### 5.1 병합은 아직 사람의 일이고, 한 사람에게 몰려 있다

2026년 9월 기준으로 Bun은 robobun PR 병합의 78%를, mastra는 봇 PR 병합의 82%를 각각 한 사람이 했다.[^5][^8] Astro는 9월 팩토리 PR 31건 중 28건을 한 메인테이너가 승인하고 병합했다.[^11] 코드 생산은 자동화되었지만, 병합 판단이 처리량의 병목이자 단일 장애점으로 남았다. 그 장애점이 실제로 멈춘 사례가 Aider다. 최근 릴리스에서 새 코드의 21-88%를 Aider 자신이 썼지만, 메인테이너가 다른 일로 바빠지자 커밋이 거의 멈췄다.[^17] (2편에서 다룬다.)

### 5.2 "수정 전에는 실패한다"를 증거로 요구한다

에이전트는 항상 통과하는 의미 없는 테스트를 쉽게 만든다. 다섯 곳이 수정 전 실패 증거를 요구하거나 검사한다. Bun은 PR 본문에 수정 전 실패 로그를 붙이고, 기존 릴리스에서도 통과하는 테스트를 무효로 본다.[^18] mastra는 CI가 PR이 바꾼 테스트만 수정 전 코드에 돌려 실패하는지 확인한다.[^19] 다만 결과는 라벨로만 붙고, 실패 라벨이 붙은 채 병합된 PR도 있다. Vercel AI SDK는 재현 → 실패하는 테스트 → 수정 순서로 커밋을 쌓고, 처음의 재현을 다시 돌려 해결 여부를 판정한다.[^20] OpenClaw와 Astro의 에이전트도 수정 전에 실패하는 회귀 테스트를 먼저 만들도록 지시받는다. (3편에서 다룬다.)

### 5.3 판단은 에이전트가, 되돌리기 어려운 실행은 결정적 코드가 한다

Claude Code 저장소에서 이슈의 중복 판정은 Claude가 하지만, 실제로 이슈를 닫는 일은 유예 기간(중복은 3일)이 지난 뒤 규칙 기반 스크립트가 한다.[^21] Astro의 팩토리는 쓰기 토큰을 에이전트에게 주지 않고 커밋·푸시 단계의 워크플로 코드에만 둔다.[^11] mastra는 에이전트가 작업 카드를 "완료"로 옮기지 못하게 서버가 막고, 병합만이 카드를 완료로 만든다.[^22] 위임의 경계를 프롬프트가 아니라 권한 구조로 구현한 것이다. (2편에서 다룬다.)

### 5.4 실패를 근거와 함께 규칙으로 바꾼다

Beads의 유지보수 지침은 규칙마다 그 규칙을 만든 사고를 날짜와 PR 번호로 적는다.[^23] Astro는 에이전트가 changeset을 자주 빠뜨린 원인을 "사소한 수정이면 생략해도 된다고 합리화할 수 있는 지시문"으로 진단하고 지시문을 고쳤다.[^24] Bun은 병합 PR 약 2,500개의 리뷰 이력에서 병합을 막은 이유만 모아 `REVIEW.md`를 만들었다.[^25] 다만 규칙이 실제로 지켜지는지 자동으로 측정하는 곳은 드물다. Astro의 스킬 평가(eval)는 CI에 연결되지 않았다. (4편에서 다룬다.)

### 5.5 착수와 확인 지점에 경계를 둔다

OpenAI Codex는 이슈를 PR로 바꾸던 워크플로를 2025년 8월에 "설계 문제"를 이유로 제거했다.[^26] mastra는 자동 모드에서 수동 모드로 돌아갔다고 블로그에서 밝혔고, 9월 22일 이후 봇 PR의 82%에는 작업을 시작한 사람이 기록되어 있다.[^27] Astro는 자동으로 수정을 만들지만, 사람이 프리뷰 릴리스로 동작을 확인하기 전에는 PR을 열지 않는다.[^28] OpenClaw는 자동 구현을 엄격한 버그로 제한하고 실패율 차단기를 달았다. 이슈의 분류는 자동화하되, 구현 착수나 PR 생성에는 사람의 확인이나 엄격한 조건을 둔 사례가 많았다.

### 5.6 에이전트의 신원과 사람의 책임을 기록으로 잇는다

OpenHands는 PR 본문을 `HUMAN:`과 `AGENT:` 구획으로 나눈다. 지침은 에이전트가 `HUMAN:` 구획을 쓰지 못하게 하고, CI는 그 구획에 사람이 쓴 내용이 최소 길이 이상 있는지 검사한다.[^29][^30] Beads는 에이전트 행위에 `Agent-Signature:` 트레일러를 남기고, 모델을 모르면 추측하지 말고 `unknown-model`로 쓰게 한다.[^31] mastra는 봇 PR에 "Opened by @사람"을, OpenClaw는 "Worked on by @사람"을 붙인다. 에이전트가 무엇을 했는지와 누가 그 결과를 책임지는지를 함께 남기는 것이다.

---

## 6. 아직 풀리지 않은 문제

공개된 실패 중에는 코드가 동작해도 의도나 저장소 밖의 영향을 놓친 사례가 있었다. 코드 품질의 문제와 달리, 이런 실패는 테스트와 리뷰 봇이 걸러 내기 어렵다.

- **"동작한다"와 "의도에 맞다"는 다르다.** Astro의 팩토리는 의도된 동작을 버그로 보고 고쳤다. 이 수정은 사람이 동작을 확인한 뒤 병합되었다가, 릴리스 전에 되돌려졌다.[^32] 같은 문제로 새 이슈가 열리자 팩토리는 같은 수정을 다시 만들었고, 그 PR은 닫혔다.[^33]
- **저장소 밖의 영향은 보이지 않는다.** OpenHands에서 AI 리뷰 봇의 승인만으로 병합된 에이전트 PR이, 다른 저장소(enterprise)에서 기능을 쓸 수 없게 만들 수 있다는 이유로 되돌려졌다.[^34] CI도 리뷰 봇도 그 저장소를 볼 수 없었다.
- **병합하는 사람이 곧 처리량이다.** 5.1에서 보았듯이 한 사람의 시간이 팩토리 전체의 속도를 정한다.

이 조사의 한계도 적어 둔다. 엔진이 비공개인 곳은 결과물만 볼 수 있다. 대부분의 수치는 2026년 9월 한 달이나 최근 PR 100-300건 표본이다. 에이전트 작업이 사람 계정으로 올라오는 곳(OpenHands 등)에서는 에이전트 비중을 PR 본문의 서명으로만 셀 수 있으므로 실제보다 작게 잡혔을 수 있다.

---

## 결론

7개월 전 OpenClaw를 분석할 때 핵심은 한 사람이 여러 에이전트를 어떻게 지휘하는가였다. 이번에 들여다본 프로젝트들의 질문은 달랐다. 에이전트가 만든 결과를 **무엇으로 거르고, 어디까지 맡기고, 실패를 어떻게 규칙으로 바꾸는가** 였다.

소프트웨어 팩토리는 이미 공개 저장소에서 돌아가고 있다. 다만 사람 없이 돌아가는 공장은 아직 거의 없다. 사람이 코드를 직접 쓰는 비중은 줄었지만, 착수를 승인하고, 병합하고, 실패에서 규칙을 만드는 일의 비중은 커졌다. 그리고 그 일이 지금 팩토리의 속도와 품질을 함께 정한다.

다음 편에서는 첫 번째 질문인 "누가 병합하는가"를 다룬다. OpenClaw가 봇에게 병합을 넘길 수 있었던 조건과, 나머지 프로젝트가 사람의 병합을 남긴 이유를 저장소의 정책 파일과 권한 구조로 비교한다.

**다음 글:** [(2/4) 누가 병합하는가: 위험 기반 위임과 권한 구조](/posts/software-factory-who-merges/)

---

[^1]: OpenClaw AGENTS.md: https://github.com/openclaw/openclaw/blob/main/AGENTS.md
[^2]: OpenClaw: 세계 최대 바이브 코딩 프로젝트에서 배우는 9가지 모범 사례: https://roboco.io/posts/openclaw-vibe-coding-best-practices/
[^3]: 바이브 코딩을 넘어서 소프트웨어 팩토리로: https://roboco.io/posts/beyond-vibe-coding-software-factory/
[^4]: StrongDM, Software Factory: https://factory.strongdm.ai/
[^5]: oven-sh/bun, robobun이 작성한 PR. 2026-09 생성·병합 PR을 GitHub API로 집계(2026-10-10): https://github.com/oven-sh/bun/pulls?q=is%3Apr+author%3Arobobun
[^6]: vercel/ai, ai-sdk-factory 봇이 작성한 병합 PR. 2026-09 병합 PR을 GitHub API로 집계(2026-10-10): https://github.com/vercel/ai/pulls?q=is%3Apr+is%3Amerged+author%3Aapp%2Fai-sdk-factory
[^7]: Vercel, "Building a software factory for AI SDK": https://vercel.com/blog/building-a-software-factory-for-ai-sdk
[^8]: mastra-ai/mastra, mastra-platform 봇이 작성한 병합 PR. 2026-09 병합 PR을 GitHub API로 집계(2026-10-10): https://github.com/mastra-ai/mastra/pulls?q=is%3Apr+is%3Amerged+author%3Aapp%2Fmastra-platform
[^9]: openai/codex PR #49713: https://github.com/openai/codex/pull/49713
[^10]: openclaw/clawsweeper README: https://github.com/openclaw/clawsweeper/blob/main/README.md
[^11]: withastro/factory README: https://github.com/withastro/factory
[^12]: OpenClaw docs-agent.yml: https://github.com/openclaw/openclaw/blob/main/.github/workflows/docs-agent.yml
[^13]: OpenClaw security-review-policy.yml: https://github.com/openclaw/openclaw/blob/main/.github/security-review-policy.yml
[^14]: openclaw/clawsweeper PR #1855: https://github.com/openclaw/clawsweeper/pull/1855
[^15]: OpenClaw 커밋 9c831c7551, "chore: retire CLAUDE.md files": https://github.com/openclaw/openclaw/commit/9c831c7551
[^16]: OpenClaw PR #132968: https://github.com/openclaw/openclaw/pull/132968
[^17]: Aider 이슈 #4613, "Where is Paul?": https://github.com/Aider-AI/aider/issues/4613
[^18]: oven-sh/bun CLAUDE.md: https://github.com/oven-sh/bun/blob/main/CLAUDE.md
[^19]: mastra changed-test-gate.yml: https://github.com/mastra-ai/mastra/blob/main/.github/workflows/changed-test-gate.yml
[^20]: vercel/ai PR #22424: https://github.com/vercel/ai/pull/22424
[^21]: anthropics/claude-code issue-lifecycle.ts: https://github.com/anthropics/claude-code/blob/main/scripts/issue-lifecycle.ts
[^22]: Mastra Factory README, Board transition policy: https://github.com/mastra-ai/mastra/blob/main/mastracode/factory/README.md
[^23]: gastownhall/beads PR_MAINTAINER_GUIDELINES.md: https://github.com/gastownhall/beads/blob/main/PR_MAINTAINER_GUIDELINES.md
[^24]: withastro/astro PR #17475: https://github.com/withastro/astro/pull/17475
[^25]: oven-sh/bun REVIEW.md: https://github.com/oven-sh/bun/blob/main/REVIEW.md
[^26]: openai/codex PR #2729: https://github.com/openai/codex/pull/2729
[^27]: Mastra, "Announcing Mastra Factory Beta": https://mastra.ai/blog/announcing-mastra-factory-beta
[^28]: withastro/astro factory.yml: https://github.com/withastro/astro/blob/main/.github/factory.yml
[^29]: OpenHands PR 템플릿: https://github.com/OpenHands/OpenHands/blob/main/.github/pull_request_template.md
[^30]: OpenHands check_pr_description.py: https://github.com/OpenHands/OpenHands/blob/main/.github/scripts/check_pr_description.py
[^31]: gastownhall/beads AGENT_SIGNING.md: https://github.com/gastownhall/beads/blob/main/engdocs/AGENT_SIGNING.md
[^32]: withastro/astro PR #18030, "Revert forwarding user class to Picture's outer element": https://github.com/withastro/astro/pull/18030
[^33]: withastro/astro PR #18052: https://github.com/withastro/astro/pull/18052
[^34]: OpenHands PR #18048: https://github.com/OpenHands/OpenHands/pull/18048

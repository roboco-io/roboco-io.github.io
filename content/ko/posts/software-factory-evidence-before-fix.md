---
title: "오픈소스 프로젝트들로부터 배우는 소프트웨어 팩토리 모범사례 (3/4): 증거로 거르는 팩토리"
date: 2026-10-10T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - software-factory
  - agentic-dev
  - testing
  - code-review
  - best-practices
---

> "테스트가 `USE_SYSTEM_BUN=1`에서 통과한다면 그 테스트는 유효하지 않다(Your test is NOT VALID if it passes with `USE_SYSTEM_BUN=1`)." – Bun `CLAUDE.md`[^1]

{{< figure src="/posts/images/Dohyun.png" title="정도현 - 로보코 수석 컨설턴트" style=".author-image">}}

---

이 글은 4편으로 구성한 연재 「오픈소스 프로젝트들로부터 배우는 소프트웨어 팩토리 모범사례」의 세 번째 편이다.

**연재 구성**

1. [판별 기준과 12개 저장소: 무엇을 팩토리라 부르고, 어디서 돌아가고 있는가](/posts/software-factory-best-practices-from-open-source/)
2. [누가 병합하는가: 위험 기반 위임과 권한 구조](/posts/software-factory-who-merges/)
3. 증거로 거르는 팩토리: "수정 전에는 실패한다"는 증명 (이 글)
4. [실패를 규칙으로: 자기 개선 루프와 그 한계](/posts/software-factory-failures-into-rules/)

맨 위의 인용은 Bun 저장소의 에이전트 지침에 있는 문장이다. `USE_SYSTEM_BUN=1`은 수정하기 전의 기존 Bun 릴리스로 테스트를 돌리라는 설정이다. 즉 이 규칙은 "수정 전 코드에서도 통과하는 테스트는 아무것도 증명하지 못한다"는 뜻이다.

[2편](/posts/software-factory-who-merges/)에서는 병합 권한을 누구에게 주느냐보다, 병합 전에 무엇이 확인되도록 강제하느냐가 중요하다고 정리했다.[^2] 이번 편은 그 확인의 내용을 다룬다. 에이전트는 코드를 빨리 만들지만, 항상 통과하는 의미 없는 테스트와 실제보다 부풀린 작업 보고도 쉽게 만든다. 그리고 Bun의 에이전트 `robobun`이 2026년 9월 한 달에 연 PR은 2,313건이다.[^3] 이 규모에서는 사람이 모든 diff를 읽을 수 없다. 그래서 팩토리들은 사람이 코드를 읽기 전에 **증거** 부터 보게 만든다. 수치는 앞의 편들과 마찬가지로 2026년 10월 10일에 GitHub API로 조회한 값이다.

## TL;DR

- 관찰한 사례를 묶어 보면, 팩토리들이 요구하는 증거는 세 겹이다. 문제가 실제로 있다는 재현, 수정 전에는 실패하고 수정 후에는 통과한다는 테스트, 그리고 단위 테스트를 넘어선 실제 동작 증거다.
- 그중 세 프로젝트가 서로 다른 방식으로 구현한 장치가 "수정 전 실패" 증명이다. Bun은 PR 본문에 수정 전 실패 로그를 붙이고, mastra는 CI가 새 테스트를 수정 전 코드에 돌려 실패하는지 확인하며, 관찰한 Vercel AI SDK의 수정 PR은 재현 → 실패 테스트 → 수정 순서로 커밋을 쌓았다.
- 증거는 우회될 수 있다. mastra에서는 수정 전 실패 게이트의 실패 라벨이 붙은 채 병합된 PR이 있고, Astro에서는 "동작한다"는 확인을 받은 수정이 의도와 달라 되돌려졌다. 나는 증거 장치가 병합 조건에 연결될 때, 그리고 의도까지 확인할 때 힘을 갖는다고 본다.

---

## 1. 세 겹의 증거

관찰한 프로젝트들이 에이전트에게 요구하는 증거를 내 기준으로 묶으면 세 종류다.

| 증거의 종류 | 묻는 질문 | 대표 장치 |
|---|---|---|
| 재현 | 문제가 실제로 존재하는가 | Vercel AI SDK의 재현 PR, Astro의 재현 단계 |
| 수정 전 실패 | 이 테스트가 정말 그 문제를 잡는가 | Bun의 증거 블록, mastra의 수정 전 코드 테스트 게이트, Vercel AI SDK의 커밋 순서 |
| 실제 동작 | 단위 테스트 밖에서도 동작하는가 | OpenClaw의 동작 증거 라벨, OpenHands의 라이브 E2E, Astro의 프리뷰 릴리스 |

나는 이 세 겹이 순서대로 쌓인다고 본다. 재현이 없으면 무엇을 고쳤는지 알 수 없고, 수정 전 실패가 없으면 테스트가 무엇을 증명하는지 알 수 없다. 그리고 단위 테스트가 통과해도 실제 환경에서 깨질 수 있다는 것이 세 번째 겹이 필요한 이유다.

---

## 2. 먼저 재현한다

Vercel AI SDK의 팩토리는 버그 이슈를 받으면 먼저 재현을 시도한다. 재현에 성공하면 예제 파일과 재현 기록 파일(`reproduction-replay.json`)을 담은 초안 PR을 만든다. 관찰한 이슈 #22412의 재현 PR은 확인 뒤 닫혔다.[^4] 재현 결과는 라벨로 남는다. `task-bug-reproduction-success`, `-cannot-reproduce`, `-issue-invalid`, `-out-of-scope` 같은 라벨이 있고, 지원하는 버전(v5, v6)마다 결과를 따로 기록한다.[^5] 이 결과에 따라 다음 단계가 갈리는 것으로 보이지만, 팩토리의 내부 규칙은 저장소 밖에 있어 확인하지 못했다.

Astro의 팩토리는 재현 → 진단 → 의도 검증 → 수정 순서로 일한다. 각 단계에 멈추는 규칙이 있다. 재현용 서버 시작이 두 번 실패하면 포기하고 보고서를 쓴다. 진단의 확신도가 낮으면 거기서 멈춘다. 의도 검증 단계에서 "의도된 동작"이라고 판정하면 수정하지 않는다.[^6] 확신도가 낮을 때는 코드를 고치는 대신 실패하는 테스트와 `// TRIAGE:` 주석만 남기는 경로도 있다. 사람이 이어받을 수 있도록 단서만 남기는 것이다.

Bun에서는 에이전트가 이슈에 재현 결과를 직접 단다. 2026년 9월에 생성된 이슈 중 441건에 robobun의 코멘트가 있고, 재현하지 못하면 공식 릴리스 바이너리로 실행한 기록과 함께 "재현할 수 없다"고 남긴다.[^7]

---

## 3. 수정 전에는 실패해야 한다

재현이 문제의 존재를 증명한다면, 수정 전 실패는 테스트의 가치를 증명한다. 세 프로젝트가 이것을 서로 다른 방식으로 구현했다.

### 3.1 Bun: PR 본문의 증거 블록

Bun의 에이전트 지침은 수정 전 릴리스에서 통과하는 테스트를 무효로 규정한다.[^1] 이 규칙은 PR 본문에서 기계적으로 드러난다. 2026년 9월에 robobun이 연 PR 2,313건 중 1,827건에 증거 블록이 있다.[^3] 증거 블록에는 "수정 없이 main에서 실패(fails on main, without fix)"한 실행 로그, 게이트를 몇 번 반복해 통과했는지, 그리고 변경한 파일마다 몇 번 읽고 고치고 테스트했는지가 들어 있다.[^8] PR 본문도 문제(Problem), 검증(Verified), 단점(Downsides) 같은 고정된 섹션을 따른다. 리뷰어는 코드를 읽기 전에 이 증거를 먼저 본다.

### 3.2 mastra: 수정 전 코드에 새 테스트를 돌리는 CI

mastra는 같은 원칙을 CI로 검사한다. `changed-test-gate.yml`은 PR의 기준 커밋을 체크아웃한 뒤, PR이 바꾼 테스트 파일만 PR 쪽에서 가져와 수정 전 코드에 대해 실행한다. 이 테스트가 실패해야 정상이다. 결과는 라벨로 붙는다. 실패하면 "변경된 테스트가 예상대로 기준 코드에서 실패함"이라는 뜻의 `tests: green ✅`, 통과해 버리면 `tests: failing ❌`, 테스트가 없으면 `tests: no tests added`다.[^9]

이 워크플로는 보안도 고려했다. PR의 코드는 시크릿이 없는 환경에서 실행하고, 라벨을 붙이는 쓰기 작업은 별도 워크플로로 분리했다. 에이전트가 만든 테스트 코드가 쓰기 권한을 가진 토큰에 닿지 않게 하기 위해서다.[^9] 2026년 9월에 병합된 봇 PR 434건의 라벨은 `tests: green ✅` 354건, `tests: no tests added` 33건, `tests: failing ❌` 24건이었다.[^10]

### 3.3 Vercel AI SDK: 커밋 순서가 증거가 된다

관찰한 Vercel AI SDK의 수정 PR #22424는 커밋을 "재현 → 실패하는 테스트 → 수정" 순서로 쌓았다. 커밋 제목은 "reproduction (reproduced)", "failing tests", "fix #22412" 순서다. 커밋 이력 자체가 수정 전에 테스트가 실패했다는 기록이 된다. 그다음 AI 리뷰가 처음의 재현을 다시 실행한 결과를 맨 먼저 확인하고, 이슈가 해결되었는지, 부작용과 성능 위험은 없는지를 판정한다. 이 PR에서 AI 리뷰는 1차에 프로덕션 경로가 수정되지 않았다며 변경을 요청했고, 수정 후 승인했다.[^11] 2026년 9월 팩토리 PR 중 AI 리뷰가 1차에 변경을 요청한 PR은 20건이다.[^5]

OpenClaw의 자동 구현 워커와 Astro의 팩토리도 수정 전에 실패하는 회귀 테스트를 먼저 만들도록 지시받는다.[^12][^6]

---

## 4. 단위 테스트만으로는 부족하다

수정 전 실패 테스트도 결국 단위 테스트일 수 있다. 몇몇 프로젝트는 여기서 한 걸음 더 나갔다.

OpenClaw는 2026년 10월, 최근 작업에서 단위 테스트가 잡지 못한 결함 다섯 건이 그대로 출시되었다고 기록하고 지침을 바꿨다. 결함 중에는 캐시 토큰이 0으로 기록되는 문제, 비용을 들여 얻은 결과를 버리는 문제, 상태 표시를 저장하지 않아 같은 처리가 반복되는 루프가 있었다. 바뀐 지침은 테스트의 개수보다 의미 있는 통합 증거를 우선한다.[^13] `AGENTS.md`의 원칙도 "테스트 개수보다 동작(Behavior over test count)"이다.[^14] 외부 기여자의 PR에는 실제 동작 증거를 확인하는 워크플로가 돌고, 증거가 충분한지를 `proof: sufficient` 같은 라벨로 표시한다.[^15]

OpenHands의 PR 템플릿은 에이전트에게 "단위 테스트를 돌리는 것만으로는 충분하지 않다. 정확히 어떤 명령을 실행했는지 설명하고 로그와 스크린샷을 첨부하라"고 지시한다. 프런트엔드를 바꾼 PR에는 실행 중인 앱의 스크린샷이나 영상이 있어야 CI를 통과한다.[^16][^17] CI는 실제 에이전트 서버를 띄워 라이브 E2E를 돌리고 결과 영상을 PR 코멘트로 남긴다.[^18] 그리고 매일 에이전트가 기준선 이후 바뀐 기능만 실제 UI로 다시 검증한다.[^19]

Beads의 에이전트 지침은 이 원칙을 한 문장으로 적는다. "변경이 처음부터 끝까지 동작한다는 증거가 필요하다. '단위 테스트 통과'만으로는 증거가 아니다."[^20]

Astro는 사람을 증거 수집에 끌어들였다. 팩토리가 만든 수정을 먼저 설치 가능한 프리뷰 패키지로 게시하고, 이슈를 올린 사람이나 메인테이너가 자기 환경에서 동작을 확인해야 PR이 열린다. 2026년 9월 팩토리 PR 31건 중 19건은 이슈 제보자가, 12건은 메인테이너가 확인했다.[^21]

StrongDM은 반대 방향의 극단을 택했다고 설명한다. 검증 시나리오를 코드 저장소 밖에 두어 에이전트가 시나리오를 코드에 맞게 고치지 못하게 하고, 이 "홀드아웃 시나리오"가 통과할 때까지 루프를 돌린다는 것이다.[^22] 다만 이것은 회사의 설명이고, 공개 저장소에서는 확인할 수 없었다.

---

## 5. 증거를 우회하지 못하게 하기

증거 장치는 우회될 수 있다. 관찰한 프로젝트들은 몇 가지 우회 경로를 막고 있었다.

- **불안정한 테스트(flaky test)를 핑계로 삼지 못하게 한다.** Bun의 PR 병합 지침은 모든 플랫폼에서 CI가 통과하는 것을 필수 조건으로 두고, "아마 불안정한 테스트일 것"이라고 주장하려면 main에서 같은 실패가 난 링크를 붙이라고 요구한다.[^23] OpenClaw는 불안정한 테스트를 재실행하거나 다시 push해서 넘기는 것을 금지하고 원인 분석을 요구했다.[^24] OpenAI Codex의 PR 감시 에이전트는 불안정한 실패를 최대 3번까지만 재실행할 수 있었다.[^25]
- **리뷰어가 증거를 직접 다시 만든다.** mastra의 리뷰 에이전트는 샌드박스에서 바뀐 패키지의 테스트와 타입 검사를 직접 실행한다. 이때 GitHub 토큰을 환경에서 지운다. CI 결과는 참고만 하고, 판정을 게시하기 직전에 PR의 최신 커밋이 자신이 검증한 커밋과 같은지 다시 확인한다.[^26]
- **부풀린 보고를 막는다.** Bun의 에이전트 지침은 "겸손하고 정직하라. 한 일을 절대 과장하지 말라"고 적는다.[^1] 그리고 PR에 `slop` 라벨이 붙으면 워크플로가 제목을 바꾸고 PR을 닫는다. 이때 남기는 메시지는 그 이유로 문제가 실제로 있는지 확인하지 않음, 수정이 동작하는지 테스트하지 않음, 코드베이스에 대한 잘못된 가정, 불완전하거나 오해를 부르는 변경을 든다. 이 라벨을 자동으로 붙이는 워크플로는 없어서, 사람이 붙이는 것으로 보인다. 이 라벨이 붙은 PR 248건 중 228건이 robobun의 PR이다.[^27]

그래도 구멍은 남아 있다.

- **증거와 병합 조건의 연결이 약하다.** mastra의 수정 전 실패 게이트는 결과를 라벨로 붙인다. 그런데 `tests: failing ❌` 라벨을 단 채 병합된 PR이 83건 있다.[^10] 브랜치 보호 설정은 공개 API로 확인할 수 없어서, 이것이 규칙상 허용된 것인지 사람이 우회한 것인지는 알 수 없다. Astro는 공개 API 기준으로 main 브랜치의 필수 상태 체크 목록이 비어 있고, 릴리스 PR 하나는 Windows E2E 테스트가 실패한 상태로 병합되었다.[^28]
- **"동작한다"는 증거가 "의도에 맞다"를 보증하지 않는다.** Astro에서 메인테이너가 동작을 확인한 팩토리 수정이 병합되었지만, 실제로는 의도된 동작을 바꾼 것이어서 릴리스 전에 되돌려졌다.[^29] 동작 확인을 거쳤는데도 그랬다.

---

## 6. 모범 사례

1. **수정 전 코드에서 통과하는 테스트는 무효로 규정한다.** 규칙을 에이전트 지침에 적고, 수정 전 실패 로그를 PR 본문에 붙이게 한다. (Bun)
2. **그 규칙을 CI로 검사하고, 결과를 병합 조건에 연결한다.** PR이 바꾼 테스트만 수정 전 코드에 돌린다. 라벨로만 남기면 우회된다. (mastra의 장치, mastra와 Astro의 교훈)
3. **재현 → 실패 테스트 → 수정 순서로 커밋하고, 처음의 재현을 다시 돌려 해결을 판정한다.** 커밋 이력이 그대로 증거가 된다. (Vercel AI SDK)
4. **재현과 진단의 각 단계에 멈춤 조건을 둔다.** 재현이 안 되거나 확신이 낮으면 수정하지 말고 단서만 남긴다. (Astro)
5. **단위 테스트 밖의 동작 증거를 요구한다.** 실행한 명령과 로그, 스크린샷, 라이브 E2E, 실제 사용자의 확인처럼 실제 환경에 가까운 증거를 요구한다. (OpenClaw, OpenHands, Beads, Astro)
6. **에이전트가 만든 테스트 코드는 시크릿과 쓰기 권한이 없는 곳에서 실행한다.** (mastra)
7. **불안정한 테스트를 이유로 넘어가려면 근거를 요구하고, 재시도 횟수를 제한한다.** (Bun, OpenClaw, OpenAI Codex)

---

## 결론

에이전트가 하루에 수십 개의 PR을 여는 환경에서 리뷰어가 diff를 읽는 것만으로는 품질을 지킬 수 없다. 관찰한 팩토리들은 리뷰의 출발점을 코드에서 증거로 옮겼다. 문제가 있다는 재현, 테스트가 그 문제를 잡는다는 수정 전 실패, 그리고 실제 환경에서의 동작 증거다.

하지만 증거도 만능은 아니다. 증거가 병합 조건과 연결되지 않으면 우회될 수 있고, 동작한다는 증거가 있어도 의도와 다를 수 있다. 다음 편에서는 이런 실패가 일어난 뒤를 다룬다. 프로젝트들이 실패를 어떻게 규칙과 지침으로 바꾸는지, 그리고 그 자기 개선 루프가 아직 어디서 끊기는지를 살펴본다.

**다음 글:** [(4/4) 실패를 규칙으로: 자기 개선 루프와 그 한계](/posts/software-factory-failures-into-rules/)

---

[^1]: oven-sh/bun CLAUDE.md: https://github.com/oven-sh/bun/blob/main/CLAUDE.md
[^2]: 오픈소스 프로젝트들로부터 배우는 소프트웨어 팩토리 모범사례 (2/4): 누가 병합하는가: https://roboco.io/posts/software-factory-who-merges/
[^3]: oven-sh/bun, robobun이 작성한 PR. 2026-09 생성 PR과 PR 본문을 GitHub API로 집계(2026-10-10): https://github.com/oven-sh/bun/pulls?q=is%3Apr+author%3Arobobun
[^4]: vercel/ai PR #22416 (재현 PR): https://github.com/vercel/ai/pull/22416
[^5]: vercel/ai 라벨 목록. 라벨별 PR 수를 GitHub API로 집계(2026-10-10): https://github.com/vercel/ai/labels
[^6]: withastro/astro .agents/skills (triage 스킬): https://github.com/withastro/astro/tree/main/.agents/skills
[^7]: oven-sh/bun 이슈 #44276: https://github.com/oven-sh/bun/issues/44276
[^8]: oven-sh/bun PR #40556: https://github.com/oven-sh/bun/pull/40556
[^9]: mastra changed-test-gate.yml: https://github.com/mastra-ai/mastra/blob/main/.github/workflows/changed-test-gate.yml
[^10]: mastra-ai/mastra, 2026-09 병합 봇 PR 434건의 테스트 게이트 라벨 분포와 `tests: failing ❌` 라벨이 붙은 병합 PR 수를 GitHub API로 집계(2026-10-10): https://github.com/mastra-ai/mastra/pulls?q=is%3Apr+is%3Amerged+label%3A%22tests%3A+failing+%E2%9D%8C%22
[^11]: vercel/ai PR #22424: https://github.com/vercel/ai/pull/22424
[^12]: openclaw/clawsweeper README: https://github.com/openclaw/clawsweeper/blob/main/README.md
[^13]: OpenClaw PR #168083: https://github.com/openclaw/openclaw/pull/168083
[^14]: OpenClaw AGENTS.md: https://github.com/openclaw/openclaw/blob/main/AGENTS.md
[^15]: OpenClaw real-behavior-proof.yml: https://github.com/openclaw/openclaw/blob/main/.github/workflows/real-behavior-proof.yml
[^16]: OpenHands PR 템플릿: https://github.com/OpenHands/OpenHands/blob/main/.github/pull_request_template.md
[^17]: OpenHands check_pr_description.py: https://github.com/OpenHands/OpenHands/blob/main/.github/scripts/check_pr_description.py
[^18]: OpenHands ci.yml: https://github.com/OpenHands/OpenHands/blob/main/.github/workflows/ci.yml
[^19]: OpenHands verify-openhands 스킬, daily.md: https://github.com/OpenHands/OpenHands/blob/main/.agents/skills/verify-openhands/references/daily.md
[^20]: gastownhall/beads AGENTS.md: https://github.com/gastownhall/beads/blob/main/AGENTS.md
[^21]: withastro/astro factory.yml: https://github.com/withastro/astro/blob/main/.github/factory.yml
[^22]: StrongDM, Software Factory: https://factory.strongdm.ai/
[^23]: oven-sh/bun .claude/docs/landing-prs.md: https://github.com/oven-sh/bun/blob/main/.claude/docs/landing-prs.md
[^24]: OpenClaw 커밋 3b76ad8461: https://github.com/openclaw/openclaw/commit/3b76ad8461
[^25]: openai/codex babysit-pr 스킬(삭제 전 버전): https://github.com/openai/codex/blob/5e96aabd68dc6194f5ad928cb7f5d0bc71b72df9/.codex/skills/babysit-pr/SKILL.md
[^26]: mastra factory-review 스킬: https://github.com/mastra-ai/mastra/blob/main/mastracode/factory/factory-skills/factory-review/SKILL.md
[^27]: oven-sh/bun on-slop.yml: https://github.com/oven-sh/bun/blob/main/.github/workflows/on-slop.yml
[^28]: withastro/astro PR #18113: https://github.com/withastro/astro/pull/18113
[^29]: withastro/astro PR #18030: https://github.com/withastro/astro/pull/18030

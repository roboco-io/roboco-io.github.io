---
title: "오픈소스 프로젝트들로부터 배우는 소프트웨어 팩토리 모범사례 (2/4): 누가 병합하는가"
date: 2026-10-10T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - software-factory
  - agentic-dev
  - openclaw
  - code-review
  - best-practices
---

> "(마이그레이션·스키마·동기화 경로의 변경은) 병합 전에 실제 사람의 리뷰를 받는다. 예외도, 셀프 병합도, 봇 단독 승인도 없다(a real human review before merge — no exceptions, no self-merge, no bot-only approval)." – Beads `PR_MAINTAINER_GUIDELINES.md`[^1]

{{< figure src="/posts/images/Dohyun.png" title="정도현 - 로보코 수석 컨설턴트" style=".author-image">}}

---

이 글은 4편으로 구성한 연재 「오픈소스 프로젝트들로부터 배우는 소프트웨어 팩토리 모범사례」의 두 번째 편이다.

**연재 구성**

1. [판별 기준과 12개 저장소: 무엇을 팩토리라 부르고, 어디서 돌아가고 있는가](/posts/software-factory-best-practices-from-open-source/)
2. 누가 병합하는가: 위험 기반 위임과 권한 구조 (이 글)
3. [증거로 거르는 팩토리: "수정 전에는 실패한다"는 증명](/posts/software-factory-evidence-before-fix/)
4. [실패를 규칙으로: 자기 개선 루프와 그 한계](/posts/software-factory-failures-into-rules/)

[1편](/posts/software-factory-best-practices-from-open-source/)에서는 공개 저장소 12곳을 리버스 엔지니어링해 8곳을 소프트웨어 팩토리로 판정했다.[^2] 그중 봇이 main 브랜치 병합을 대량으로 하는 것을 확인한 곳은 OpenClaw 하나였다. 나머지 팩토리에서는 사람의 최종 병합이 주로 관찰되었고, 그 병합은 대개 한 사람에게 몰려 있었다.

이번 편은 이 차이를 파고든다. OpenClaw는 어떤 조건에서 봇에게 병합을 맡겼는가? 사람 계정의 병합이 관찰된 프로젝트들은 왜 봇에게 병합을 맡기지 않았고, 그 대신 무엇으로 에이전트의 권한을 제한하는가? 수치는 1편과 마찬가지로 2026년 10월 10일에 GitHub API로 조회한 값이다.

## TL;DR

- OpenClaw는 변경의 위험 등급마다 자동화 권한을 다르게 준다. 문서 변경은 에이전트가 main에 직접 push하고, 일반 코드는 게이트를 통과하면 봇이 병합하며, 보안 정책·릴리스는 사람이 승인한다. 이 등급이 정책 파일과 CODEOWNERS로 정의되어 있다.
- 사람 계정의 병합이 관찰된 프로젝트들의 저장소에서는 그 배경을 세 가지로 읽을 수 있다. GitHub App이 자기 PR을 승인할 수 없다는 구조적 제약, 리뷰를 건너뛴 병합이 사고를 낳았다는 경험, 그리고 무엇을 만들지와 의도에 맞는지는 사람이 정한다는 원칙이다.
- 사람의 병합 기록이 사람의 리뷰 기록은 아니다. Bun의 봇 PR은 82%가 GitHub의 승인 요건이 남은 상태로 병합되었고, OpenHands에서는 AI 리뷰 봇의 승인만으로 필수 승인이 채워진 PR이 많았다. 병합 권한보다 중요한 것은 그 권한을 행사하기 전에 무엇을 확인하게 하느냐다.

---

## 1. 병합 권한의 스펙트럼

먼저 팩토리로 판정한 프로젝트들이 병합을 어떻게 처리하는지 한 표에 모았다. "병합 집중도"는 해당 PR 묶음에서 가장 많이 병합한 한 계정의 비율이다. 브랜치 규칙은 GitHub API로 main 브랜치의 규칙을 조회해 확인했다.[^3]

| 프로젝트 | 병합 게이트 (브랜치 규칙) | 관찰된 병합 주체 | 병합 집중도 |
|---|---|---|---|
| OpenClaw | 필수 체크 1개, 필수 승인 0건 + CODEOWNERS 경로만 승인 필요 | 최근 병합 300건 중 203건을 봇이 병합 | - |
| Vercel AI SDK | 필수 승인 1건 + 필수 체크 4개 | 9월 팩토리 PR 294건 모두 승인 상태에서 사람이 병합 | 294건 중 63% |
| OpenHands | 필수 체크 1개 + 필수 승인 1건 | 최근 병합 100건 모두 사람이 병합 | 100건 중 69% |
| Beads | 필수 체크 2개 + 머지 큐 | 최근 병합 300건 중 296건을 한 계정이 병합 | 99% |
| mastra | 공개 API로 확인 못 함 | 9월 봇 PR 434건 모두 사람이 병합 | 82% |
| Bun | 공개 API로 확인 못 함 | 9월 robobun PR 446건 중 443건을 사람이 병합 | 78% |
| Astro | 필수 체크 목록이 비어 있음 | 9월 팩토리 PR 31건 모두 사람이 승인·병합 | 31건 중 28건 |

표의 왼쪽 열이 보여 주듯, 봇 병합을 허용하는 핵심은 브랜치 규칙이다. OpenClaw의 main 브랜치는 필수 승인 수가 0이다. 그 대신 CODEOWNERS로 지정한 경로에는 해당 팀의 승인을 요구하고, 새 커밋이 올라오면 이전 승인을 무효로 만든다.[^4] 반면 Vercel AI SDK와 OpenHands는 필수 승인을 1건 이상 요구한다. 이 조건에서 팩토리 App은 자기가 연 PR의 승인 요건을 스스로 채울 수 없다. 다만 다른 봇의 승인까지 막지는 않는다. OpenHands에서는 실제로 그런 병합이 많았다(5절).

---

## 2. OpenClaw가 봇에게 병합을 맡긴 조건

OpenClaw에서 병합을 하는 봇은 유지보수 봇 ClawSweeper다. ClawSweeper는 아무 PR이나 병합하지 않는다. README에 적힌 자동 병합 조건은 다음과 같다. 최신 커밋(exact head)에 대한 리뷰 판정이 통과해야 하고, 필수 체크가 모두 통과해야 하며, 병합 가능한 상태여야 한다. 보안 검사, 메인테이너의 중지·승인 상태, 저장소 정책 게이트도 모두 통과해야 한다.[^5] 관찰일 기준으로 `clawsweeper:automerge` 라벨이 붙은 PR 803건 중 576건이 병합되었다.

중요한 것은 이 자동 병합이 **옵트인** 이라는 점이다. 메인테이너가 PR에 `@clawsweeper automerge`를 써야 자동 병합 대상이 되고, `@clawsweeper stop`을 쓰면 자동 병합이 멈추고 사람 검토 라벨이 붙는다. 이 명령은 쓰기 권한이 있는 사람만 쓸 수 있다. 관찰일 기준 `clawsweeper:human-review` 라벨이 붙은 항목은 210건이다.[^5]

그리고 변경의 종류에 따라 자동화가 할 수 있는 일이 다르다. 저장소 파일들을 종합하면 아래와 같은 위험 등급이 드러난다.

| 변경의 종류 | 자동화 권한 | 근거 파일 |
|---|---|---|
| 문서 (`docs/*`, README, 기존 CHANGELOG 미러) | Docs Agent가 허용된 경로의 기존 파일 갱신과 미러 재생성만 할 수 있다. 파일 추가·삭제나 다른 경로 수정이 있으면 실패하고, 통과하면 PR 없이 main에 직접 push | `docs-agent.yml`[^6] |
| 일반 코드 | 필수 체크와 봇 리뷰를 통과하고 메인테이너가 옵트인하면 봇이 병합 | ClawSweeper README[^5] |
| 이슈에서 자동 생성한 PR | 자동 병합하지 않음. 사람이 병합 | ClawSweeper README[^5] |
| 민감한 경로 (인증 등) | 메인테이너 권한이 없는 작성자(에이전트 포함)는 승인 명령을 받아야 함 | `security-review-policy.yml`[^7] |
| 보안 정책·CI 보안 설정 파일 | 작성자와 관계없이 SecOps 팀의 독립 리뷰 필요 | `CODEOWNERS`[^4] |
| 릴리스·배포, 의존성, 스키마·권한 변경 | 명시적인 사람 승인 필요 | `AGENTS.md`[^8] |

민감한 경로를 정한 `security-review-policy.yml`은 인증 같은 범주별로 경로 패턴을 정의하고, 테스트와 문서 경로는 제외한다. 2026년 9월의 변경에 따라 메인테이너 권한이 없는 작성자는 `/allow-security-sensitive-change` 같은 명령으로 메인테이너의 승인을 받아야 한다. OpenClaw 제품 자체로 돌아가는 에이전트 계정(roboclaw-bot)도 여기에 포함된다.[^9] `CODEOWNERS`의 첫 줄 주석은 "모든 작성자에게 독립적인 SecOps 리뷰가 필요한 강한 보안 등급(Hard security tier: an independent SecOps review is required for every author)"이라고 적는다. 여기에 해당하는 항목이 18개, 릴리스 관리자 팀이 소유한 항목이 5개다.[^4]

`AGENTS.md`는 사람의 명시적 승인이 필요한 일을 목록으로 둔다. 프로토콜·버전 변경, 의존성 패치, 유료 서비스, 릴리스와 배포, 새 설정 옵션, 공개 계약을 깨는 변경, 스키마·보존·권한 변경, 파괴적인 작업, 50건을 넘는 일괄 종료가 여기에 들어간다. 반대로 작업 범위 안의 버그 수정은 다시 승인받지 않고 진행해도 된다.[^8] 이 글 1편 맨 위에 인용한 "수정하고 내보낼 권한이 릴리스 권한은 아니다"가 이 목록의 요약이다.

정리하면 OpenClaw가 봇에게 병합을 맡길 수 있었던 조건은 세 가지다. 첫째, 봇이 병합해도 되는 변경의 범위가 파일로 정의되어 있다. 둘째, 보안 정책 파일과 민감한 경로처럼 위험이 큰 변경은 CODEOWNERS와 보안 가드가 기계적으로 막는다. 릴리스와 의존성 같은 나머지 승인 요구는 `AGENTS.md`의 지침으로 정해져 있고, 릴리스는 수동으로 실행하는 워크플로로만 시작된다. 릴리스 환경에 필수 승인자가 설정되어 있는지는 공개 API로 확인하지 못했다. 셋째, 사람은 언제든 옵트인을 거두고 자동화를 멈출 수 있다.

---

## 3. 사람의 병합을 남긴 이유

사람 계정의 병합이 관찰된 프로젝트들은 왜 봇에게 병합을 맡기지 않았을까. 저장소에서 읽을 수 있는 배경은 세 갈래다. 프로젝트가 직접 이유를 밝힌 경우도 있고, 장치를 보고 추론한 경우도 있다.

### 3.1 GitHub App은 자기 PR을 승인할 수 없다

Astro, mastra, Vercel AI SDK의 팩토리는 모두 GitHub App으로 PR을 만든다. GitHub은 App이 자신이 연 PR을 승인하지 못하게 한다. 그래서 Astro의 리뷰 페르소나는 판정을 승인 리뷰가 아닌 코멘트로 남기고, mastra의 리뷰 에이전트도 자기 PR에 대한 판정을 일반 코멘트로 게시한다.[^10][^11] 필수 승인이 1건 이상인 저장소에서는 팩토리 App이 자기 PR의 승인 요건을 채울 수 없으므로, 다른 봇이 승인하지 않는 한 사람의 승인이 남는다. Vercel AI SDK는 릴리스 PR의 자동 병합에 개인 토큰을 쓰고 있는데, 워크플로 주석은 그 이유를 "원래 App 토큰을 써야 하지만, PR을 만드는 App이 자기 PR을 승인할 수 없으므로 두 번째 App을 등록해야 한다"고 설명한다.[^12]

### 3.2 리뷰를 건너뛴 병합이 사고를 냈다

Beads는 병합된 PR 440건을 두 달 동안 감사한 뒤, 프로젝트의 가장 나쁜 결함이 "리뷰를 건너뛰었거나, 실제 내용을 숨겼거나, 남아 있던 반대 의견을 넘어선 병합"으로 들어왔다고 결론 내렸다. 그 결과 사소하지 않은 PR의 셀프 병합을 금지하고, 마이그레이션·스키마·동기화 경로에는 이 글 맨 위의 인용처럼 예외 없는 사람 리뷰를 요구했다.[^1] 실제로 리뷰 0건으로 셀프 병합된 마이그레이션 PR이 데이터 손상을 일으킨 기록이 남아 있다.[^13]

다만 이 규칙은 아직 문서에만 있다. 관찰일 기준 Beads의 브랜치 규칙은 필수 체크와 머지 큐만 요구하고, 리뷰 필수 조건은 없다. 문서 스스로도 "이 경로들은 관례에만 맡기지 말고 브랜치 보호(리뷰 필수)로 강제하는 것이 좋다"고 적고, 그 작업을 프로젝트 소유자의 과제로 남겨 두었다.[^1]

### 3.3 의도를 판단할 사람이 필요하다

Astro의 팩토리 문서는 작성 에이전트가 "절대 병합하지 않는다"고 명시한다. 작성 에이전트는 리뷰어의 변경 요청이나 CI 실패에 대응해 최대 5라운드까지 고치고, 예산을 다 쓰면 `factory: needs human` 라벨을 붙이고 스스로 빠진다.[^10] mastra는 버그가 아닌 이슈(기능 요청 등)는 사람의 수용 기록 없이 계획 단계로 넘어갈 수 없게 서버가 막는다. 관찰일 기준 이 승인을 기다리는 열린 이슈가 50건이다.[^11] 무엇을 만들지, 그 변경이 의도에 맞는지는 사람이 정한다는 원칙이다.

코드 리뷰에 대해서는 StrongDM이 정반대의 접근을 택했다. StrongDM도 사람이 처음의 명세를 주고 에이전트의 질문에 답하는 지점은 남긴다. 그러나 "코드는 사람이 리뷰해서는 안 된다(Code must not be reviewed by humans)"는 규칙을 두고, 사람의 리뷰 대신 코드 저장소 밖에 둔 시나리오로 검증한다고 설명한다.[^14] 다만 1편에서 다룬 대로 그 운영은 공개 저장소에서 관찰되지 않는다.

---

## 4. 권한을 코드로 구현하는 방법

사람이 병합하더라도, 에이전트가 할 수 있는 일은 줄여야 한다. 관찰한 프로젝트들은 이 경계를 프롬프트가 아니라 권한 구조로 구현했다. 공통 원칙은 **판단은 에이전트가 하고, 되돌리기 어려운 실행은 규칙 기반 코드가 한다** 는 것이다.

- **쓰기 도구를 좁히고 횟수를 제한한다.** Claude Code 저장소의 이슈 분류 에이전트는 읽기 전용 GitHub 명령 래퍼와 라벨 편집 스크립트만 쓸 수 있다. 라벨 편집 스크립트는 한 번 실행에 두 번까지만 호출할 수 있고, 파일 편집과 웹 접근은 금지된다. 그 이유는 누구나 이슈를 열어 이 작업을 실행시킬 수 있기 때문이다.[^15]
- **되돌리기 어려운 행동은 유예 기간 뒤에 스크립트가 한다.** 같은 저장소에서 이슈를 실제로 닫는 일은 에이전트가 아니라 규칙 기반 스크립트가 한다. 중복 후보는 3일, 정보 요청은 7일, 오래된 이슈는 14일의 유예 기간이 있다.[^16] 중복 후보는 이슈 작성자가 반대 표시를 하거나 새 코멘트가 달리면 닫지 않는다.[^17] 추천이 10개 이상이거나 담당자가 지정된 이슈는 오래된 이슈 처리에서 제외한다.[^18]
- **쓰기 토큰을 에이전트에게 주지 않는다.** Astro의 팩토리에서 쓰기 토큰은 커밋·푸시 단계의 워크플로 코드에만 있다. 분류기와 동작 확인 에이전트에는 도구가 없고, 리뷰어는 읽기 전용 도구만 쓴다. 리뷰 설정과 스킬은 PR의 브랜치가 아니라 대상 브랜치에서 읽는다. 따라서 PR이 리뷰 규칙을 함께 바꿔도 그 PR의 리뷰에는 적용되지 않는다.[^10] OpenAI Codex의 이슈 자동화도 Codex를 읽기 전용 샌드박스에서 실행하고, 코멘트 게시는 Codex가 없는 별도 작업이 맡는다.[^19]
- **상태 전이를 서버가 검사한다.** mastra의 팩토리 서버는 작업 카드의 모든 전이를 리비전 검사 트랜잭션으로 처리하고, 사람이 해야 하는 전이는 요청한 주체와 요청이 들어온 경로가 모두 사람에 해당해야 통과한다. 에이전트는 카드를 완료로 옮길 수 없고, 병합만이 카드를 완료로 만든다.[^11]
- **실행 직전에 상태를 다시 확인한다.** OpenClaw의 ClawSweeper는 기여자의 브랜치에 push하기 전에 90초를 기다린 뒤 PR의 최신 커밋을 다시 읽고, 그 사이 바뀌었으면 push하지 않고 다시 큐에 넣는다.[^5]

---

## 5. 사람의 병합 기록이 사람의 리뷰 기록은 아니다

1편에서 병합이 한 사람에게 몰려 있다고 썼다. 더 들여다보면 집중보다 더 눈에 띄는 것이 있다. 병합 기록은 남지만 리뷰 기록은 없는 경우가 많다는 점이다.

- Bun에서 9월에 병합된 robobun PR 446건 중 368건(82%)은 GitHub 기준으로 승인 요건이 남은 상태(`REVIEW_REQUIRED`)에서 메인테이너 권한으로 병합되었다.[^20] 병합한 사람이 실제로 얼마나 검토했는지는 기록으로 확인할 수 없다. 기록상으로는 병합한 사람이 최종 판단자다.
- mastra에서는 팩토리의 리뷰 에이전트가 마지막에 변경을 요청한 봇 PR도 사람이 그대로 병합한 경우가 있었다. 표본 27건 중 3건이고, 라벨 기준으로는 9월 봇 PR 14건이다.[^21]
- OpenHands는 필수 승인을 1건 요구하지만, 최근 병합 PR 40건 중 26건은 AI 리뷰 봇의 승인만으로 이 요건을 채웠다.[^22] 그렇게 병합된 에이전트 PR 하나는 다른 저장소의 기능을 깨뜨릴 수 있다는 이유로 사람이 되돌렸다.[^23]

반대로 Vercel AI SDK의 9월 팩토리 PR 294건은 모두 승인(`APPROVED`) 상태에서 사람이 병합했다. 승인자가 사람인지는 20건 표본에서 확인했고, 모두 사람이었다.[^24] 그리고 봇 PR의 백포트 PR은 원래 PR을 마지막으로 리뷰한 사람을 담당자로 지정한다.[^25] 리뷰한 사람에게 후속 작업을 맡기는 장치로 읽힌다.

---

## 6. 모범 사례

관찰한 장치를 다른 팀이 가져갈 수 있는 형태로 정리하면 다음과 같다. 각 항목에 근거가 된 프로젝트를 적었다.

1. **변경 종류별 위험 등급을 파일로 정의하고, 등급마다 자동화 권한을 다르게 준다.** 문서, 일반 코드, 민감 경로, 보안 정책, 릴리스를 나누고, 보안 정책과 민감 경로처럼 위험이 큰 등급은 CODEOWNERS와 보안 가드로 기계적으로 강제한다. (OpenClaw)
2. **봇의 자동 병합은 옵트인으로 시작하고, 사람이 언제든 멈출 수 있게 한다.** 중지 명령과 사람 검토 라벨을 두고, 그 명령을 쓸 수 있는 사람을 쓰기 권한자로 제한한다. (OpenClaw)
3. **에이전트에게 쓰기 토큰을 주지 말고, 쓰기는 좁은 전용 단계에서만 하게 한다.** 쓰기 도구는 호출 횟수까지 제한한다. (Astro, Claude Code, OpenAI Codex)
4. **되돌리기 어려운 행동은 유예 기간과 반대 신호 확인을 거쳐 규칙 기반 스크립트가 실행하게 한다.** (Claude Code)
5. **리뷰 규칙은 문서가 아니라 브랜치 규칙으로 강제한다.** 문서에만 있는 규칙은 지켜지지 않을 수 있다. (Beads의 교훈)
6. **승인과 리뷰를 기록으로 남기고, 리뷰한 사람을 후속 작업의 담당자로 지정한다.** (Vercel AI SDK)

마지막으로 관찰에서 나온 제안을 하나 덧붙인다. 공개 자료에서는 병합이 한 사람에게 얼마나 몰리는지를 지표로 관리하는 흔적을 찾지 못했다. 그러나 1편에서 보았듯 Aider는 메인테이너가 다른 일로 바빠지자 코드 개발이 크게 줄었다. 이슈 정리 봇은 지금도 돌지만, 코드를 병합할 사람이 없다. 병합 집중도와 승인 없이 병합된 비율을 정기적으로 확인하는 것만으로도 팩토리의 단일 장애점을 미리 볼 수 있다. 이것은 저장소에서 관찰한 사실이 아니라 관찰을 바탕으로 한 내 제안이다.

---

## 결론

누가 병합하는가에 대한 답은 생각보다 단순하지 않았다. OpenClaw는 봇에게 병합을 맡겼지만, 그 대가로 위험 등급, 브랜치 규칙, 옵트인과 중지 명령을 촘촘하게 설계했다. 다른 프로젝트는 사람의 병합을 남겼지만, 그 사람이 실제로 무엇을 확인했는지는 프로젝트마다 크게 달랐다.

결국 병합 권한을 누구에게 주느냐보다, 병합 전에 무엇이 확인되도록 강제하느냐가 팩토리의 안전을 정한다. 다음 편에서는 그 확인의 핵심인 증거를 다룬다. 에이전트가 만든 수정이 정말 문제를 고쳤는지를 프로젝트들이 어떻게 증명하게 하는지, "수정 전에는 실패한다"는 증거를 중심으로 살펴본다.

**다음 글:** [(3/4) 증거로 거르는 팩토리: "수정 전에는 실패한다"는 증명](/posts/software-factory-evidence-before-fix/)

---

[^1]: gastownhall/beads PR_MAINTAINER_GUIDELINES.md: https://github.com/gastownhall/beads/blob/main/PR_MAINTAINER_GUIDELINES.md
[^2]: 오픈소스 프로젝트들로부터 배우는 소프트웨어 팩토리 모범사례 (1/4): 판별 기준과 12개 저장소: https://roboco.io/posts/software-factory-best-practices-from-open-source/
[^3]: GitHub REST API, 브랜치 규칙 조회 `GET /repos/{owner}/{repo}/rules/branches/main`(2026-10-10): https://docs.github.com/en/rest/repos/rules
[^4]: OpenClaw CODEOWNERS: https://github.com/openclaw/openclaw/blob/main/.github/CODEOWNERS
[^5]: openclaw/clawsweeper README: https://github.com/openclaw/clawsweeper/blob/main/README.md
[^6]: OpenClaw docs-agent.yml: https://github.com/openclaw/openclaw/blob/main/.github/workflows/docs-agent.yml
[^7]: OpenClaw security-review-policy.yml: https://github.com/openclaw/openclaw/blob/main/.github/security-review-policy.yml
[^8]: OpenClaw AGENTS.md: https://github.com/openclaw/openclaw/blob/main/AGENTS.md
[^9]: OpenClaw PR #152415: https://github.com/openclaw/openclaw/pull/152415
[^10]: withastro/factory README: https://github.com/withastro/factory
[^11]: Mastra Factory README: https://github.com/mastra-ai/mastra/blob/main/mastracode/factory/README.md
[^12]: vercel/ai auto-merge-release-prs.yml: https://github.com/vercel/ai/blob/main/.github/workflows/auto-merge-release-prs.yml
[^13]: gastownhall/beads PR #4039: https://github.com/gastownhall/beads/pull/4039
[^14]: StrongDM, Software Factory: https://factory.strongdm.ai/
[^15]: anthropics/claude-code claude-issue-triage.yml: https://github.com/anthropics/claude-code/blob/main/.github/workflows/claude-issue-triage.yml
[^16]: anthropics/claude-code issue-lifecycle.ts: https://github.com/anthropics/claude-code/blob/main/scripts/issue-lifecycle.ts
[^17]: anthropics/claude-code auto-close-duplicates.ts: https://github.com/anthropics/claude-code/blob/main/scripts/auto-close-duplicates.ts
[^18]: anthropics/claude-code sweep.ts: https://github.com/anthropics/claude-code/blob/main/scripts/sweep.ts
[^19]: openai/codex issue-deduplicator.yml: https://github.com/openai/codex/blob/main/.github/workflows/issue-deduplicator.yml
[^20]: oven-sh/bun, robobun이 작성한 PR. 2026-09 병합 PR의 리뷰 상태를 GitHub API로 집계(2026-10-10): https://github.com/oven-sh/bun/pulls?q=is%3Apr+is%3Amerged+author%3Arobobun
[^21]: mastra-ai/mastra, mastra-platform 봇이 작성한 병합 PR. 2026-09 병합 PR을 GitHub API로 집계(2026-10-10): https://github.com/mastra-ai/mastra/pulls?q=is%3Apr+is%3Amerged+author%3Aapp%2Fmastra-platform
[^22]: OpenHands/OpenHands, 최근 병합 PR 40건의 리뷰 기록을 GitHub API로 확인(2026-10-10): https://github.com/OpenHands/OpenHands/pulls?q=is%3Apr+is%3Amerged
[^23]: OpenHands PR #18048: https://github.com/OpenHands/OpenHands/pull/18048
[^24]: vercel/ai, ai-sdk-factory 봇이 작성한 2026-09 병합 PR의 리뷰 상태를 GitHub API로 집계(2026-10-10): https://github.com/vercel/ai/pulls?q=is%3Apr+is%3Amerged+author%3Aapp%2Fai-sdk-factory
[^25]: vercel/ai backport.yml: https://github.com/vercel/ai/blob/main/.github/workflows/backport.yml

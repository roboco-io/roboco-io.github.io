---
title: "오픈소스 프로젝트들로부터 배우는 소프트웨어 팩토리 모범사례 (4/4): 실패를 규칙으로"
date: 2026-10-10T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - software-factory
  - agentic-dev
  - agents-md
  - continuous-improvement
  - best-practices
---

> "이 경로에는 성공률에 따른 실행 제한이 없었고, 제한을 두지 않을 이유도 찾지 못했다(The lane has no rate gate, and I found no reason for that)." – OpenClaw ClawSweeper PR #1855[^1]

{{< figure src="/posts/images/Dohyun.png" title="정도현 - 로보코 수석 컨설턴트" style=".author-image">}}

---

이 글은 4편으로 구성한 연재 「오픈소스 프로젝트들로부터 배우는 소프트웨어 팩토리 모범사례」의 마지막 편이다.

**연재 구성**

1. [판별 기준과 12개 저장소: 무엇을 팩토리라 부르고, 어디서 돌아가고 있는가](/posts/software-factory-best-practices-from-open-source/)
2. [누가 병합하는가: 위험 기반 위임과 권한 구조](/posts/software-factory-who-merges/)
3. [증거로 거르는 팩토리: "수정 전에는 실패한다"는 증명](/posts/software-factory-evidence-before-fix/)
4. 실패를 규칙으로: 자기 개선 루프와 그 한계 (이 글)

맨 위의 인용은 OpenClaw의 자동 구현 워커가 1주일 동안 52번 성공하고 256번 실패한 뒤, 이를 보고한 PR에 적힌 문장이다. 그 PR은 실패율이 높으면 자동 구현을 멈추는 장치를 추가했다.[^1] 실패를 발견하고, 원인을 찾고, 다시 일어나지 않도록 규칙이나 장치를 바꾸는 것. 이것이 [1편](/posts/software-factory-best-practices-from-open-source/)에서 정한 판별 기준의 여섯 번째, 자기 개선 루프다.[^2]

[3편](/posts/software-factory-evidence-before-fix/)에서는 증거 장치도 우회되거나 의도를 놓칠 수 있다는 것을 보았다.[^3] 이번 편은 그런 실패가 일어난 뒤를 다룬다. 프로젝트들은 실패를 어디에, 어떤 형태로 되돌려 넣는가? 그리고 그 루프는 어디서 끊기는가? 수치는 앞의 편들과 마찬가지로 2026년 10월 10일에 GitHub API로 조회한 값이다.

## TL;DR

- 관찰한 팩토리들은 실패를 네 곳에 되돌려 넣는다. 에이전트 지침과 스킬, CI 검사, 서버나 워크플로의 장치, 그리고 자동화를 멈추거나 줄이는 결정이다.
- 사례들을 바탕으로 나는 세 가지를 권한다. 실패를 근거와 함께 기록하고, 원인을 에이전트가 아니라 지시문과 장치에서 찾고, 가능하면 지침과 CI 검사를 함께 고치는 것이다.
- 이번 공개 자료 조사에서는 마지막 단계인 효과 확인의 운영 기록이 제한적이었다. 규칙을 추가한 기록은 많지만, 그 규칙이 지켜지는지 정기적으로 자동 확인하는 기록은 찾기 어려웠다. 되돌린 결정이 기억되지 않아 같은 실수가 반복된 사례도 있다.

---

## 1. 자기 개선 루프의 네 단계

자기 개선 루프는 네 단계로 나눌 수 있다. 실패를 발견하고, 원인을 진단하고, 규칙이나 장치로 바꾸고, 그 효과를 확인하는 것이다. 각 단계가 저장소에서 어떻게 보였는지 정리하면 다음과 같다.

| 단계 | 저장소에서 관찰한 예 |
|---|---|
| 1. 발견 | OpenClaw의 실패율 집계, OpenHands의 일일 검증, Beads의 병합 PR 440건 감사, Vercel AI SDK의 `factory-flawed` 라벨 |
| 2. 진단 | Astro의 "합리화 여지" 진단, OpenClaw의 지침 잘림 발견, Claude Code의 권한 모드 오작동 발견 |
| 3. 규칙화 | Beads·OpenClaw·Bun의 지침 수정, Astro의 스킬 수정, mastra의 서버 장치 추가, OpenClaw의 차단기 |
| 4. 효과 확인 | 공개 기록이 제한적. Astro는 스킬 평가(eval)를 만들었지만 CI에 연결하지 않았다 |

앞의 세 단계는 여러 프로젝트에서 관찰되었다. 네 번째 단계는 이번 조사에서 공개된 기록만으로는 거의 확인되지 않았다. 이 글의 뒷부분에서 이 차이를 다시 다룬다.

---

## 2. 실패를 근거와 함께 기록한다

규칙만 남기고 이유를 지우면, 나중에 그 규칙을 지켜야 할지 없애야 할지 판단할 수 없다. 에이전트도 규칙의 범위를 추측해야 한다. 잘 작동하는 프로젝트들은 규칙 옆에 그 규칙을 만든 사건을 남긴다.

Beads가 가장 철저하다. 유지보수 지침의 "병합 규율(Merge Discipline)" 절은 2026년 6월 12일에 추가되었고, 근거로 병합 PR 440건을 두 달간 감사한 결과를 든다.[^4] "선행 사례 확인(Prior art)" 절은 2026년 7월 27일에 추가되었는데, 바로 전날 일어난 사건을 "계기가 된 사건(Motivating incident)"으로 적었다. 44일 된 PR이 20일 동안 병합 준비 상태로 기다리는 사이, 5일 된 중복 PR이 아무 코멘트 없이 자동 병합된 사건이다. 그 결과 모든 리뷰 전에 같은 주제의 열린 PR을 찾는 절차가 의무가 되었다.[^5] `CODEOWNERS`의 주석에도 마이그레이션 사고를 일으킨 PR 번호가 적혀 있다.[^6]

Bun은 기록을 거꾸로 활용했다. 리뷰 피드백이 수정 커밋으로 이어진 병합 PR 약 2,500개의 리뷰 이력에서, 병합을 막은 이유만 모아 `REVIEW.md`를 만들었다. 이 파일은 에이전트 지침의 일부로 쓰인다. 리뷰 봇도 이 파일을 기준으로 삼는 것으로 보이지만, 연결 설정은 공개 저장소에서 확인하지 못했다.[^7] OpenClaw는 지침을 바꾸는 PR 본문에 근거가 된 실제 결함을 나열한다. 2026년 10월의 한 PR은 단위 테스트가 놓친 결함 다섯 건을 하나씩 적고 테스트 지침을 바꿨다.[^8]

---

## 3. 원인을 지시문과 장치에서 찾는다

에이전트가 실수했을 때 "에이전트가 부족하다"로 결론 내리면 고칠 것이 없다. 관찰한 프로젝트들은 원인을 에이전트에게 준 지시문이나 장치에서 찾았다.

### 3.1 지시문이 합리화를 허용했다

Astro의 팩토리가 만든 PR은 자주 changeset(릴리스 노트용 변경 기록 파일) 없이 올라왔다. Astro는 그 원인을 "사소한 수정이면 생략해도 된다고 LLM이 합리화할 수 있게 쓰인 지시문"으로 진단했다. 그리고 선택 단계였던 changeset 생성을 필수로 다시 쓰고, 예외를 허용하는 문구를 지우고, 작업을 끝내기 직전에 `git status`를 확인하는 단계를 추가했다.[^9] Astro 저장소에는 이런 수정이 이어져 있다.

| 날짜 | 관찰된 실패 | 스킬 변경 |
|---|---|---|
| 2026-05-20 | 버그를 일찍 확인했지만 오래된 서버와 씨름하다 시간 초과로 보고서를 쓰지 못함 | 서버 시작이 두 번 실패하면 포기하는 규칙[^10] |
| 2026-07-20 | 일부 봇 PR이 lint와 타입 검사를 통과하지 못함 | 검사 강화, 토큰을 아끼는 `lint:ai` 명령 추가[^11] |
| 2026-08-20 | 봇 PR에서 changeset이 자주 빠짐 | 위에 적은 지시문 재작성[^9] |
| 2026-09-28 | 봇 PR이 임시 재현 환경의 항목을 `pnpm-lock.yaml`에 포함 | 작업 정리 단계에 락파일 원복 추가[^12] |

마지막 사례는 이슈가 열리고 약 4시간 만에 수정이 병합되었다. 수정 커밋은 팩토리 봇이 직접 만들었다.

### 3.2 지침이 너무 길어 잘렸다

OpenClaw는 `AGENTS.md`가 에이전트에게 주입될 때 20,000자에서 잘린다는 사실을 발견했다. 핵심 규칙이 에이전트에게 조각으로만 보이고 있었던 것이다. 그래서 27,913자이던 파일을 18,900자로 줄이고, 세부 규칙을 해당 영역을 담당하는 스킬로 옮겼다.[^13] 지침 파일에도 길이 예산이 필요하다는 것을 보여 준 사례다.

Beads의 `CODEOWNERS` 주석에는 성격이 다른 경고가 있다. 방어 코드를 조용히 덧붙여 온 결과, 설계 결정 문서(ADR)를 쓰기 전까지 임시방편 커밋이 8개 이상 쌓였다는 것이다.[^6] 원인을 정리하지 않고 증상마다 규칙을 덧붙이면 규칙 자체가 부채가 된다는 경고로 읽힌다.

### 3.3 지침과 CI를 함께 고친다

같은 실패를 두 층에서 막는 사례도 많다. Bun은 에이전트가 장황한 코드 주석을 다는 문제를 지침의 규칙으로 막는 동시에, `claude` 라벨이 붙은 에이전트 PR의 `src/` 변경에서 두 줄 이상의 새 주석을 찾아 삭제를 요청하는 CI(`comment-cop`)를 두었다. `SAFETY:` 표시가 붙은 주석은 예외다.[^14] Claude Code 저장소는 이슈 중복 판정 작업이 구형 모델 때문에 의도한 권한 모드로 돌지 않았다는 사실을 발견하고, 같은 PR에서 워크플로 보안 검사 스크립트와 "이 검사를 건너뛰거나 약화하지 말라"는 `CLAUDE.md` 규칙을 함께 추가했다.[^15] OpenAI Codex는 리뷰 봇이 잠금 파일 변경을 잘못 요구하는 일이 반복되자, `AGENTS.md`에 리뷰 봇이 그런 요구를 하지 않도록 적었다.[^16] OpenHands는 기존 도구로 검증할 수 없는 사용자 경로를 "하네스의 빈틈"으로 정의하고, 일회성 스크립트로 우회하지 말고 검증 도구 자체를 확장하라고 규정한다.[^17]

---

## 4. 에이전트가 자기 규칙을 고친다

새로운 점은 에이전트가 자기 지침을 직접 고친다는 것이다. 다만 대부분 사람이 지시하거나 승인한 수정이다.

- OpenClaw의 루트 `AGENTS.md`는 2026년 3월 이후 456번 수정되었다. 작성자는 메인테이너 steipete가 320건으로 가장 많고, OpenClaw 제품으로 돌아가는 에이전트 roboclaw-bot도 직접 수정 PR을 올린다.[^18] 앞에서 본 결함 다섯 건 PR도 roboclaw-bot이 올렸다.
- Bun의 `CLAUDE.md` 커밋 50개 중 4개는 robobun이, 32개(64%)는 메인테이너 한 사람이 작성했다.[^19] robobun은 90일 동안 갱신되지 않은 자기 PR을 자동으로 닫는 워크플로도 직접 만들었고[^20], 이후 두 번 고쳤다.[^21][^22]
- mastra의 리뷰 스킬 커밋 20개(2026년 7월 23일-9월 30일) 중 3개는 봇이 작성했다.[^23] 리뷰 봇이 이전 판정 본문을 재사용해 "승인"과 "변경 요청"이 섞인 리뷰를 올린 사건 뒤, 게시 직전에 판정과 커밋을 대조하게 만든 수정도 봇이 썼다. 다만 그 PR에는 작업을 시작한 사람이 기록되어 있다.[^24]
- Astro의 락파일 수정 커밋은 팩토리 봇이 만들었고, 사람이 PR을 열고 승인·병합했다.[^12]

이 가운데 Astro의 사례는 지침 변경도 일반 PR로 올라와 사람이 승인하고 병합했고, mastra의 사례도 일반 PR로 올라와 사람이 병합했다. 나는 이 점이 중요하다고 본다. 지침 변경이 코드 변경과 같은 검토를 받는 한, 에이전트가 자기 지침을 고치는 것은 위험이라기보다 자기 개선 루프를 빠르게 돌리는 수단이 된다.

---

## 5. 자동화 자체를 고치거나 멈춘다

실패가 반복되면 규칙을 더하는 대신 자동화를 줄이는 결정도 루프의 일부다.

- OpenClaw는 자동 구현 성공률이 16.9%로 떨어지고 실패한 실행이 123시간의 작업 시간을 쓰자, 성공률 기반 차단기를 추가했다.[^1] 그보다 앞서 2026년 7월에는 마지막 한 달 동안 한 번도 성공하지 못한 커밋 리뷰 경로를 아예 폐기했다.[^25]
- mastra는 팩토리를 자동 모드로 돌렸다가 PR이 몰아치듯 쏟아져 리뷰가 어려워지자 수동 모드로 바꿨다고 밝혔다.[^26]
- OpenAI Codex는 이슈를 PR로 바꾸던 워크플로를 "설계 문제"를 이유로 제거했다.[^27]

자동화를 멈추는 결정은 실패를 인정하는 것이 아니라, 자동화의 범위를 실제 성공률에 맞추는 조정이다. OpenClaw의 차단기는 이 조정을 사람의 결정이 아니라 기준으로 만들었다.

---

## 6. 루프가 끊기는 곳

여기까지가 잘 작동하는 부분이다. 저장소를 더 들여다보면 루프가 끊기는 지점도 분명하다.

- **효과를 정기적으로 측정한 기록이 없다.** Astro는 스킬 8개에 평가 케이스 24개를 만들었지만, 비용과 비결정성을 이유로 CI에 연결하지 않았다. 관찰일 기준 평가 파일 8개 중 6개는 처음 추가된 2026년 8월 13일 이후 바뀌지 않았고, 앞의 표에 나온 changeset 누락과 락파일 누수는 평가 케이스로 추가되지 않았다.[^28] 수동 실행 기록은 저장소에 남지 않아 확인할 수 없었다. 이번 조사에서 확인한 범위에서는, 규칙은 생겼지만 그 규칙이 지켜지는지 정기적으로 자동 확인하는 장치는 없었다.
- **되돌린 결정이 기억되지 않는다.** Astro의 팩토리가 의도된 동작을 버그로 보고 고친 수정은 병합 후 되돌려졌다. 그런데 같은 문제로 새 이슈가 열리자 팩토리는 같은 수정을 다시 만들었다.[^29] 관찰일 기준으로 관련 스킬은 바뀌지 않았다. 나는 이것을 되돌린 결정이 다음 작업에 전달되지 않은 사례로 본다.
- **문서에만 남는다.** Beads의 "스키마 변경은 예외 없이 사람이 리뷰한다"는 규칙은 브랜치 규칙으로 강제되지 않는다.[^30] Bun의 `CLAUDE.md`는 브랜치 이름을 `claude/`로 시작하라고 하지만, 실제 robobun의 브랜치는 `robobun/`으로 시작한다.[^31]
- **외부에서 보고된 자동화 버그가 남아 있다.** Claude Code 저장소에는 중복 이슈 자동 종료에 관한 오류 보고가 관찰일 기준 열려 있다. 안내 문구는 누구든 반대 표시를 하면 자동 종료를 막을 수 있다고 하지만 코드는 이슈 작성자의 반대만 인정한다는 보고와, 자동 종료가 라벨 목록을 `duplicate` 하나로 덮어써 영역·플랫폼 같은 다른 라벨을 지운다는 보고다.[^32][^33]
- **루프가 저장소 밖으로 사라진다.** Vercel AI SDK는 실패 분류(`factory-flawed` 11건, `factory-blocked` 60건)를 라벨로 공개하지만, 그 실패를 받아 고칠 프롬프트와 평가셋은 저장소 밖에 있다.[^34] OpenAI Codex는 리뷰 봇과 `AGENTS.md` 사이의 개선 루프가 공개 저장소에서 돌던 기록을 남겼지만, 2026년 9월 30일 `AGENTS.md`와 스킬을 공개 저장소에서 삭제했다.[^35]

9월에 쓴 [바이브 코딩을 넘어서 소프트웨어 팩토리로](/posts/beyond-vibe-coding-software-factory/)에서 나는 "개선 결과 역시 검증해야 한다. 성공 기준까지 임의로 바꿔 버리면 개선됐다는 판단 자체를 믿기 어렵다"고 썼다.[^36] 관찰한 프로젝트들은 이 위험을 일부 막고 있다. Astro의 팩토리는 PR이 아니라 대상 브랜치의 리뷰 규칙을 읽고[^37], StrongDM은 검증 시나리오를 코드 저장소 밖에 둔다고 설명한다.[^38] 그러나 이번 조사에서 공개된 기록만으로는, 개선이 실제로 효과가 있었는지를 정기적으로 측정하는 곳을 확인하지 못했다.

---

## 7. 모범 사례

1. **규칙마다 그 규칙을 만든 사건을 날짜와 PR 번호로 적는다.** 나중에 규칙을 유지할지 없앨지 판단할 근거가 된다. (Beads, OpenClaw)
2. **리뷰 이력에서 병합을 막은 이유를 추출해 에이전트와 리뷰 봇이 함께 읽는 규칙 문서로 만든다.** (Bun)
3. **실패의 원인을 지시문에서 찾는다.** 에이전트가 합리화할 여지를 주는 선택적 표현과 예외 문구를 찾아 지운다. (Astro)
4. **지침 파일에 길이 예산을 두고, 세부 규칙은 담당 스킬로 나눈다.** (OpenClaw)
5. **같은 실패를 지침과 CI 검사 두 층에서 막는다.** (Bun, Claude Code)
6. **에이전트의 지침 수정도 코드 변경과 같은 PR 리뷰를 거치게 한다.** (OpenClaw, Bun, mastra, Astro)
7. **자동화 경로마다 성공률을 집계하고, 기준 아래로 떨어지면 자동으로 멈춘다.** (OpenClaw)
8. **새 규칙을 만들 때 평가 케이스도 함께 추가하고, 그 평가를 정기적으로 돌린다.** 이번 조사의 공개 기록에서는 이것을 정기적으로 하는 곳을 확인하지 못했다. Astro의 사례를 바탕으로 한 내 제안이다.

---

## 연재를 마치며

네 편에 걸쳐 공개 저장소 12곳을 리버스 엔지니어링했다. 1편에서는 판별 기준을 세우고 8곳을 소프트웨어 팩토리로 판정했다. 2편에서는 병합 권한을, 3편에서는 검증 증거를, 이번 편에서는 자기 개선 루프를 다뤘다.

세 주제를 관통하는 내 결론은 하나다. 이 사례들에서 팩토리의 품질을 지키는 핵심은 **에이전트를 둘러싼 장치** 였다. 무엇을 자동으로 병합해도 되는지 정한 위험 등급, 에이전트의 주장을 대신하는 증거, 실패를 근거와 함께 규칙으로 바꾸는 습관이 그 장치다. 그리고 이 장치는 대부분 공개 저장소의 파일로 남아 있어서, 누구나 읽고 자기 팀에 맞게 가져갈 수 있다.

동시에 사람의 자리도 분명해졌다. 여러 사례에서 사람은 작업의 착수를 승인하고, 병합하고, 실패에서 규칙을 고치는 일을 맡았고, 필요할 때는 구현에도 직접 참여했다. 아직 풀리지 않은 문제들, 즉 의도를 확인하는 일, 저장소 밖의 영향을 보는 일, 개선의 효과를 측정하는 일도 지금은 사람의 몫이다. 다음 단계의 팩토리는 아마 이 세 가지를 어떻게 장치로 만드느냐에서 갈릴 것이다.

---

[^1]: openclaw/clawsweeper PR #1855: https://github.com/openclaw/clawsweeper/pull/1855
[^2]: 오픈소스 프로젝트들로부터 배우는 소프트웨어 팩토리 모범사례 (1/4): 판별 기준과 12개 저장소: https://roboco.io/posts/software-factory-best-practices-from-open-source/
[^3]: 오픈소스 프로젝트들로부터 배우는 소프트웨어 팩토리 모범사례 (3/4): 증거로 거르는 팩토리: https://roboco.io/posts/software-factory-evidence-before-fix/
[^4]: gastownhall/beads 커밋 9a9da38c: https://github.com/gastownhall/beads/commit/9a9da38c
[^5]: gastownhall/beads 커밋 c989b6b8: https://github.com/gastownhall/beads/commit/c989b6b8
[^6]: gastownhall/beads CODEOWNERS: https://github.com/gastownhall/beads/blob/main/.github/CODEOWNERS
[^7]: oven-sh/bun REVIEW.md: https://github.com/oven-sh/bun/blob/main/REVIEW.md
[^8]: OpenClaw PR #168083: https://github.com/openclaw/openclaw/pull/168083
[^9]: withastro/astro PR #17475: https://github.com/withastro/astro/pull/17475
[^10]: withastro/astro PR #16802: https://github.com/withastro/astro/pull/16802
[^11]: withastro/astro PR #17352: https://github.com/withastro/astro/pull/17352
[^12]: withastro/astro PR #18168: https://github.com/withastro/astro/pull/18168
[^13]: OpenClaw PR #163325: https://github.com/openclaw/openclaw/pull/163325
[^14]: oven-sh/bun comment-cop.yml: https://github.com/oven-sh/bun/blob/main/.github/workflows/comment-cop.yml
[^15]: anthropics/claude-code PR #97952: https://github.com/anthropics/claude-code/pull/97952
[^16]: openai/codex PR #29720: https://github.com/openai/codex/pull/29720
[^17]: OpenHands verify-openhands 스킬: https://github.com/OpenHands/OpenHands/blob/main/.agents/skills/verify-openhands/SKILL.md
[^18]: OpenClaw AGENTS.md 커밋 이력: https://github.com/openclaw/openclaw/commits/main/AGENTS.md
[^19]: oven-sh/bun CLAUDE.md 커밋 이력. 작성자별 커밋 수를 GitHub API로 집계(2026-10-10): https://github.com/oven-sh/bun/commits/main/CLAUDE.md
[^20]: oven-sh/bun PR #27125: https://github.com/oven-sh/bun/pull/27125
[^21]: oven-sh/bun PR #27126: https://github.com/oven-sh/bun/pull/27126
[^22]: oven-sh/bun PR #41079: https://github.com/oven-sh/bun/pull/41079
[^23]: mastra factory-review 스킬 커밋 이력. 작성자별 커밋 수를 GitHub API로 집계(2026-10-10): https://github.com/mastra-ai/mastra/commits/main/mastracode/factory/factory-skills/factory-review/SKILL.md
[^24]: mastra-ai/mastra PR #25494: https://github.com/mastra-ai/mastra/pull/25494
[^25]: openclaw/clawsweeper README: https://github.com/openclaw/clawsweeper/blob/main/README.md
[^26]: Mastra, "Announcing Mastra Factory Beta": https://mastra.ai/blog/announcing-mastra-factory-beta
[^27]: openai/codex PR #2729: https://github.com/openai/codex/pull/2729
[^28]: withastro/astro .agents/evals README: https://github.com/withastro/astro/blob/main/.agents/evals/README.md
[^29]: withastro/astro PR #18052: https://github.com/withastro/astro/pull/18052
[^30]: gastownhall/beads PR_MAINTAINER_GUIDELINES.md: https://github.com/gastownhall/beads/blob/main/PR_MAINTAINER_GUIDELINES.md
[^31]: oven-sh/bun CLAUDE.md: https://github.com/oven-sh/bun/blob/main/CLAUDE.md
[^32]: anthropics/claude-code 이슈 #79146: https://github.com/anthropics/claude-code/issues/79146
[^33]: anthropics/claude-code 이슈 #98160: https://github.com/anthropics/claude-code/issues/98160
[^34]: vercel/ai 라벨 목록. 라벨별 항목 수를 GitHub API로 집계(2026-10-10): https://github.com/vercel/ai/labels
[^35]: openai/codex PR #49713: https://github.com/openai/codex/pull/49713
[^36]: 바이브 코딩을 넘어서 소프트웨어 팩토리로: https://roboco.io/posts/beyond-vibe-coding-software-factory/
[^37]: withastro/factory README: https://github.com/withastro/factory
[^38]: StrongDM, Software Factory: https://factory.strongdm.ai/

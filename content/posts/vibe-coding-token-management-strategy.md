---
title: "바이브 코딩의 토큰 관리 전략"
date: 2026-03-19T09:00:00+09:00
draft: false
toc: false
images:
tags:
  - vibe-coding
  - claude-code
  - codex
  - gemini
  - context-engineering
---

> 토큰 부족은 모델 성능의 문제가 아니라, 대개 컨텍스트 운영 방식의 문제다.

{{< figure src="/posts/images/Dohyun.png" title="정도현 - 로보코 수석 컨설턴트" style=".author-image">}}

---

Claude Code, Codex, Gemini 같은 바이브 코딩 도구를 오래 쓰다 보면 어느 순간부터 비슷한 증상이 나타난다. 응답이 느려지고, 이미 합의한 제약을 잊어버리고, 관련 없는 파일까지 건드리기 시작한다. 흔히 이를 "토큰이 부족하다"고 표현하지만, 실제 현상은 조금 더 정확히 말해 **컨텍스트 오염** 혹은 **Context Rot**에 가깝다.

Perplexity를 통해 정리한 ideation 메모를 다시 읽어보면 핵심은 분명하다. 실제 사용 환경에서 토큰 사용량의 대부분은 출력보다 **입력 컨텍스트**에서 발생하며, 따라서 문제를 푸는 가장 좋은 방법도 "더 큰 모델"이 아니라 "더 깨끗한 컨텍스트"다. 이 글에서는 그 내용을 바탕으로, 도구별 기능 소개가 아니라 **실무 운영 전략** 중심으로 토큰 관리 원칙을 정리해 보려 한다.

## 왜 토큰이 먼저 바닥나는가

긴 세션이 계속 누적되면 문제는 두 층위에서 나타난다. 하나는 순수한 토큰 한도 도달이고, 다른 하나는 그보다 먼저 오는 품질 저하다. 대화 로그, 실패한 시도, 임시 가설, 긴 빌드 로그, 이미 끝난 작업의 맥락이 계속 남아 있으면 모델은 지금 중요한 정보와 이미 폐기된 정보를 구분하기 어려워진다.

이 현상은 단순히 컨텍스트 창 크기로 해결되지 않는다. 긴 컨텍스트는 더 많은 정보를 담을 수 있게 해주지만, 그 안의 정보가 잘 정리되어 있다는 보장은 해주지 않기 때문이다. 그래서 토큰 관리의 핵심은 절약 자체보다 **선별**에 있다.

## 전략 1: 세션을 오래 끌지 말고 `/clear`, `/compact`를 의식적으로 써라

Claude Code를 기준으로 보면 가장 즉효성이 높은 방법은 `/clear`와 `/compact`를 전략적으로 쓰는 것이다.[^1][^2]

- `/clear`는 작업 맥락을 완전히 초기화할 때 쓴다.
- `/compact`는 중요한 내용만 남기고 대화 이력을 요약할 때 쓴다.
- 긴 디버깅 세션 직후, 기능 하나를 마쳤을 때, 혹은 컨텍스트 사용량이 70% 수준에 도달했을 때 compact를 거는 습관이 효과적이다.[^2]

핵심은 긴 대화를 계속 유지하는 것이 생산적이라는 착각에서 벗어나는 것이다. 세션은 길게 이어가는 것보다, **짧게 끊고 재시작할 수 있어야** 한다.

## 전략 2: handoff 문서를 남기고 새 세션으로 넘어가라

세션을 자주 끊으려면 재개 비용이 낮아야 한다. 이때 가장 단순하고 강력한 방식이 `HANDOFF.md` 같은 짧은 인계 문서를 두는 것이다.[^3]

예를 들면 아래 정도면 충분하다.

```text
목표: 로그인 플로우 race condition 해결
수정한 파일: auth_service.ts, login_controller.ts
확인한 사실: DB 문제가 아니라 중복 API 호출 문제
실패한 시도: mutex 적용은 부작용으로 롤백
다음 작업: idempotency key 방식 검토
완료 조건: 중복 로그인 재현 테스트 통과
```

이 문서의 목적은 장문의 기록 보존이 아니다. 다음 세션이 **즉시 일할 수 있을 정도의 방향성**만 남기는 것이다.

## 전략 3: 반복되는 설명은 `CLAUDE.md`로 빼고, 계층적으로 관리하라

매 세션마다 프로젝트 구조와 스타일 가이드, 금지 규칙, 테스트 방식까지 다시 설명하는 팀이 많다. 이건 장기적으로 가장 비싼 토큰 낭비다. ideation 문서에서도 `CLAUDE.md`를 전역, 프로젝트, 모듈 단위로 레이어링하는 패턴을 권장하고 있다.[^4]

```text
~/
└── CLAUDE.md
project/
├── CLAUDE.md
├── backend/CLAUDE.md
└── frontend/CLAUDE.md
```

이 구조의 장점은 분명하다. 항상 필요한 규칙은 상위에 두고, 특정 도메인에만 필요한 정보는 하위 모듈 파일에 둔다. 그러면 모든 세션이 같은 무거운 규칙 파일을 통째로 들고 다닐 필요가 없다.

특히 `CLAUDE.md`에는 아래 항목이 유용하다.[^4][^5]

- 핵심 기술 스택과 아키텍처
- 코딩 컨벤션
- 현재 스프린트 목표와 블로커
- compact 시 반드시 남겨야 할 정보
- 자세한 문서로 넘어가는 `Load on Demand` 링크

즉, 좋은 `CLAUDE.md`는 모든 것을 다 담는 문서가 아니라, **무엇을 바로 읽고 무엇은 나중에 읽을지 결정해주는 인덱스**에 가깝다.

## 전략 4: `.claudeignore`로 애초에 읽지 말아야 할 것을 차단하라

실측 기준으로 가장 ROI가 높은 단일 조치는 `.claudeignore` 설정이다. ideation 문서에 인용된 사례들에서는 `node_modules`, 빌드 산출물, 로그, 바이너리, 대용량 이미지, lock 파일을 제외하는 것만으로도 **30~40% 수준의 절감 효과**가 보고된다.[^6][^7]

예를 들면 이런 식이다.

```text
node_modules/
.next/
dist/
build/
coverage/
.cache/
*.log
*.db
*.sqlite
.env*
*.png
*.jpg
*.gif
*.mp4
```

이 전략의 본질은 절약이 아니다. 모델이 애초에 봐도 도움이 안 되는 정보를 보지 않게 막는 것이다. 특히 lock 파일이나 빌드 산출물은 토큰을 많이 먹지만 추론 가치가 거의 없다.

## 전략 5: `tasks.md`를 하나로 몰아넣지 말고, 인덱스 구조로 쪼개라

ideation 문서에서 가장 인상적인 사례 중 하나는 단일 대형 `tasks.md`를 도메인별 문서와 `INDEX.md` 구조로 나누어 **76.1% 절감**을 달성한 케이스다.[^8]

```text
tasks/
├── INDEX.md
├── backend.md
├── frontend.md
├── infra.md
├── security.md
└── archive/
```

이 구조가 좋은 이유는 간단하다. 모든 작업에서 모든 태스크를 읽을 필요가 없기 때문이다. 일반 현황은 `INDEX.md`만 보면 되고, 특정 작업은 해당 도메인 파일만 읽으면 된다. 완료된 이력은 `archive/`로 치워 두면 현재 세션의 작업대에서 사라진다.

토큰 관리란 결국 문서 정보 아키텍처의 문제이기도 하다.

## 전략 6: Plan mode를 먼저 거치고 구현은 나중에 하라

큰 작업을 곧바로 실행 모드로 던지면, 모델은 탐색과 설계와 구현을 같은 비용 센터 안에서 한꺼번에 처리한다. 이 방식은 시행착오가 많고 토큰도 많이 든다. ideation에서는 Plan mode를 먼저 거쳐 범위를 줄인 뒤 구현으로 들어가는 습관이 **20~30% 절감**에 기여한다고 정리하고 있다.[^7]

이 원칙은 아주 단순하다.

1. 먼저 관련 파일과 영향 범위를 찾는다.
2. 수정 후보 파일과 접근 방식을 짧게 계획한다.
3. 계획에서 불필요한 범위를 잘라낸다.
4. 그 뒤에만 구현한다.

즉, 토큰 절약은 프롬프트를 짧게 쓰는 기술보다 **불필요한 시행착오를 사전에 제거하는 설계 습관**에 더 가깝다.

## 전략 7: 큰 로그와 검색 작업은 서브에이전트나 별도 세션으로 격리하라

웹 검색, 긴 로그 분석, 빌드 출력 검토, 광범위한 코드 탐색은 결과물이 길다. 이런 작업을 메인 세션에서 직접 처리하면 컨텍스트가 빠르게 오염된다. ideation에서도 이런 고노이즈 작업은 서브에이전트에 위임하고, **결과 요약만 메인 컨텍스트로 돌려받는 방식**을 권장한다.[^9]

이 패턴은 Claude Code뿐 아니라 Codex나 Gemini CLI에도 그대로 적용된다. 중요한 것은 어떤 도구를 쓰느냐보다, **노이즈가 많은 작업과 결정이 필요한 작업을 같은 세션에 섞지 않는 것**이다.

## 전략 8: 검색 기반 컨텍스트 주입을 기본값으로 삼아라

대형 코드베이스에서 전체 파일을 그대로 읽히는 방식은 오래 가지 못한다. ideation 문서에는 함수나 심볼 단위 의존성 그래프를 만들어 필요한 조각만 제공하는 고급 패턴도 소개되어 있는데, 이런 방식은 실측 기준 **80% 이상 절감**이 가능하다는 사례까지 나온다.[^10]

물론 모든 팀이 곧바로 MCP 서버나 의존성 그래프를 만들 필요는 없다. 하지만 원칙은 지금 당장 적용할 수 있다.

- 먼저 검색한다.
- 관련 파일과 심볼만 추린다.
- 그 조각만 컨텍스트에 넣는다.

즉, 전체 저장소를 덤프하는 대신 **검색 후 주입**을 기본값으로 삼아야 한다.

## 전략 9: MCP 서버도 켜놓기만 하면 비용이다

MCP는 강력하지만, 활성화된 서버와 도구가 많을수록 컨텍스트와 시스템 지시문이 불어난다. ideation 문서가 지적하듯, 현재 작업과 무관한 MCP를 상시 켜 두는 것은 첫 프롬프트 전부터 예산을 잡아먹는 방식이다.[^11]

따라서 MCP 전략도 "많이 연결"이 아니라 "필요할 때만 연결"이 맞다. 장기적으로는 이 역시 Progressive Disclosure의 일부다.

## 전략 10: 도구별로 역할을 분리하라

ideation은 Claude Code, Codex, Gemini를 각각 다른 특성으로 정리한다.[^12][^13][^14]

- Claude Code는 복잡한 추론과 디버깅에 강하지만, 세션 관리가 중요하다.
- Gemini CLI는 긴 컨텍스트 분석에 유리하지만 `.geminiignore` 같은 제외 전략이 필수다.
- Codex는 비교적 큰 컨텍스트를 다루지만, 결국 compaction과 범위 관리 원칙에서 자유롭지 않다.

이 말은 곧, 모든 도구를 하나의 방식으로 쓰지 말라는 뜻이다. 코드베이스 전체 맵핑은 긴 컨텍스트 도구에 맡기고, 실제 수정은 짧고 집중된 세션으로 넘기는 식의 **역할 분리**가 비용과 품질 모두에 유리하다.

## 안티패턴

반대로 다음 패턴들은 거의 항상 토큰 부채를 만든다.

- "전체 프로젝트를 보고 알아서 해줘" 같은 넓은 요청
- 한 세션에 탐색, 구현, 디버깅, 회고를 모두 누적하는 방식
- 대형 `tasks.md`나 거대한 규칙 파일을 항상 통째로 로드하는 구조
- build 로그, diff, 검색 결과를 압축 없이 그대로 붙여넣는 습관
- 현재 작업과 무관한 MCP 서버와 도구를 상시 활성화하는 설정
- 큰 컨텍스트 창이 있으니 정리하지 않아도 된다고 믿는 태도

긴 컨텍스트는 쓰레기를 더 많이 담을 수 있게 해줄 뿐, 중요한 정보를 더 잘 고르게 해주지는 않는다.

## 현실적인 적용 우선순위

ideation 메모의 제안은 합리적이다. 투자 대비 효과 기준으로 보면 보통 아래 순서가 맞다.

1. `.claudeignore` 또는 동등한 ignore 파일부터 잡는다.
2. `tasks.md`와 작업 문서를 인덱스 구조로 쪼갠다.
3. Plan mode와 handoff 문서를 습관화한다.
4. `CLAUDE.md`를 슬림하게 재구성하고 온디맨드 링크 구조로 바꾼다.
5. 그 다음에야 검색 기반 컨텍스트 서빙이나 MCP 최적화를 고려한다.

즉, 대부분의 팀은 고급 인프라보다 먼저 **문서 구조와 세션 습관**만 바꿔도 큰 차이를 체감할 수 있다.

## 결론

바이브 코딩의 토큰 관리 전략은 결국 한 문장으로 요약된다. **모델에게 많은 것을 보여주지 말고, 지금 필요한 것만 정확히 보여줘라.** 세션을 짧게 유지하고, 반복되는 설명은 문서로 외부화하고, 큰 태스크는 인덱스와 계획 단계로 쪼개고, 노이즈가 많은 작업은 별도 세션으로 격리해야 한다.

토큰을 아끼는 팀이 생산성이 높은 이유는 돈을 적게 써서가 아니다. 모델이 헷갈릴 여지를 줄였기 때문이다. 좋은 바이브 코더는 긴 프롬프트를 쓰는 사람이 아니라, **컨텍스트를 설계하는 사람**이다.

[^1]: Best Practices for Claude Code, Anthropic Docs: https://code.claude.com/docs/en/best-practices
[^2]: Managing Claude Code context to reduce limits: https://mcpcat.io/guides/managing-claude-code-context/
[^3]: 45 Claude Code Tips From basics to advanced: https://github.com/ykdojo/claude-code-tips
[^4]: The Complete Guide to Claude Code Context: https://supatest.ai/blog/claude-context-management-guide
[^5]: Claude Code 컨텍스트 최적화 가이드 - 인포그랩: https://insight.infograb.net/blog/2026/01/14/claudecode-context/
[^6]: 7 Ways to Cut Your Claude Code Token Usage: https://dev.to/boucle2026/7-ways-to-cut-your-claude-code-token-usage-elb
[^7]: How I Reduced Claude Code Token Consumption by 50%: https://32blog.com/en/claude-code/claude-code-token-cost-reduction-50-percent
[^8]: CLAUDE-CODE의 토큰을 절약하기 - tasks.md의 문서 구조 개편: https://developer-youn.tistory.com/196
[^9]: How to Use Claude Code: A Guide to Slash Commands: https://www.producttalk.org/how-to-use-claude-code-features/
[^10]: I cut Claude Code's token usage by 65% by building a ... https://www.reddit.com/r/ClaudeAI/comments/1rby0gt/i_cut_claude_codes_token_usage_by_65_by_building/
[^11]: Tips after using Claude Code daily: context management ... https://www.reddit.com/r/ClaudeCode/comments/1pawyud/tips_after_using_claude_code_daily_context/
[^12]: Best practices for cost-efficient, high-quality context management in long AI chats: https://community.openai.com/t/best-practices-for-cost-efficient-high-quality-context-management-in-long-ai-chats/1373996
[^13]: How to Leverage Gemini CLI's 1M Token Context Window: https://inventivehq.com/knowledge-base/gemini/how-to-leverage-1m-token-context
[^14]: What Is the Token Limit for Codex Requests?: https://apidog.com/blog/token-limit-for-codex-requests/

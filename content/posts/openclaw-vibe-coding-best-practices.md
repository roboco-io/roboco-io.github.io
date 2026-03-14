---
title: "OpenClaw: 세계 최대 바이브 코딩 프로젝트에서 배우는 9가지 모범 사례"
date: 2026-03-14T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - vibe-coding
  - agentic-dev
  - openclaw
  - best-practices
---

> "예전에 팀을 이끈 적이 있다. 내 아래에 많은 소프트웨어 엔지니어가 있었다. 그때도 내가 원하는 방식과 완전히 똑같은 코드를 그들이 쓰지는 않는다는 점을 받아들여야 했다." – Peter Steinberger[^3]

{{< figure src="/posts/images/Dohyun.png" title="정도현 - 로보코 수석 컨설턴트" style=".author-image">}}

---

OpenClaw는 GitHub에서 가장 많은 스타를 받은 소프트웨어 저장소(31만+ 스타)이자, 대규모 AI 보조 "바이브 코딩"의 결정적 사례 연구다.[^1] 오스트리아 개발자 Peter Steinberger가 3~8개의 병렬 AI 에이전트 인스턴스를 활용해 구축한 이 프로젝트는[^2], 단 한 명의 개발자가 30만+ LOC 규모의 TypeScript 모노레포, 20개 이상의 메시징 통합, 세 플랫폼용 네이티브 앱을 오케스트레이션할 수 있음을 보여준다. 그것도 대부분의 코드를 직접 읽지 않고서 말이다.[^3]

이 프로젝트의 이름은 격동의 과정을 거쳤다. 2025년 11월 Anthropic의 Claude를 기반으로 한 시간 만에 만든 프로토타입 **Clawdbot**이 시작이었다. 2026년 1월 GitHub 공개 후 하루 만에 9,000 스타를 받으며 폭발적으로 성장했지만, Anthropic의 상표권 경고로 **Moltbot**으로 개명해야 했다. 이어 사칭 계정과 악성 npm 패키지 등 보안 사고가 터지면서 불과 3일 만에 다시 **OpenClaw**로 이름을 바꿨다.[^16] 2026년 2월, Steinberger는 OpenAI에 합류해 "차세대 개인 에이전트"를 이끌게 되었고, OpenClaw는 OpenAI가 지원하는 독립 재단으로 이관되었다.[^17]

아이러니하게도 Steinberger 본인은 "vibe coding"이라는 표현을 비하적 표현이라고 부르며 "agentic engineering"을 선호하지만[^5], OpenClaw는 이 흐름의 대표 프로젝트가 되었다.[^6] 이 글에서는 OpenClaw의 저장소 구조, 워크플로, 커뮤니티 운영 방식을 분석하고, 여기서 뽑아낸 실천 가능한 모범 사례를 정리한다.

---

## 1. OpenClaw는 실제로 무엇을 하는가

OpenClaw는 **셀프 호스팅 개인 AI 어시스턴트**로, 메시징 플랫폼을 대형 언어 모델과 연결해 준다. ChatGPT나 Claude의 웹 인터페이스와 달리, OpenClaw는 사용자의 로컬 머신에서 실행되며 사용자가 이미 머무는 채널과 연결된다. WhatsApp, Telegram, Discord, Slack, Signal, iMessage, Microsoft Teams, Matrix, LINE 등 15개 이상의 채널을 지원한다. README는 이를 간단히 이렇게 설명한다. *"당신의 기기에서 직접 실행하는 개인 AI 어시스턴트."*[^7]

아키텍처의 핵심은 로컬 **Gateway 데몬**이다. 이는 18789 포트에서 동작하는 WebSocket 기반 컨트롤 플레인으로, 들어오는 메시지를 각각 독립된 AI 에이전트로 라우팅한다. 각 에이전트는 자신만의 워크스페이스, 메모리, 그리고 Markdown 파일(`SOUL.md`, `MEMORY.md`, `USER.md`)로 정의된 개성을 가진다.[^8] 에이전트는 단순히 대화만 하는 것이 아니다. 셸 명령 실행, CDP를 통한 브라우저 제어, 일정 관리, cron 작업 실행, 하트비트 시스템을 통한 능동적 연락까지 수행한다.[^9] **ClawHub**라는 스킬 마켓플레이스에는 1,700개 이상의 커뮤니티 제작 확장이 올라와 있다.[^10]

기술 스택은 TypeScript 기반 **pnpm 모노레포**(Node.js 22 이상)이며, Swift(macOS/iOS)와 Kotlin(Android)으로 작성된 네이티브 컴패니언 앱을 포함한다. 테스트는 Vitest와 V8 커버리지 기준 70% 이상으로 운영된다.[^4]

---

## 2. 저장소에서 드러나는 AI 보조 개발의 흔적

바이브 코딩의 가장 분명한 증거는 커밋 히스토리에 있다. 초기에는 Anthropic의 Claude Code로 개발되었기 때문에 커밋에 **"claude"가 공동 작성자(co-author)** 로 자주 등장한다. 그러나 Steinberger가 2026년 2월 OpenAI에 합류한 이후로는 `codex/issue-issue-41258-20260312044119` 같은 **OpenAI Codex 에이전트가 자율 생성한 브랜치**가 눈에 띄게 늘어났다. 저장소 하나에 Claude와 Codex, 두 AI 코딩 에이전트의 흔적이 공존하는 셈이다. README는 아예 이렇게 명시한다. **"AI/vibe-coded PRs welcome!"**[^7]

Steinberger 개인의 워크플로는 특히 인상적이다. 그는 **Codex CLI 인스턴스 3~8개를 3x3 터미널 그리드에서 동시에 실행**하며, 대부분은 별도 워크트리가 아니라 같은 폴더에서 작업한다.[^2] 각 에이전트는 `AGENTS.md` 규칙의 안내를 받아 원자적 커밋을 만든다. 그는 **2026년 1월 한 달에만 6,600개 이상의 커밋**을 남겼는데, 겉보기에는 20명 규모 팀의 속도지만 실제로는 한 사람과 AI 에이전트들의 조합이다.[^3] 프롬프트는 시간이 갈수록 더 짧아져서, 지금은 보통 1~2문장과 스크린샷 하나면 충분하며 스크린샷이 입력의 약 50%를 차지한다.[^11]

`CONTRIBUTING.md`는 커뮤니티가 AI 보조 PR을 어떻게 다뤄야 하는지 규범화한다.[^12]

- PR 제목 또는 설명에 AI 사용 여부를 표시할 것
- 테스트 수준을 명시할 것(미테스트 / 가볍게 테스트 / 충분히 테스트)
- 가능하면 프롬프트 또는 세션 로그를 포함할 것
- 생성된 코드가 무엇을 하는지 이해하고 있음을 확인할 것

문서는 이렇게 마무리된다. *"여기서 AI PR은 1급 시민으로 대우한다. 다만 리뷰어가 어디를 중점적으로 봐야 하는지 알 수 있도록 투명성을 원할 뿐이다."*[^12]

---

## 3. AGENTS.md와 CLAUDE.md 설정 패턴

OpenClaw 저장소에서 가장 재현 가능성이 높은 혁신은 **`AGENTS.md` 파일**이다.[^4] 이는 코드베이스에서 작업하는 모든 AI 코딩 에이전트를 위한 포괄적 지침 문서다. `CLAUDE.md`는 동일 파일을 가리키는 심볼릭 링크이며, Claude Code와 Codex 계열 에이전트가 동일한 지침을 읽도록 보장한다. 규칙도 명확하다. *"저장소 어디든 새 `AGENTS.md`를 추가할 때는, 반드시 이를 가리키는 `CLAUDE.md` 심볼릭 링크도 함께 추가하라."*[^4]

이 파일은 AI 에이전트를 위한 조직 기억 장치로 동작한다. Steinberger는 이를 **"조직의 상처가 축적된 흔적(organizational scar tissue)의 모음"** 이라고 표현하는데, 무언가 잘못될 때마다 Codex 자체가 점진적으로 내용을 추가해 왔기 때문이다.[^11] 핵심 섹션은 다음과 같다.

- **빌드 및 테스트 명령어**: `pnpm build`, `pnpm check`, `pnpm test`, 빠른 타입 체크용 `pnpm tsgo`처럼 정확히 명시
- **Git 규칙**: `fix(telegram):`, `feat(skills):` 같은 서브시스템 스코프 포함 Conventional Commits 강제, push 전 `git pull --rebase` 요구
- **멀티 에이전트 안전 규칙**: git stash를 생성/적용/삭제하지 말 것, 요청받지 않으면 브랜치를 바꾸지 말 것, 인식하지 못한 변경을 발견하면 다른 에이전트가 작업 중이라고 가정하고 계속 진행할 것
- **체인지로그 규칙**: 사용자에게 의미 있는 항목만 섹션 끝에 추가, 외부 기여자 표기는 `Thanks @author` 패턴
- **보안 경계**: 실제 전화번호, 운영 환경 설정값, 동영상 파일 커밋 금지

더 넓은 커뮤니티 차원에서는 **자동 코드 리뷰가 필수**다. GitHub Codex 리뷰가 자동으로 실행되지 않으면, 기여자는 로컬에서 `codex review --base origin/main`을 실행하고 그 결과를 필수 리뷰 작업으로 처리해야 한다.[^12]

---

## 4. 대규모 운영에서의 PR 패턴과 자동화

OpenClaw는 대략 **하루 14개의 신규 PR**을 처리하며, 임의 시점 기준으로 5,500개+의 오픈 PR과 19,000개+의 종료 PR이 존재한다.[^13] 이 정도 볼륨은 강한 자동화를 요구한다. 저장소에는 총 **58개의 라벨**이 있으며, 컴포넌트(`agents`, `cli`, `gateway`, `docker`), 채널(`channel: telegram`, `channel: discord`, `channel: whatsapp-web`), 유형(`docs`, `enhancement`, `bug`)별로 나뉜다.[^8]

리뷰 프로세스에는 여러 봇이 참여한다. **openclaw-barnacle** 봇은 자동 라벨링과 자동 응답을 담당하고, **Greptile-apps**는 자동 코드 분석을, **aisle-research-bot**은 리뷰 코멘트를 남긴다. `.github/workflows/auto-response.yml` 워크플로는 특정 패턴과 일치하는 이슈(TestFlight 요청, 서드파티 확장 제안, 스팸 등)를 자동으로 닫고 잠근다.[^13]

`VISION.md`는 강한 제한을 둔다. **하나의 PR은 하나의 이슈/주제만 다룰 것**, 관련 없는 수정은 묶지 말 것, 그리고 대략 5,000줄 이상 바뀌는 PR은 예외적인 경우에만 리뷰한다.[^14] CI 파이프라인에는 메인 테스트 스위트, 설치 스모크 테스트, 워크플로 건전성 검사, 자동 라벨러가 포함되며, 커버리지 기준은 **라인, 브랜치, 함수, 구문 모두 70% 이상**을 요구한다.[^4]

---

## 5. 바이브 코딩 워크플로에서 뽑은 9가지 모범 사례

OpenClaw의 공식 **Vibe Coding 스킬**(ClawHub 1,700+ 스타)은 이 방법론을 규칙화된 형태로 정리해 둔다.[^15] 여기에 Steinberger의 공개된 워크플로와 저장소의 실제 관행을 결합하면, 가장 실천적인 패턴은 다음과 같다.

### 5.1 살아 있는 `AGENTS.md` 파일을 유지하라

가장 영향력이 큰 실천이다. 점진적으로 작성하라. AI 에이전트가 실수할 때마다 규칙을 추가하면 된다. 도구 호환성을 위해 `CLAUDE.md`로 심볼릭 링크를 걸어라. Steinberger의 파일은 약 300줄 길이로, git 규약, 테스트 명령, 아키텍처 패턴, 파일 길이 제한(약 500 LOC), 멀티 에이전트 조율 규칙까지 담고 있다. 이는 구전 지식을 기계가 읽을 수 있는 제도적 기억으로 바꾼다.[^4][^11]

### 5.2 Research → Plan → Implement 워크플로를 사용하라

구현 전에 AI가 기존 코드를 먼저 탐색하게 하라. 예를 들어 "auth 모듈을 읽고 세션이 어떻게 동작하는지 설명해"라고 시킨다. 그다음 계획을 제안하게 하라. "수정할 파일과 각 파일에서 바뀔 내용을 적어"라고 시킨다. 계획을 검토한 뒤에만 구현으로 넘어간다. *"계획 단계에서 오해를 잡아내는 비용은, 연쇄 오류를 디버깅하는 것보다 10배 저렴하다."*[^15]

### 5.3 서브시스템 스코프가 포함된 Conventional Commits를 강제하라

`type(scope): description` 패턴, 예를 들면 `fix(telegram): resolve TypeError in status command` 같은 형식은 AI 에이전트가 이해할 수 있고 자동 체인지로그 생성도 가능한, 기계 해석 가능한 히스토리를 만든다. 커미터 헬퍼 스크립트를 사용해 스테이징이 의도한 파일에만 한정되도록 하라.[^4]

### 5.4 AI 에이전트를 관리 대상인 주니어 엔지니어처럼 다뤄라

Steinberger의 핵심 비유다. 인간의 노력은 **시스템 아키텍처**와 **취향**에 집중해야 한다. 즉, 작동하는 해법과 우아한 해법을 구분하는 능력이다. 구현, 보일러플레이트, 리팩터링은 에이전트에게 맡겨라.[^3]

### 5.5 명시적 조율 규칙과 함께 병렬 에이전트를 운영하라

여러 에이전트는 같은 폴더에서도 동시에 작업할 수 있다. 단, `AGENTS.md`에 다음이 명확히 적혀 있어야 한다. 수정 전에 `git status`와 `git diff`를 확인할 것, 원자적 커밋을 만들 것, stash를 건드리거나 브랜치를 바꾸지 말 것, 이해되지 않는 변경을 보더라도 다른 에이전트의 작업으로 간주하고 계속 진행할 것. 이렇게 해야 "바이브 코딩"이 1인 플레이가 아니라 멀티플레이 오케스트레이션 문제로 바뀐다.[^4][^2]

### 5.6 AI PR을 투명성이 보장된 1급 시민으로 취급하라

기여자에게 AI 도구 사용 여부 공개, 테스트 수준 명시, 프롬프트나 세션 로그 첨부, 생성된 코드에 대한 이해 확인을 요구하라. 이는 진입 장벽을 세우는 행위가 아니다. 리뷰어가 미묘한 AI 생성 버그가 숨어 있을 가능성이 높은 부분에 집중하도록 필요한 맥락을 제공하는 일이다.[^12]

### 5.7 취향이 필요 없는 것은 전부 자동화하라

OpenClaw는 자동 라벨링, 자동 응답 워크플로, 자동 코드 리뷰 봇, stale 이슈 관리, 시크릿 탐지, 데드 코드 분석, 중복 검사까지 사용한다. 인간의 역할은 아키텍처와 품질 판단이다. 그 외는 자동화하거나 에이전트에 위임해야 한다.[^13]

### 5.8 언제 개입하고 언제 흐름에 맡길지 구분하라

스캐폴딩, UI 컴포넌트, 보일러플레이트, 탐색 작업은 AI에 맡겨라. 반면 **인증, 결제, 데이터 처리, 데이터베이스 스키마, API 권한, 보안과 맞닿은 모든 것**은 수동 개입이 필요하다. 그리고 모든 변경 뒤에는 반드시 테스트하라. AI는 "겉보기에 완벽하지만 미묘한 버그가 있는" 코드를 만들어낸다.[^15]

### 5.9 프롬프트에 제약 조건을 고정(anchor)하라

명시적 경계를 주어라. 줄 수 제한("50줄 이하"), 출력 형식 제한("파일 전체가 아니라 수정된 함수만"), 범위 고정("결제 플로만, auth는 건드리지 말 것"), 스타일 지시("`UserService.ts`의 기존 패턴을 따를 것") 같은 제약이다. 모호한 프롬프트는 모호한 결과를 만든다.[^15]

---

## 결론

OpenClaw 저장소는 프로덕션 규모의 바이브 코딩이 엔지니어링 규율을 버리는 일이 아니라, 그것을 **재배치하는 일**임을 보여준다. 이 프로젝트의 1,200명+ 기여자, 19,000개+ 머지된 PR, 18,000개+ 커밋은 대규모 소프트웨어 프로젝트를 가능하게 하는 바로 그 원칙들로 운영된다. 명확한 규약, 자동화된 강제, 구조화된 커뮤니케이션, 명시적 경계가 그것이다.

혁신은 *누가 실행하느냐* 에 있다. AI 에이전트는 구현을 담당하고, 인간은 아키텍처, 취향, 조율을 맡는다. **"조직의 상처가 축적된 흔적"** 을 쌓아 올리는 살아 있는 점진적 지침 파일이라는 `AGENTS.md(CLAUDE.md)` 패턴은[^11], 가장 쉽게 이전 가능한 실천 방식이다.

Steinberger가 상세한 명세(2025년 6월)에서, 스크린샷 중심의 짧은 프롬프트(2025년 후반)로, 다시 최소한의 감독으로 3~8개 병렬 에이전트를 굴리는 단계(2026년)로 이동한 궤적은 모든 바이브 코더가 따라가게 될 학습 곡선을 보여준다.[^2] 교훈은 코드가 중요하지 않다는 것이 아니다. 소프트웨어 엔지니어링의 무게중심이 이동했다는 것이다. 코드를 직접 쓰는 숙련에서, 코드를 쓰는 시스템을 설계하는 숙련으로. 300줄의 `AGENTS.md`를 축적하고, 70% 커버리지 기준선을 세우고, 멀티 에이전트 충돌 규칙을 설계하는 일은 벽돌을 쌓는 일이 아니라 건축을 하는 일이다. 그리고 그 건축 역시 쉽게 얻어지지 않는 숙련을 요구한다.

---

[^1]: GitHub Repository — openclaw/openclaw: https://github.com/openclaw/openclaw
[^2]: Peter Steinberger, "Shipping at Inference-Speed": https://steipete.me/posts/2025/shipping-at-inference-speed
[^3]: The Pragmatic Engineer, "The creator of Clawd: I ship code I don't read": https://newsletter.pragmaticengineer.com/p/the-creator-of-clawd-i-ship-code
[^4]: AGENTS.md (AI agent guide): https://github.com/openclaw/openclaw/blob/main/AGENTS.md
[^5]: TechSpot, "OpenClaw creator says vibe coding is a slur against AI-assisted development": https://www.techspot.com/news/111468-openclaw-creator-vibe-coding-slur-against-ai-assisted.html
[^6]: Fortune, "Who is OpenClaw creator Peter Steinberger?": https://fortune.com/2026/02/19/openclaw-who-is-peter-steinberger-openai-sam-altman-anthropic-moltbook/
[^7]: README.md: https://github.com/openclaw/openclaw/blob/main/README.md
[^8]: DeepWiki architecture analysis — openclaw/openclaw: https://deepwiki.com/openclaw/openclaw/8-channels
[^9]: OpenClaw official documentation: https://docs.openclaw.ai
[^10]: Milvus Blog, "What Is OpenClaw? Complete Guide to the Open-Source AI Agent": https://milvus.io/blog/openclaw-formerly-clawdbot-moltbot-explained-a-complete-guide-to-the-autonomous-ai-agent.md
[^11]: Peter Steinberger, "Just Talk To It — the no-bs Way of Agentic Engineering": https://steipete.me/posts/just-talk-to-it
[^12]: CONTRIBUTING.md: https://github.com/openclaw/openclaw/blob/main/CONTRIBUTING.md
[^13]: Pull Requests — openclaw/openclaw: https://github.com/openclaw/openclaw/pulls
[^14]: VISION.md: https://github.com/openclaw/openclaw/blob/main/VISION.md
[^15]: OpenClaw official Vibe Coding skill (ClawHub): https://playbooks.com/skills/openclaw/skills/vibe-coding
[^16]: TechCrunch, "OpenClaw creator Peter Steinberger joins OpenAI": https://techcrunch.com/2026/02/15/openclaw-creator-peter-steinberger-joins-openai/
[^17]: Peter Steinberger, "OpenClaw, OpenAI and the future": https://steipete.me/posts/2026/openclaw

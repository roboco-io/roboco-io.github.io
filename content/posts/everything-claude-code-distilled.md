---
title: "Everything Claude Code - 해커톤 우승자의 AI 개발 팀 레시피"
date: 2026-01-20T09:30:07+09:00
draft: false
toc: false
images:
tags:
  - claude-code
  - vibe-coding
  - agentic-dev
---

> “AI를 팀으로 받아들이려면, 도구보다 프로세스를 먼저 설계해야 한다.” – Anthropic x Forum Ventures 해커톤 우승자 Affaan Mustafa

{{< figure src="/posts/images/Dohyun.png" title="정도현 - 로보코 수석 컨설턴트" style=".author-image">}}

---

Everything Claude Code는 Claude Code CLI를 **가상 개발 팀 환경**으로 변모시키는 설정 모음집이다. 해커톤 우승자가 10개월 동안 실제 스타트업 제품을 만들며 다듬은 레시피가 공개 저장소 한 곳에 모였고, 이를 적용하면 Claude를 “시니어 엔지니어 + QA + 아키텍트”로 호출할 수 있다.[^tilnote] 리포지토리는 GitHub에서 누구나 확인할 수 있다.

**[Everything Claude Code](https://github.com/affaan-m/everything-claude-code)**

이 글은 레포지토리 구조, Claude API 활용 방식, 기술 스택, 그리고 해커톤 우승으로 이어진 차별성을 한눈에 정리한 기술 리포트다. 마지막에는 현재 한계와 개선 아이디어도 덧붙였다.

---

## 1. 프로젝트 개요

Everything Claude Code는 “Claude를 다역할 에이전트 팀으로 운영하라”는 명확한 철학으로 설계됐다.[^tilnote] 메인 세션이 프로젝트 매니저 역할을 맡고, 세부 작업은 다양한 서브 에이전트가 병렬로 수행한다. 작성자는 이 구성으로 2025년 9월 Anthropic x Forum Ventures 해커톤에서 **zenith.chat**을 완전히 Claude Code만으로 개발해 우승했다는 실전 사례도 공유했다.[^github]

핵심 가치 제안은 세 가지다.

1. **역할 분리**: 역할별 프롬프트, 툴 권한, 톤을 분리해 LLM 집중도를 높인다.
2. **프로세스 표준화**: `/plan`, `/tdd`, `/code-review` 같은 슬래시 명령으로 개발 루틴을 자동화한다.
3. **품질 가드레일**: 규칙·스킬·훅을 조합해 보안, 테스트, 스타일을 강제한다.

이 철학을 토대로 저장소 전체는 “AI가 프로젝트 히스토리를 학습하고 도구를 직접 실행하는” 완성형 개발 파이프라인을 구성한다.

---

## 2. 저장소 구조와 아키텍처

레포지토리는 Claude Code에 필요한 맥락을 역할별 폴더로 분리해 관리한다. 실제 사용자는 필요한 파일을 자신의 `~/.claude` 혹은 프로젝트 루트의 `.claude`로 복사해 활성화한다.

### 2.1 Agents

`agents/`는 역할 특화 프롬프트 모음이다. `planner`, `architect`, `code-reviewer`, `security-reviewer`, `tdd-guide`, `build-error-resolver`, `e2e-runner`, `refactor-cleaner`, `doc-updater` 등이 대표적이다.[^github] 각 파일은 YAML 프런트매터로 모델(`opus`), 허용 툴(`Read`, `Grep`, `Bash` 등), 설명을 정의하고, 본문에는 역할별 지침을 담는다. **툴을 최소화**해 집중도를 높이고, 에이전트 간 역할 충돌을 막는 것이 설계의 핵심 관점이다.

### 2.2 Skills

`skills/`는 팀이 공유하는 업무 매뉴얼이다. `coding-standards.md`, `backend-patterns.md`, `frontend-patterns.md`, `security-review/`, `tdd-workflow/` 등이 포함된다.[^github] 특히 `tdd-workflow`는 RED→GREEN→REFACTOR 루프와 커버리지 80% 요구사항을 상세히 명시해 Claude가 테스트 주도 개발을 자동으로 상기하도록 만든다. 스킬은 전사 공통(`~/.claude/skills`)과 프로젝트 전용(`.claude/skills`)으로 분리해 운영할 수 있다.

### 2.3 Commands

`commands/`에는 `/plan`, `/tdd`, `/e2e`, `/code-review`, `/build-fix`, `/refactor-clean`, `/test-coverage`, `/update-docs` 등 슬래시 명령 프롬프트가 있다.[^github] 사용자는 대화창에서 명령만 입력하면, 해당 절차에 맞춘 프롬프트가 로딩되고 필요한 스킬·에이전트가 호출된다. 덕분에 “기능 계획 → TDD 실행 → 코드 리뷰 → 문서 동기화” 같은 일련의 개발 플로우를 버튼처럼 실행할 수 있다.

### 2.4 Rules

`rules/`는 항상 적용되는 가드레일이다. `security.md`, `coding-style.md`, `testing.md`, `git-workflow.md`, `agents.md`, `performance.md`, `patterns.md`, `hooks.md` 등으로 모듈화돼 있으며 Claude Code는 이 폴더의 모든 규칙을 시스템 프롬프트에 자동 삽입한다. 예를 들어 `testing.md`는 “커버리지 80% 미만 PR 금지” 규칙을 명시해 모델이 테스트 생략을 허용하지 않도록 한다.

### 2.5 Hooks

`hooks/hooks.json`은 Pre/Post ToolUse 지점에서 실행할 자동화 스크립트를 정의한다. 예시는 TypeScript 파일 편집 후 `console.log`가 남아있으면 경고하는 훅, 세션 종료 전 포맷터를 돌리는 훅 등이다.[^github] Hook matcher로 툴 이름·파일 패턴을 지정하고, Bash 명령이나 추가 명령을 실행하도록 구성한다. 반복적인 실수(디버깅 코드 방치, 테스트 누락 등)를 자동 감시하는 안전망 역할을 한다.

### 2.6 MCP 설정

`mcp-configs/`는 GitHub, Supabase, Vercel, Railway, ClickHouse 등 다수의 MCP 서버 설정 템플릿을 제공한다.[^tilnote] 사용자들은 필요한 항목을 `~/.claude/settings.json`에 붙여 넣고 API 키를 채우면 Claude가 직접 해당 서비스 API를 호출할 수 있다. README는 “활성 MCP는 프로젝트당 10개 이하, 전체 툴은 80개 이하”라는 가이드도 제공한다. 지나친 MCP 활성화는 컨텍스트 창을 잠식해 모델 성능을 떨어뜨리기 때문이다.

### 2.7 Plugins & Examples

`plugins/`는 Claude Skills Marketplace와 외부 플러그인 설치법을 안내하는 문서 집합이다. `examples/` 폴더에는 프로젝트 수준(`CLAUDE.md`)과 사용자 수준(`user-CLAUDE.md`) 설정 예시, 커스텀 `statusline.json` 등이 포함돼 있어 신규 사용자가 그대로 복사해 시작할 수 있다. 결과적으로 저장소 전체가 “레퍼런스 구현 + 템플릿” 역할을 겸한다.

---

## 3. Claude API 활용 원칙

Everything Claude Code가 강조하는 AI 활용 원칙은 다음 네 가지로 요약된다.

1. **멀티 에이전트 병렬화**  
   메인 세션이 큰 방향을 잡고 세부 작업은 서브 에이전트가 위임받아 수행한다. 각 에이전트는 자신의 도메인 맥락만 다루므로 응답 품질과 속도가 안정적으로 유지된다.[^tilnote]

2. **TDD·테스트 퍼스트**  
   `/tdd` 명령과 `tdd-workflow` 스킬을 통해 RED→GREEN→REFACTOR 사이클을 강제하고, `testing.md` 규칙으로 커버리지 80% 이상을 요구한다. Claude는 기능 요청을 받으면 테스트 추가 필요성을 항상 상기시킨다.

3. **보안·품질 가드레일**  
   `security.md`는 비밀키 하드코딩 금지, 입력 검증, 에러 처리, 취약 라이브러리 검사 등을 명문화한다. `/code-review` 명령과 `code-reviewer` 에이전트는 AI가 작성한 코드도 다시 AI가 리뷰하도록 만들어 자기 정제 루프를 형성한다.

4. **컨텍스트 예산 관리**  
   MCP·규칙·스킬·도구가 많을수록 시스템 프롬프트가 비대해지므로, README는 “필요한 설정만 활성화할 것”을 반복 강조한다.[^github] 프로젝트별 최소 구성으로 집중력을 유지하는 것이 Claude 활용 효율을 결정한다.

이 원칙 때문에 Claude Code는 단순한 코드 자동완성 도구가 아니라, **프롬프트 엔지니어링 + 워크플로 엔진**으로 기능한다.

---

## 4. 사용 기술 스택과 도구 체인

Everything Claude Code 자체는 Markdown·JSON 기반 설정집이지만, 그 배경에는 다음과 같은 스택이 깔려 있다.

- **Anthropic Claude Code CLI**: 시스템 프롬프트를 조합하고 LLM과 툴 호출을 중개하는 런타임. 최신 Opus/Sonnet 모델을 지원한다.
- **MCP 서버 묶음**: GitHub, Supabase, Vercel, Railway, ClickHouse 등 주요 SaaS용 MCP 템플릿을 제공해 Claude가 직접 API를 호출할 수 있게 한다.[^tilnote]
- **테스트 & 품질 도구**: `/e2e` 커맨드는 Playwright 실행을 전제로 설계돼 있고, `testing.md`는 Jest/Vitest 등 JS 테스팅 스택을 내재화하고 있다. `/build-fix`는 Node/Vite 빌드 오류를 다루도록 짜여 있다.
- **프론트엔드/백엔드 패턴**: `frontend-patterns.md`에는 React/Next.js 지침, `backend-patterns.md`에는 API·DB·캐싱 베스트 프랙티스가 정리되어 있다. `clickhouse-io.md`처럼 특정 데이터 기술에 대한 스킬도 존재한다.

즉, 저장소는 “언어/프레임워크-중립”을 표방하지만 첫 번째 타깃은 **TypeScript 기반 풀스택 웹 제품**이다. 다른 언어나 도메인에 쓰려면 추가 스킬을 작성해야 한다.

---

## 5. 해커톤 우승으로 이어진 차별성

해커톤에서 Everything Claude Code가 발휘한 경쟁력은 다섯 가지로 정리할 수 있다.

1. **역할 병렬화**: 설계·구현·테스트를 서로 다른 에이전트가 동시에 처리해 개발 병목을 줄였다.
2. **표준화된 개발 루틴**: `/plan → /tdd → /code-review → /update-docs` 순서가 자동화돼 기능별 사이클이 짧고 일정했다.
3. **풀스택 자동화**: MCP 덕분에 Claude가 GitHub 이슈, Supabase 쿼리, Vercel 배포 등을 직접 수행해 사람은 제품 로직에만 집중했다.[^medium]
4. **훅 기반 안전장치**: console.log 제거, 테스트 누락 경고 같은 훅이 실수를 초기에 잡아 품질을 유지했다.
5. **전투 검증된 노하우**: 작성자가 실무에서 반복 검증한 프롬프트/규칙을 담았기에 ‘한 번 써본 통찰’이 아니라 ‘다듬어진 프레임워크’였다.

이 조합 덕분에 짧은 시간에도 높은 품질을 유지하는 “AI 주도 팀”이 구현됐고, 그것이 해커톤에서 차별화 요소로 작동했다.

---

## 6. 기술적 한계와 개선 방향

아무리 완성도가 높아도 여전히 해결할 과제는 존재한다.

1. **컨텍스트 창 한계**  
   MCP·규칙·스킬을 과도하게 켜면 Claude의 사용 가능 토큰이 줄어들어 장기 세션에서 맥락 손실이 발생한다. 동적 컨텍스트 로딩이나 필요 시점별 설정 교체 기능이 향후 보완 포인트다.

2. **모델 비용과 가용성**  
   Opus 모델은 느리고 비용이 높다. 사용량이 많을수록 부담이 커지므로, Sonnet이나 타 모델로의 자동 폴백 전략이 필요하다. Anthropic 외 모델을 꽂을 수 있는 추상화 레이어도 고민할 만하다.

3. **온보딩 난도**  
   에이전트·스킬·훅 개념을 모두 이해해야 하기에 초기 학습 곡선이 높다. 대화형 설정 마법사나 GUI 기반 설정 관리가 있다면 도입 장벽을 낮출 수 있다.

4. **도메인 편중**  
   현재 스킬은 JS/TS 웹 서비스에 최적화돼 있다. 임베디드, 데이터 과학, 모바일 등 다른 도메인용 스킬/명령을 커뮤니티가 계속 추가해야 범용 프레임워크가 된다.

5. **실행 안전성**  
   Bash 권한이 주어진 에이전트가 잘못된 명령을 실행할 리스크는 여전히 존재한다. 명령 2단계 승인, 샌드박스 모드, `/dry-run` 명령 같은 보호 장치가 향후 필요한 이유다.

6. **성능 최적화**  
   모든 작업을 AI가 설명하며 실행하면 속도가 느려질 수 있다. 응답 캐싱이나 에이전트 간 결과 공유 같은 최적화가 없으면 “빠르게 코딩” 경험과 거리가 생긴다.

---

## 7. 맺음말

Everything Claude Code는 단순한 설정 파일 모음이 아니라 **AI와 함께 일하는 방식을 설계한 운영체제**에 가깝다. 역할 단위 프롬프트, 테스트 중심 규칙, 훅 기반 자동화, MCP 연동이 결합하면서 “AI를 어떻게 팀원으로 쓸 것인가”라는 질문에 구체적인 답을 제시한다. 동시에, 컨텍스트 관리·온보딩·도메인 확장 같은 과제도 분명하다. 이 레포지토리를 자신의 프로젝트에 이식하면서 조직의 프로세스와 도메인 지식을 덧입히는 순간, AI는 더 이상 보조 도구가 아니라 **지속 가능한 개발 파트너**가 된다.

---

## 참고 자료

- Affaan Mustafa, *Everything Claude Code Repository* (GitHub) – https://github.com/affaan-m/everything-claude-code
- Tilnote, *Everything Claude Code 정리* – https://tilnote.io/en/pages/696db2d265a2e4dd63f35cc7
- JP Caparas, *The Claude Code setup that won a hackathon* – https://jpcaparas.medium.com/the-claude-code-setup-that-won-a-hackathon-a75a161cd41c
- MCP Servers Catalog – https://mcpservers.org/servers/asifdotpy/github-mcp-server-asifdotpy
- Tatsuya Takasaka, *Zenn: Anthropic 해커톤 우승자의 Claude Code 설정 해설* – https://zenn.dev/ttks/articles/a54c7520f827be

[^tilnote]: https://tilnote.io/en/pages/696db2d265a2e4dd63f35cc7
[^github]: https://github.com/affaan-m/everything-claude-code
[^medium]: https://jpcaparas.medium.com/the-claude-code-setup-that-won-a-hackathon-a75a161cd41c

---
source: content/ko/products.md
generated_at: 2026-10-16T00:00:00+09:00
window: 전체 공개 리포지토리 (2026-10-16 조회)
candidates_considered: 59
candidates_selected: 5
---

# products.md 업데이트 초안 (2026-10-16)

> 이 파일은 초안이다. content/ko/products.md 원본은 수정하지 않았다. 반영 시 en/ja 번역도 함께 동기화해야 한다.

## A. 신규 H2 풀 제품 블록

> `## **token-forge**` 블록 다음, `## **오픈소스 도구와 리소스**` 앞에 추가하는 안이다. 소프트웨어 팩토리 블록은 로보코의 핵심 서비스와 직결되므로 맨 위(`## **Intent Engineering**` 앞)로 올리는 안도 검토할 수 있다.

## **The Software Factory**

> *의도를 정책과 실행계획으로, 결과를 증거로, 피드백을 개선으로.* — 소프트웨어 팩토리와 AI 시대의 조직 설계.

『The Software Factory — 소프트웨어 팩토리와 AI 시대의 조직 설계』는 소프트웨어 조직 리더를 위한 한국어 책입니다. 의도를 정책과 실행계획으로 구체화하고, 수행 결과를 증거로 검증하며, 피드백으로 정책과 계획을 개선하는 개발 접근법을 패턴 언어로 설명합니다. 현재 공개 초안으로 웹에서 읽을 수 있으며, GitHub 이슈로 의견을 받습니다.

함께 공개한 **The Software Factory Demo**는 이 접근법의 구현 예제입니다. 사람이 원하는 변화를 글로 요청하면 AI가 구현하고 검증한 뒤 실제 서비스(RealWorld 예제 블로그)에 반영하는 과정을 누구나 관찰할 수 있습니다. 반복되는 실패를 바탕으로 팩토리의 작업 규칙을 고치는 자가 개선의 개념 검증도 함께 수행합니다.

### 이런 분에게 유용합니다

- AI 시대에 개발 조직의 역할과 프로세스를 다시 설계하려는 리더
- 소프트웨어 팩토리가 실제로 어떻게 동작하는지 직접 보고 싶은 분
- 요청·검증·배포·자가 개선이 연결된 구현 사례를 참고하려는 팀

### 링크

- 책 읽기: [factory.roboco.io](https://factory.roboco.io)
- 데모 서비스: [roboco.io/the-software-factory-demo](https://roboco.io/the-software-factory-demo/) · [팩토리 대시보드](https://roboco.io/the-software-factory-demo/factory/)
- GitHub: [roboco-io/the-software-factory](https://github.com/roboco-io/the-software-factory) · [roboco-io/the-software-factory-demo](https://github.com/roboco-io/the-software-factory-demo)

---

## **Vibe Up**

> *Shape Up for the Vibe-Coding Era.* — 구현 비용이 0에 수렴해도 병목은 사라지지 않고 이동합니다.

Vibe Up은 Basecamp의 Shape Up(Ryan Singer)을 바이브 코딩 시대에 맞춰 재구성한 가이드입니다. 구현 비용이 급격히 낮아진 뒤 새로 생긴 병목인 검증·리뷰, 주의력·집중, 복잡도 부채를 짚습니다. 이어서 애피타이트와 셰이핑이라는 원작의 원리가 예산 단위만 바꿔 유지되는 과정을 설명하고, [VDLC](https://vdlc.roboco.io)의 주간 사이클(4일 빌드 + 1일 쿨다운)로 연결합니다. 한국어·영어·일본어로 제공합니다.

### 이런 분에게 유용합니다

- Shape Up을 운영해 왔지만 AI 도입 후 사이클과 베팅 기준이 맞지 않게 된 팀
- 바이브 코딩 환경에서 기획(셰이핑)과 검증의 역할을 다시 정의하려는 리더

### 링크

- 사이트: [vibeup.roboco.io](https://vibeup.roboco.io/ko/)
- GitHub: [roboco-io/vibeup](https://github.com/roboco-io/vibeup)

---

## **AI Doc Ready**

> *사람과 AI가 함께 읽기 쉬운 보고서로.* — Markdown·HWPX 보고서 구조 검사 도구.

AI Doc Ready(`aidocready`)는 Markdown과 HWPX 보고서가 AI 친화적 작성 원칙을 따르는지 검사하는 CLI입니다. 행정안전부의 AI 친화적 보고서 도입 발표에서 제시한 원칙(표·그림 상단 제목, 단순한 셀 병합, 서술식 문장 등)을 실제 문서 작성 과정에 적용하는 데서 출발했습니다. 구조 검사는 재현 가능한 코드로 수행하고, 문장의 명확성과 의미 보존은 원문 대조와 수동 검토로 확인하도록 역할을 나눕니다. HWPX 파싱은 오픈소스 라이브러리 Kordoc을 사용합니다.

### 이런 분에게 유용합니다

- 공공기관 또는 공공 사업 보고서를 HWPX로 작성하는 분
- AI가 보고서를 정확히 읽고 요약하도록 문서 구조를 정비하려는 팀

### 링크

- 제품 페이지: [roboco.io/aidocready](https://roboco.io/aidocready/)
- 실행: `npx aidocready lint report.hwpx`
- GitHub: [roboco-io/aidocready](https://github.com/roboco-io/aidocready)

---

## B. 신규 H3 오픈소스 도구 블록

> `## **오픈소스 도구와 리소스**` 섹션 안, `### **plugins**` 다음에 추가하는 안이다(claude-wiki는 plugins 마켓플레이스로 설치되므로 인접 배치).

### **claude-wiki**

Claude Code로 코드베이스의 에이전트 친화적 위키를 생성하고 유지하는 도구. 위키 생성 로직은 Claude Code 플러그인으로 동작하므로, 별도 API 키 없이 기존 Claude 구독 안에서 실행됩니다. 터미널과 CI에서는 얇은 CLI 래퍼(`claude-wiki`)로 같은 로직을 실행합니다.

- GitHub: [roboco-io/claude-wiki](https://github.com/roboco-io/claude-wiki)

### **DORA AI Guide**

DORA(dora.dev)의 AI 관련 리서치를 한국어와 일본어로 요약한 비공식 학습 가이드. 4대 리포트, AI Capabilities Model의 7대 역량, 12편의 인사이트를 정리해 AI 도입 효과를 근거로 논의할 때 참고할 수 있습니다.

- 사이트: [roboco.io/dora-ai-guide](https://roboco.io/dora-ai-guide/)
- GitHub: [roboco-io/dora-ai-guide](https://github.com/roboco-io/dora-ai-guide)

---

## C. 본문 보강 패치 제안

**변경 전** (도입 문단 2번째 문단)

> 이 페이지에서는 실무에 활용할 도구와 방법론을 소개합니다. 연구·실험의 질문과 결과는 [Research](/research/)에서 확인할 수 있습니다.

**변경 후**

> 이 페이지에서는 실무에 활용할 도구와 방법론을 소개합니다. 연구·실험의 질문과 결과는 [Research](/research/)에서, 강의·워크숍 자료는 [Education](/education/)에서 확인할 수 있습니다.

(Education 페이지를 신설하는 경우에만 적용한다. `education-page-2026-10-16.md` 참고.)

---

## D. 부록 — 스캔 메타데이터

- 조회일: 2026-10-16, `gh repo list roboco-io --limit 200`
- 전체 90개 중 공개 59개, 비공개 31개(비공개는 대상 외)
- 사용자 선택: claude-wiki, aidocready, the-software-factory(+demo), vibeup, dora-ai-guide
- 사용자가 선택에서 제외: vmux, task-master-viewer, ralph-mem
- 분류 근거: aidocready·vibeup·the-software-factory는 자체 사이트가 있어 H2, claude-wiki·dora-ai-guide는 H3
- 자동 제외: 포크 6개, 아카이브 1개(handson-vibecoding-demo), 사이트 저장소(roboco-io.github.io, .github), 이미 반영된 리포지토리

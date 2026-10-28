# AGENTS.md

Codex와 Claude Code가 이 저장소에서 공유하는 작업 규칙입니다.

## 프로젝트 개요

ROBOCO.IO 기업 웹사이트. Hugo 기반의 정적 사이트이며 GitHub Pages로 배포됩니다. 한국어 콘텐츠 중심( AI/클라우드 컨설팅, 바이브 코딩 ).

## 공통 설정과 도구별 연결

- 공통 스킬·참고 문서·리뷰 지침·훅 스크립트는 `.agents/`에서만 관리한다. `.claude/skills/<이름>`과 `.claude/hooks/`의 호환 경로는 공통 원본을 가리키는 상대 심볼릭 링크다. 수정할 때는 링크 대상인 `.agents/` 파일을 편집한다.
- `CLAUDE.md`는 `@AGENTS.md`로 이 문서를 불러오는 Claude Code 연결 파일이다. `.claude/settings.json`에는 Claude 전용 훅 등록과 스킬 호출 설정만 둔다. Codex가 이 JSON이나 Claude 훅을 자동 실행한다고 가정하지 않는다.
- 공통 스킬의 AskUserQuestion은 Claude Code에서는 같은 이름의 도구, Codex에서는 `request_user_input_async`를 뜻한다. 사용자 답변이 필요한 단계는 답변을 기다리며, 독립 작업은 계속할 수 있다. 도구가 없거나 해당 용도로 사용할 수 없으면 이유를 밝히고 텍스트로 질문한다.
- 파일 읽기·검색·편집·웹 조사에는 현재 실행 환경이 제공하는 대응 도구를 사용한다. Claude 전용 도구 이름이나 `$ARGUMENTS`를 Codex의 필수 API로 취급하지 않는다.
- 서브에이전트는 Claude Code의 Agent 도구 또는 Codex의 `collaboration.spawn_agent`를 사용한다. 모델 지정은 각 스킬의 환경별 지침을 따른다.

## 다국어 콘텐츠 (ko/en/ja)

- 한국어 `content/ko/`가 원본이다. 한국어 URL은 루트를 유지하며 영어는 `/en/`, 일본어는 `/ja/`를 사용한다.
- 한국어 콘텐츠를 작성·수정하면 [translate-content](.agents/skills/translate-content/SKILL.md)에 따라 영어·일본어도 동기화한다. 원문 작성·수정 작업에서는 사용자의 원문 확인을 먼저 받는다. 번역 보류·한국어만 작성 등 사용자의 언어 범위 지시가 우선한다. 완성된 원문에 대한 직접 번역 요청에는 확인을 반복하지 않는다.
- Claude의 편집 후 훅은 동기화 확인을 상기시킨다. Codex는 훅에 의존하지 말고 작업 완료 전에 변경한 한국어 콘텐츠와 번역 상태를 직접 확인한다. 확인 대기 중이면 번역을 임의로 시작하지 말고 대기 상태를 보고한다.
- 이미지는 `static/posts/images/`에 보관하고 `/posts/images/...`로 참조한다. 사진·로고·텍스트 없는 삽화는 공유한다. 설명 문구가 있는 이미지·다이어그램은 번역 필요성을 확인해 언어별 자산을 만들고 해당 번역 페이지에서 사용한다. 상세 기준은 `.agents/skills/translate-content/references/visual-localization.md`를 따른다.
- 모든 언어에서 ROBOCO는 라틴 문자로 유지한다. 일본어는 です・ます調를 사용한다. 상세 규칙은 [공통 번역 규칙](.agents/skills/translate-content/references/translation-rules.md)을 따른다.

## 주요 명령어

```bash
# 최초 설정 (서브모듈 포함)
git submodule update --init --recursive

# 로컬 개발 서버 (draft 포함)
hugo server -D

# 새 블로그 글 생성
hugo new posts/my-post.md

# 사이트 빌드 (./public 출력)
hugo -D

# SVG 소스로부터 파비콘 생성
./scripts/generate_favicons.sh
```

## 아키텍처

- 정적 사이트 생성기: Hugo v0.143.1
- 테마: hello-friend-ng (themes/ 서브모듈)
- 호스팅: GitHub Pages (GitHub Actions)
- 설정: `hugo.yaml`

### 핵심 디렉터리

- `content/ko/posts/` - 한국어 블로그 원문
- `content/en/`, `content/ja/` - 영어·일본어 번역
- `content/ko/` - 한국어 정적 페이지 (about.md, solutions.md, products.md, contact.md)
- `static/posts/images/` - 모든 언어가 공유하는 이미지
- `layouts/` - 테마 오버라이드 템플릿
- `assets/css/extended.css` - 커스텀 CSS
- `static/favicon/` - 파비콘 리소스

### 템플릿 커스터마이징

테마 오버라이드는 `layouts/`에 위치합니다.

- `layouts/index.html` - 커스텀 홈
- `layouts/partials/home/logo.html` - 로고 컴포넌트
- `layouts/partials/extra-head.html` - 추가 head 콘텐츠

## 콘텐츠 규칙

### 포스트 프론트매터 예시

```yaml
---
title: "제목"
date: 2025-01-01T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - tag1
  - tag2
---
```

## 배포

`main` 브랜치에 push 시 GitHub Actions로 자동 배포됩니다. 트리거 경로는 다음과 같습니다.

- `content/`
- `layouts/`
- `static/`
- `assets/`
- `hugo.yaml`
- `config.yaml`

## 콘텐츠 업데이트 시 필수 마케팅 에이전트 리뷰

- 고객에게 공개되는 콘텐츠를 작성·수정하면, 완료 보고 전에 **작성자와 별도의 에이전트**로 마케터 관점 리뷰를 실행합니다. 사용자가 매번 요청할 필요는 없습니다.
- 범위: `content/`의 모든 언어, 고객용 문구·구성을 바꾸는 `layouts/`, SEO·메뉴·CTA 문구, 브로셔 등 공개 자료. 콘텐츠에 영향이 없는 코드·스타일·설정 변경은 제외합니다.
- Claude Code에서는 Agent 도구, Codex에서는 `collaboration.spawn_agent`로 리뷰 에이전트를 생성합니다. [마케팅 리뷰 지침](.agents/reviewers/marketing.md)을 읽게 하고 변경 파일, 작업 목표, 관련 도착 페이지를 전달합니다. 이는 해당 리뷰를 위한 에이전트 위임 지시입니다.
- 에이전트는 읽기 전용으로 검토합니다. 주 작업자는 지적을 검토하고 타당한 항목을 수정합니다. 높은 중요도 지적을 수정했다면 해당 항목을 같은 에이전트에 재검토 요청합니다.
- 성과 수치, 고객 정보, 비용, 기간, 무료 상담 등의 약속을 임의로 만들지 않습니다. 근거가 필요한 내용은 검증하거나 표현을 낮추고, 사용자 판단이 꼭 필요한 경우에만 질문합니다.
- 수정 후 Hugo 빌드와 변경한 링크·CTA를 확인합니다. 최종 보고에 에이전트 리뷰 수행 여부와 남은 중요 지적을 짧게 적습니다.
- 에이전트 도구를 사용할 수 없으면 그 제한을 알리고 자체 검토 결과를 별도로 표시합니다. 자체 검토를 독립 에이전트 리뷰라고 보고하지 않습니다.

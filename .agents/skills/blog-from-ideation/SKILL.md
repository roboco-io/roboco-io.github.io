---
name: blog-from-ideation
description: ideation 문서(초안, 메모, URL)를 받아 팩트 체크와 리서치를 거쳐 ROBOCO.IO Hugo 블로그 포스트로 변환한다. "블로그 작성", "포스트 생성", "ideation을 글로" 같은 요청에 사용한다.
argument-hint: [ideation-file-path 또는 주제]
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(gh *), Bash(hugo *), WebFetch, WebSearch, AskUserQuestion
---

# Ideation → 블로그 포스트 생성

ideation 문서를 받아 5단계 워크플로로 블로그 포스트를 생성한다.

## 입력

- `$ARGUMENTS` — ideation 파일 경로, URL, 또는 주제 키워드
- 인자가 없으면 AskUserQuestion으로 주제를 물어본다

## 블로그 컨벤션

이 프로젝트의 기존 포스트 패턴을 반드시 따른다. 자세한 규칙은 [reference.md](reference.md) 참고.

## 워크플로

### 1단계: Ideation 분석

- ideation 문서를 읽고 핵심 주제, 주장, 참조 자료를 추출한다
- 글의 목적(기술 분석, 비교, 가이드, 의견)과 대상 독자를 파악한다
- 빠진 맥락이나 모호한 부분이 있으면 AskUserQuestion으로 확인한다

### 2단계: 리서치 & 팩트 체크

- ideation에 언급된 주장, 수치, 인용을 원문 소스와 교차 검증한다
  - GitHub 저장소: `gh api` 명령으로 스타 수, 기여자 수, 파일 내용 등 확인
  - 웹 소스: WebFetch 또는 WebSearch로 원문 확인
- 검증 결과를 표로 정리해 사용자에게 보여준다 (주장 | 실제 | 판정)
- 추가 리서치가 필요한 맥락이 있으면 조사 후 반영 여부를 AskUserQuestion으로 묻는다

### 3단계: 초안 작성

- `content/posts/` 에 포스트 파일을 생성한다
- [reference.md](reference.md)의 frontmatter, 저자 표기, 문체 규칙을 따른다
- 각주(`[^N]`)는 1번부터 빠짐없이 연속 번호를 사용한다

### 4단계: 셀프 리뷰

작성된 초안에 대해 자동 점검 후 문제를 수정한다:

- 팩트 정확성: 2단계 검증 결과가 빠짐없이 반영되었는가
- 각주 연속성: 번호가 1부터 빠짐없이 연속되는가
- 인용 정확성: 원문 번역이 자연스럽고 의미가 왜곡되지 않았는가
- 문체 일관성: 논문체나 번역체가 섞이지 않았는가
- 구조 완결성: 도입-본문-결론 흐름이 자연스러운가

### 5단계: 사용자 리뷰

- 완성된 포스트의 핵심 구조와 주요 판단을 요약해 보여준다
- AskUserQuestion으로 수정 필요 여부를 확인한다
- Hugo 로컬 프리뷰를 제안한다: `hugo server -D`

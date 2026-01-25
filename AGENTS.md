# AGENTS.md

Codex가 이 저장소에서 작업할 때 참고할 규칙입니다.

## 프로젝트 개요

ROBOCO.IO 기업 웹사이트. Hugo 기반의 정적 사이트이며 GitHub Pages로 배포됩니다. 한국어 콘텐츠 중심( AI/클라우드 컨설팅, 바이브 코딩 ).

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

- `content/posts/` - 블로그 포스트
- `content/` - 정적 페이지 (about.md, solutions.md, contact.md)
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

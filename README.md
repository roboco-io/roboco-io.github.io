# RoboCo.IO 웹사이트

[RoboCo.IO](https://roboco-io.github.io)의 공식 웹사이트 저장소입니다.

## 프로젝트 개요

- **프로젝트명**: RoboCo.IO 웹사이트
- **목적**: AI·클라우드 솔루션 및 교육 서비스 소개
- **웹사이트**: [https://roboco-io.github.io](https://roboco-io.github.io)
- **기술 스택**: Hugo, GitHub Pages

## 기술 스택

- **정적 사이트 생성기**: Hugo v0.143.1
- **테마**: PaperMod
- **호스팅**: GitHub Pages
- **CI/CD**: GitHub Actions

## 로컬 개발 환경 설정

1. Hugo 설치
```bash
brew install hugo
```

2. 저장소 클론
```bash
git clone https://github.com/roboco-io/roboco-io.github.io.git
cd roboco-io.github.io
```

3. 로컬 서버 실행
```bash
hugo server -D
```

## 디렉토리 구조

```
.
├── archetypes/     # 컨텐츠 템플릿
├── assets/         # CSS, JS, 이미지 등 에셋
├── content/        # 마크다운 컨텐츠
├── layouts/        # 레이아웃 템플릿
├── static/         # 정적 파일
└── hugo.yaml       # Hugo 설정 파일
```

## 컨텐츠 작성 가이드

1. 새 포스트 생성
```bash
hugo new posts/my-post.md
```

2. 프론트매터 작성
```yaml
---
title: "제목"
date: YYYY-MM-DD
draft: false
tags: ["태그1", "태그2"]
categories: ["카테고리"]
---
```

3. 마크다운으로 컨텐츠 작성

## 배포

- `main` 브랜치에 푸시하면 GitHub Actions를 통해 자동으로 배포됩니다.
- 배포는 다음 파일들이 변경되었을 때만 실행됩니다:
  - `content/**`
  - `layouts/**`
  - `static/**`
  - `assets/**`
  - `hugo.yaml`
  - `config.yaml`

## 라이선스

Copyright 2025 RoboCo.IO. All rights reserved.

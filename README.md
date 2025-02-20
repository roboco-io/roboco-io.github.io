# RoboCo.IO 웹사이트

[![Deploy Hugo site to Pages](https://github.com/roboco-io/roboco-io.github.io/actions/workflows/hugo.yml/badge.svg)](https://github.com/roboco-io/roboco-io.github.io/actions/workflows/hugo.yml)

[ROBOCO.IO](https://roboco-io.github.io)의 공식 웹사이트 저장소입니다.

## 프로젝트 개요

- **프로젝트명**: ROBOCO.IO 웹사이트
- **목적**: AI·클라우드 솔루션 및 교육 서비스 소개
- **웹사이트**: [https://roboco-io.github.io](https://roboco-io.github.io)
- **기술 스택**: Hugo, GitHub Pages

## 기술 스택

- **정적 사이트 생성기**: Hugo v0.143.1
- **테마**: [Hello Friend NG](https://github.com/rhazdon/hugo-theme-hello-friend-ng)
- **호스팅**: GitHub Pages
- **CI/CD**: GitHub Actions

## 로컬 개발 환경 설정

1. Hugo 설치
```bash
brew install hugo
```

2. 저장소 클론 및 서브모듈 초기화
```bash
git clone https://github.com/roboco-io/roboco-io.github.io.git
cd roboco-io.github.io
git submodule update --init --recursive
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
│   ├── posts/      # 블로그 포스트
│   ├── solutions/  # 솔루션 소개
│   ├── about/      # 회사 소개
│   └── contact/    # 문의하기
├── layouts/        # 레이아웃 템플릿
├── static/         # 정적 파일
├── themes/         # Hugo 테마
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

## 파비콘 생성 가이드

SVG 파일에서 여러 크기의 파비콘을 생성하려면 다음 단계를 따르세요:

1. librsvg 설치 (이미 설치되어 있다면 생략)
```bash
brew install librsvg
```

2. SVG 파일로부터 여러 크기의 PNG 파일 생성
```bash
cd static/images
# SVG 파비콘 복사
cp roboco-icon.svg ../favicon/favicon.svg

# 투명 배경으로 PNG 파비콘 생성
rsvg-convert -h 16 -b none roboco-icon.svg > ../favicon/favicon-16x16.png
rsvg-convert -h 32 -b none roboco-icon.svg > ../favicon/favicon-32x32.png
rsvg-convert -h 96 -b none roboco-icon.svg > ../favicon/favicon-96x96.png
rsvg-convert -h 180 -b none roboco-icon.svg > ../favicon/apple-touch-icon.png
rsvg-convert -h 192 -b none roboco-icon.svg > ../favicon/android-chrome-192x192.png
rsvg-convert -h 512 -b none roboco-icon.svg > ../favicon/android-chrome-512x512.png

# ICO 파일 생성 (16x16, 32x32, 96x96 크기 포함)
cd ../favicon
magick convert favicon-16x16.png favicon-32x32.png favicon-96x96.png favicon.ico
```

생성된 파비콘 파일들의 용도:
- `favicon.svg`: 벡터 기반의 파비콘 (모던 브라우저 지원)
- `favicon.ico`: 다중 크기 아이콘 (16x16, 32x32, 96x96)을 포함한 레거시 브라우저용 파비콘
- `favicon-16x16.png`, `favicon-32x32.png`, `favicon-96x96.png`: 브라우저 탭과 북마크 아이콘
- `apple-touch-icon.png`: iOS 홈 화면 아이콘
- `android-chrome-192x192.png`, `android-chrome-512x512.png`: Android 홈 화면 아이콘

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

Copyright 2025 ROBOCO.IO. All rights reserved.

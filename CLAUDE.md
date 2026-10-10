# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ROBOCO.IO corporate website - a Hugo-based static site deployed to GitHub Pages. Korean language content focused on AI/cloud consulting services and vibe coding topics.

## Multilingual Content (ko/en/ja)

- 한국어(`content/ko/`)가 원본. 영어는 `content/en/`(/en/), 일본어는 `content/ja/`(/ja/). 한국어 URL은 루트를 유지한다.
- **한국어 콘텐츠를 생성·수정하면 반드시 en/ja 번역도 같은 작업에서 동기화한다.** 절차와 규칙은 `translate-content` 스킬(`.claude/skills/translate-content/`)을 따른다. `content/ko/**/*.md` 편집 시 PostToolUse 훅이 자동으로 이를 상기시킨다.
- 이미지(`static/posts/images/`)는 3개 언어 공용이며 `/posts/images/...` 경로 그대로 참조한다. (content/ 아래 두면 Hugo 0.146+에서 참조되지 않은 번들 리소스로 간주되어 게시되지 않음)
- 브랜드 표기: 모든 언어에서 ROBOCO는 라틴 문자 유지(ロボコ 금지).

## Commands

```bash
# First-time setup (theme is a git submodule)
git submodule update --init --recursive
```

## Content Conventions

### Post Frontmatter

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

### Deployment

Auto-deploys via GitHub Actions when pushing to `main` branch. Only triggers on changes to: `content/`, `layouts/`, `static/`, `assets/`, `hugo.yaml`, `config.yaml`.

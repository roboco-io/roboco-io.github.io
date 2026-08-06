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
# First-time setup (clone with submodules)
git submodule update --init --recursive

# Local development server (includes drafts)
hugo server -D

# Create new blog post
hugo new posts/my-post.md

# Build site (output to ./public)
hugo -D

# Generate favicons from SVG source
./scripts/generate_favicons.sh
```

## Architecture

- **Static Site Generator**: Hugo v0.143.1
- **Theme**: hello-friend-ng (as git submodule in `themes/`)
- **Hosting**: GitHub Pages via GitHub Actions
- **Config**: `hugo.yaml` (site settings, menu, theme params)

### Key Directories

- `content/posts/` - Blog posts in markdown
- `content/` - Static pages (about.md, solutions.md, contact.md)
- `layouts/` - Custom template overrides (index.html, partials/)
- `assets/css/extended.css` - Custom CSS extending theme
- `static/favicon/` - Favicon assets (source SVG and generated PNGs)

### Template Customization

Theme overrides are placed in `layouts/` to customize the hello-friend-ng theme:
- `layouts/index.html` - Custom homepage
- `layouts/partials/home/logo.html` - Logo component
- `layouts/partials/extra-head.html` - Additional head content

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

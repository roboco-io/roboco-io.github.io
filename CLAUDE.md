# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ROBOCO.IO corporate website - a Hugo-based static site deployed to GitHub Pages. Korean language content focused on AI/cloud consulting services and vibe coding topics.

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

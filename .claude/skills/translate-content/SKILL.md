---
name: translate-content
description: 한국어 콘텐츠(content/ko/)를 영어(content/en/)·일본어(content/ja/)로 번역·동기화. 한국어 포스트/페이지를 새로 쓰거나 수정한 뒤, 또는 "번역", "translate", "다국어 동기화", "en/ja 업데이트" 요청 시 사용. i18n 훅이 번역 갱신을 상기시킬 때도 이 스킬을 따른다.
---

# 한국어 → 영어/일본어 콘텐츠 번역·동기화

이 사이트는 ko(루트 URL)/en(/en/)/ja(/ja/) 3개 언어를 제공한다. **한국어(content/ko/)가 원본**이며, en/ja는 항상 ko를 따라간다.

## 절차

1. **대상 파악**: 인자로 파일이 지정되지 않았으면 `git status`/`git diff --name-only`로 변경·신규된 `content/ko/**/*.md`를 찾는다. 각 대상의 `content/en/`, `content/ja/` 대응 파일 존재 여부와 최신성을 확인한다.
2. **규칙 로드**: `references/translation-rules.md`(이 스킬 디렉토리)를 읽고 그대로 따른다. frontmatter 보존 규칙, 링크 프리픽스, ROBOCO 라틴 표기, JA です・ます調가 핵심이다.
3. **번역 실행**:
   - 1~2개 파일: 현재 세션에서 직접 번역.
   - 3개 이상: **opus 모델 서브에이전트**에 배치(파일 3개/에이전트, en+ja 동시)로 위임한다. 2026-07 파일럿 블라인드 평가에서 opus가 sonnet 대비 EN 2:1, JA 3:0으로 우세했다(sonnet은 です・ます調 위반 경향). 서브에이전트 프롬프트에 규칙 파일 경로를 반드시 포함하고, 커밋·hugo 실행은 금지시킨다.
   - 기존 번역이 있는 파일의 부분 수정이면 전체 재번역 대신 변경된 부분만 반영한다.
4. **검증** (커밋 전 필수):
   ```bash
   hugo --quiet   # 빌드 에러 없음
   # 한국어 잔존 (규칙 파일의 예외 3종 외에는 0건이어야 함)
   grep -n '[가-힣]' content/en/<대상>.md content/ja/<대상>.md
   grep -rn 'ロボコ' content/ja/   # 0건
   # date frontmatter가 ko와 동일한지, 헤딩 수가 3개 언어에서 같은지 확인
   ```
5. **커밋**: 번역만 담은 커밋으로 분리. 메시지 예: `feat(content): add en/ja translations of <slug>` 또는 `fix(content): sync en/ja translations with updated <slug>`.

## 주의

- en/ja 파일을 직접 수정해 달라는 요청이 아닌 한, en/ja를 ko보다 앞서 변경하지 않는다 (ko가 원본).
- `content/ko/posts/images/`는 공용이다 — 이미지 경로는 언어 프리픽스를 붙이지 않는다.
- 정적 페이지(about/solutions/products/contact) 수정 시 세 언어의 의미 동기화 여부를 확인하되, EN의 글로벌화 방침(규칙 파일 참조)은 유지한다.

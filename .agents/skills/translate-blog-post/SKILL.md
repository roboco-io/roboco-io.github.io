---
name: translate-blog-post
description: ROBOCO.IO 한국어 Hugo 블로그 포스트의 영어·일본어 번역을 위한 기존 진입점이다. 블로그 번역이나 translate-blog-post 요청 시 사용하며, 정적 페이지를 포함한 공통 절차는 translate-content에 있다.
---

# 블로그 영어·일본어 번역

이 스킬은 [translate-content](../translate-content/SKILL.md)의 블로그 전용 진입점이다. 해당 스킬과 연결된 번역 규칙을 읽고 그대로 적용한다. 절차와 규칙은 여기서 복제하지 않는다.

대상은 `content/ko/posts/<filename>.md`이며, 번역은 같은 파일명의 `content/en/posts/`와 `content/ja/posts/`에 둔다. 사용자 지정 언어와 범위를 우선한다. 한국어 작성·수정 작업에서는 원문 확인 후 번역하며, 완성된 원문에 대한 직접 번역 요청에는 확인을 반복하지 않는다.

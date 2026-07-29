# 다국어(영어/일어) 기능 설계

- 날짜: 2026-07-29
- 상태: 승인됨
- 범위: 이번 세션은 다국어 인프라 + 정적 페이지 번역. 포스트 40편 번역은 후속 세션에서 배치 진행.

## 목표

Hugo 기반 roboco.io 사이트에 영어(en)/일어(ja) 다국어 기능을 추가한다. 최종적으로 전체 콘텐츠(포스트 40편 포함)를 3개 언어로 제공하되, 이번 작업은 인프라와 정적 페이지까지만 다룬다.

## 결정 사항

| 항목 | 결정 |
|------|------|
| 번역 대상 | 전체 (포스트 포함, 단계적 진행) |
| 파일 구조 | 언어별 디렉토리: `content/ko/`, `content/en/`, `content/ja/` |
| URL 구조 | 한국어는 루트 유지(기존 URL 보존), 영어 `/en/`, 일어 `/ja/` |
| 이번 세션 범위 | 인프라 + 정적 페이지 4개 번역. 포스트 번역은 다음 세션 |

## 설계

### 1. 설정 (`hugo.yaml`)

- `defaultContentLanguage: ko`, `defaultContentLanguageInSubdir: false`
- `languages:` 블록에 ko/en/ja 정의:
  - `languageName`, `title`, `weight`
  - `contentDir`: `content/ko` / `content/en` / `content/ja`
  - `params.homeSubtitle`: 언어별 번역문
  - 언어별 `menu` (메뉴명은 기존 영문 유지, URL은 언어 프리픽스 반영)
- `params.enableGlobalLanguageMenu: true` (테마 내장 언어 전환 메뉴)

### 2. 콘텐츠 재배치

- 기존 `content/*` 전체를 `git mv`로 `content/ko/`로 이동 (포스트 40편 + images 포함)
- `content/en/`, `content/ja/`에 정적 페이지 4개(about/solutions/products/contact) 번역본 생성
- en/ja의 posts 목록은 당분간 비어 있음 — 빈 목록이 깨져 보이지 않는지 확인

### 3. 레이아웃 점검

- 커스텀 `layouts/index.html`, partials(menu/footer/head, home/logo)가 다국어 컨텍스트에서 동작하는지 확인
- 하드코딩된 한국어 문구는 `.Site.Params` 또는 i18n 참조로 교체

### 4. 검증 (푸시 전 로컬)

1. `hugo` 빌드 에러 없음
2. `hugo server`로 확인:
   - `/` — 한국어, 기존 URL 구조 그대로
   - `/en/`, `/ja/` — 번역된 정적 페이지·메뉴
   - 언어 전환 메뉴 동작
   - RSS/사이트맵 언어별 생성
3. 결과 보고 후 사용자 승인 → 커밋·푸시

## 리스크

- hello-friend-ng 테마(서브모듈)의 언어 메뉴가 기대대로 동작하지 않으면 partial 오버라이드로 대응
- GitHub Actions 배포는 `content/` 경로 트리거이므로 변경 불필요

## 후속 작업 (범위 밖)

- 포스트 40편 × 2개 언어 번역 — 서브에이전트 배치로 별도 세션에서 진행

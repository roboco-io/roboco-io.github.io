# 블로그 포스트 레퍼런스

## Hugo Frontmatter

```yaml
---
title: "제목"
date: YYYY-MM-DDT10:00:00+09:00
draft: false
toc: false
images:
tags:
  - tag1
  - tag2
---
```

- `date`: 작성일 기준, 시간은 `T10:00:00+09:00` 고정
- `draft`: 기본 `false`, 미완성이면 `true`
- `tags`: 소문자, 하이픈 구분 (예: `vibe-coding`, `agentic-dev`)

## 본문 구조

```markdown
> "인용구 또는 핵심 사실" – 출처[^N]

{{</* figure src="/posts/images/Dohyun.png" title="정도현 - 로보코 수석 컨설턴트" style=".author-image" */>}}

---

본문 시작...

---

## 결론

...

---

[^1]: 출처 제목: URL
[^2]: 출처 제목: URL
```

### 필수 요소

1. **도입 인용구**: 독자의 관심을 끄는 인용구 또는 핵심 사실로 시작
2. **저자 표기**: figure shortcode 필수 (위 형식 그대로)
3. **구분선**: 저자 표기 뒤, 결론 앞뒤에 `---`
4. **번호 헤딩**: `## 1. 제목`, `## 2. 제목` 형식으로 구조화
5. **각주**: `[^N]` 형식, 1부터 빠짐없이 연속. 문서 끝에 정의

## 문체 규칙

### 해야 할 것

- 자연스러운 한국어 기술 블로그 톤
- "~이다", "~한다" 체 (해체)
- 기술 용어는 원어 병기 가능 (예: "바이브 코딩(vibe coding)")
- 비유나 구체적 사례로 추상적 개념을 풀어쓴다
- 짧고 명확한 문장 선호

### 하지 말아야 할 것

- 논문체: "본 연구에서는", "기술 리포트다", "살펴보고자 한다"
- 번역체: "~것으로 나타났다", "~되어지다", "~에 있어서"
- 과도한 존댓말: "~습니다", "~세요"
- 과도한 영어 혼용
- "비하어" 같은 부자연스러운 조어 → "비하적 표현"
- "동등한 시민권을 가진다" 같은 직역 → "1급 시민으로 대우한다"

## 팩트 체크 방법

| 소스 유형 | 검증 방법 |
|---|---|
| GitHub 저장소 통계 | `gh api repos/{owner}/{repo}` → stars, forks, language |
| 기여자 수 | `gh api repos/{owner}/{repo}/contributors?per_page=1 -i` → Link 헤더의 last page |
| 파일 내용 | `gh api repos/{owner}/{repo}/contents/{path}` → base64 디코드 |
| Symlink 여부 | `gh api repos/{owner}/{repo}/git/trees/{branch}` → mode `120000` |
| 웹 기사/블로그 | WebFetch로 원문 확인 |
| 일반 사실 | WebSearch 또는 Perplexity로 교차 확인 |

## 파일 이름 규칙

- 소문자, 하이픈 구분: `my-post-title.md`
- 영어 사용 (한글 파일명 X)
- 내용을 함축하는 간결한 이름

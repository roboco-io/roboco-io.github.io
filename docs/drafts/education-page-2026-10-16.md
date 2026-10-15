---
target: content/ko/education.md (신규) + hugo.yaml 메뉴
generated_at: 2026-10-16T00:00:00+09:00
---

# Education 페이지 신설 + 메뉴 개편 초안 (2026-10-16)

> 이 파일은 초안이다. 원본 파일은 수정하지 않았다. 반영 시 `content/en/education.md`, `content/ja/education.md` 번역도 함께 만들어야 한다.

## A. 메뉴 개편안 (hugo.yaml)

현재 메인 메뉴는 About(10) / Solutions(20) / Products(25) / Research(27) / Posts(30) / Contact(40) / GitHub(50)이다. 메뉴는 `hugo.yaml`의 `menu.main` 하나를 ko/en/ja가 공유한다. Research와 Posts 사이에 Education을 추가한다.

```yaml
    - identifier: research
      name: Research
      url: /research/
      weight: 27
    - identifier: education
      name: Education
      url: /education/
      weight: 28
```

## B. content/ko/education.md 초안

```markdown
---
title: "Education"
description: "로보코의 바이브 코딩 워크숍, 강연 자료, AI 도입 역할 정의를 공개합니다."
date: 2026-10-16T09:00:00+09:00
draft: false
---

**배운 것을 나누고, 팀이 스스로 할 수 있게 만듭니다.**

로보코는 컨설팅과 함께 개발자·비개발자·학생을 위한 교육을 진행합니다. 워크숍 커리큘럼과 강연 자료, 조직에 AI 개발 방식을 정착시키는 역할 정의를 공개하고 있습니다. 귀사 맞춤 교육은 [Solutions](/solutions/)의 각 단계에서 실제 업무와 함께 진행합니다.

---

## 바이브 코딩 워크숍

개발자와 비개발자를 위한 두 가지 트랙으로 설계한 바이브 코딩 워크숍 커리큘럼입니다. 개발자 트랙은 시니어 개발자를, 비개발자 트랙은 기획·운영 등 비개발 직군을 대상으로 합니다.

- [커리큘럼 보기](https://roboco-io.github.io/vibecoding-workshop/)
- GitHub: [roboco-io/vibecoding-workshop](https://github.com/roboco-io/vibecoding-workshop)

---

## AI 시대의 학습법

대학생을 위한 60분 강연 자료입니다. 원하는 결과에서 거꾸로 학습 경로를 설계하는 방법, 톱다운 학습, 오픈소스 참여를 통한 학습을 다룹니다. AI가 수행할 수 있는 작업 길이에 관한 METR 데이터를 함께 소개합니다. 웹 슬라이드로 발표자 노트와 함께 공개합니다.

- [발표자료 보기](https://roboco.io/learn-with-ai/)
- GitHub: [roboco-io/learn-with-ai](https://github.com/roboco-io/learn-with-ai)

---

## Vibe Lead 역할 정의

Vibe Lead는 회사의 사업 목표를 달성하기 위해 AI 기반 개발 프로세스를 설계하고, 조직에 확산하고, 개선하는 변화 주도자입니다. 이 문서는 Vibe Lead가 왜 필요한지, 어떤 책임을 지는지를 정리한 역할 기술서로, 조직에 AI 개발 방식을 도입하려는 리더가 담당자를 정할 때 참고할 수 있습니다. 한국어·영어·일본어로 제공합니다.

- GitHub: [roboco-io/vibe-lead](https://github.com/roboco-io/vibe-lead/blob/main/README.ko.md)

---

## 귀사 팀을 위한 교육

공개 자료는 출발점입니다. 귀사의 실제 업무를 과제로 삼아 팀이 직접 만들고 검증하는 교육은 [실전 파일럿](/solutions/#pilot)과 함께 진행합니다.

[교육 상담하기](/contact/) · [로보코의 블로그 글 보기](/posts/)
```

## C. 확인이 필요한 사항

- 라이브 코딩 데모(vibecoding-demo ★34, ttimes-vibecoding-conference ★19 등)는 선택 질문에 응답이 없어 제외했다. 별 수가 가장 많은 리포지토리이므로 "라이브 데모" 섹션 추가 여부를 확인해야 한다.
- vibecoding-workshop README에는 두 트랙 상태가 "기획 중"으로 표시돼 있다(2026-10-16 조회). 공개 페이지에 노출할 시점이 맞는지 확인이 필요하다.
- `learn-with-ai`의 소개 문구 중 "원하는 결과에서 거꾸로 학습 경로를 설계"는 README의 "Offer Backward"를 풀어 쓴 해석이다.

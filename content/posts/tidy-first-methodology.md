---
title: "Tidy First 방법론: Kent Beck의 Augmented Coding 해석과 적용"
date: 2025-07-27T06:29:39+09:00
draft: true
toc: false
images:
tags:
  - Vibe Coding
  - Tidy First
  - Kent Beck
---

{{< figure src="/posts/images/Dohyun.png" title="정도현 - 로보코 수석 컨설턴트" style=".author-image">}}

최근 나는 클로드 코드(Claude Code)를 주요 작업 도구로 사용하고 있다. 클로드 코드가 탁월한 성능을 보이는 이유는 작업을 즉각적으로 실행하지 않고, 작업 전체를 체계적으로 계획한 뒤 작고 명확한 단계로 나누어 순차적으로 수행하기 때문이다.

오늘은 여기에 더해 한 가지 유용한 방법론을 소개하고자 한다. 바로 TDD(Test Driven Development)의 창시자로 유명한 Kent Beck이 자신의 블로그에서 제안한 "Augmented Coding"이라는 접근법이다. 이 양반도 용어 만들기에 집착하는 모습을 보니 바이브 코딩이라는 대세에 얼른 숟가락을 얹고자 하는것 같다. 하지만 나는 이 접근법이 기존에 Kent Beck이 쓴 책-[켄트 벡의 Tidy First?](https://www.hanbit.co.kr/store/books/look.php?p_code=B1474193984)의 내용에 기반하고 있기에 "Tidy First 방법론"이라 내 맘대로 부르기로 했다.

## Augmented Coding과 Tidy First의 핵심

Kent Beck이 이야기한 Augmented Coding의 핵심은 코딩 작업을 구조적 변화(Structural Changes)와 행동적 변화(Behavioral Changes) 두 가지로 명확하게 나누는 것이다. 구조적 변화는 코드의 동작을 변경하지 않고 단순히 코드의 위치를 바꾸거나, 이름을 변경하거나, 메서드를 추출하는 등의 작업을 말한다. 행동적 변화는 실제 코드의 기능을 추가하거나 수정하는 작업이다.

Beck은 이 두 가지 변화가 절대로 하나의 커밋(commit)에 혼합되어서는 안 된다고 강조한다. 특히 구조적 변화를 항상 우선적으로 처리하고, 이를 통해 코드의 복잡성을 낮춘 상태에서 명확한 테스트 환경을 유지한 후 행동적 변화를 도입해야 한다고 설명한다.

## Kent Beck이 제시한 규칙들

Kent Beck이 실제로 프로젝트에서 사용한 "Tidy First" 규칙은 다음과 같다:

* 항상 TDD 주기(빨강→초록→리팩터링)를 엄격히 준수한다.
* 가장 간단한 실패 테스트를 먼저 작성한다.
* 최소한의 코드로 테스트를 통과시키며, 그 이상을 넘지 않는다.
* 테스트가 통과된 이후에만 리팩터링한다.
* 구조적 변화와 행동적 변화를 분리하며, 커밋을 명확히 구분한다.
* 모든 테스트가 통과하고, 경고가 없으며, 작업의 논리적 단위가 명확할 때만 커밋한다.
* 코드의 중복을 철저히 제거하고, 명확한 이름과 구조로 의도를 표현한다.
* 메서드를 작게 유지하며, 하나의 책임만 수행하게 한다.

이러한 명확한 규칙을 지키며 코딩을 진행하면, 코드는 복잡성과 불필요한 기능 추가를 방지하면서 점진적으로 견고하고 이해하기 쉬워진다.

## Tidy First의 실제 적용과 장점

필자가 클로드 코드와 함께 이 "Tidy First 방법론"을 실제 프로젝트에서 적용해 본 결과, 프로젝트 대부분에서 매우 효과적으로 작동했다. 구조적 변화부터 시작해 코드 베이스를 깔끔하게 유지한 후 행동적 변화를 도입하면, 코드가 복잡해져 중간에 길을 잃는 일이 크게 줄어든다.

Kent Beck이 [B+ Tree 프로젝트](https://github.com/KentBeck/BPlusTree3)에서 밝혔듯이, AI(GenAI)가 때로 필요 없는 기능을 추가하거나 코드가 복잡해져서 개발 속도가 저하될 때가 있다. 이를 방지하려면 항상 먼저 구조적 정리 작업을 수행하고, 이 작업이 테스트를 통해 정확히 검증된 후에야 다음 기능적 변화를 추가해야 한다.

"Tidy First 방법론"은 AI와 함께 작업할 때 개발자가 코드에 대한 주도권과 명확성을 유지할 수 있게 해 주며, 코드의 품질과 복잡성을 관리하는 데 큰 도움이 된다.

이 방법론은 여러분의 프로젝트에도 분명 효과적일 것이다. 꼭 한번 시도해 보기를 강력히 권장한다.

#### 관련 링크
- [Augmented Coding: Beyond the Vibes](https://tidyfirst.substack.com/p/augmented-coding-beyond-the-vibes)
- [BPlusTree Project의 규칙파일](https://github.com/KentBeck/BPlusTree3/blob/main/.claude/system_prompt_additions.md)
- [켄트 벡의 Tidy First?](https://www.hanbit.co.kr/store/books/look.php?p_code=B1474193984)





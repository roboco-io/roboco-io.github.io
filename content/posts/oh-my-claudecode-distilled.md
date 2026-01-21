---
title: "Oh My Claude Code - Claude Code를 ‘팀’으로 쓰는 플러그인"
date: 2026-01-21T22:03:59+09:00
draft: false
toc: false
images:
tags:
  - claude-code
  - agentic-dev
  - vibe-coding
  - plugins
  - oh-my-claudecode
---

> “Don’t learn Claude Code. Just use OMC.” – *oh-my-claudecode* README[^github]

{{< figure src="/posts/images/Dohyun.png" title="정도현 - 로보코 수석 컨설턴트" style=".author-image">}}

---

oh-my-claudecode(OMC)는 Claude Code에 “멀티 에이전트 오케스트레이션”을 얹는 플러그인이다.[^github] 사용자가 서브 에이전트, 스킬, 훅 같은 개념을 하나씩 학습하지 않아도, **자연어 요청을 단서로 필요한 행동(계획/병렬화/지속 실행/리서치/디자인 감각)을 자동 활성화**하는 것을 목표로 한다.

이 글은 OMC를 “무엇을 해결하려는 플러그인인지”, “왜 Claude Code에서 이 방식이 합리적인지”, “어떤 워크플로에서 특히 강한지”를 한 번에 읽히는 형태로 정리한 기술 리포트다.

**[oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode)**

---

## 1. 프로젝트 개요

OMC가 내세우는 한 줄 요약은 “Multi-agent orchestration for Claude Code. Zero learning curve.”다.[^github] 핵심은 두 가지다.

1. **자동 위임(delegation-first)**: “복잡한 작업”이라고 말하면 설계/리서치/실행/QA 같은 전문 역할로 쪼개 병렬로 굴린다.
2. **자동 모드 전환**: “plan this”, “don’t stop until done” 같은 표현을 감지해 계획 인터뷰나 지속 실행(완료 보증) 성향을 켠다.

저장소가 공개하는 “Under the hood” 구성도는 OMC가 단순 프롬프트 모음이 아니라, Claude Code의 확장 포인트(agents/skills/hooks/statusline)를 묶어 **실사용 워크플로**로 만든 패키지라는 걸 보여준다.[^github]

---

## 2. 설치와 사용 흐름 (정말 30초)

README 기준 사용 흐름은 단순하다.[^github]

```text
/plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode
/plugin install oh-my-claudecode
/oh-my-claudecode:omc-setup
```

설치 후에는 “명령을 외우는” 대신, 평소처럼 일을 시키면 된다. OMC가 문장 속 힌트를 읽고 내부에서 적절한 스킬/서브에이전트를 조합한다.[^github]

---

## 3. 왜 ‘스킬 합성’이 핵심인가

OMC가 흥미로운 이유는 “Claude Code의 제약”을 정면으로 받아들이기 때문이다. Claude Code는 대화의 ‘마스터’를 다른 에이전트로 교체하는 방식이 아니라, **고정된 마스터에 스킬을 주입(inject)하는 방식으로 행동을 바꾼다**.[^arch]

OMC는 이 구조를 “레이어”로 정리한다.[^arch]

```text
[Execution Skill] + [0-N Enhancement Skills] + [Optional Guarantee]
```

예를 들어 “UI 작업 + 여러 파일 수정 + 커밋까지”가 필요하면, 실행(기본) 레이어 위에 `frontend-ui-ux`, `git-master` 같은 보강 레이어를 얹는 식이다.[^arch] 즉, 모드를 ‘갈아타는’ 게 아니라 **행동을 ‘겹겹이 쌓는’ 방식**이라서 맥락이 끊기지 않는다.

---

## 4. 파워 유저를 위한 ‘매직 키워드’

대부분은 자동이지만, 필요하면 키워드로 강제할 수도 있다.[^github]

| 키워드 | 효과 |
| --- | --- |
| `ralph` | 완료될 때까지 멈추지 않는 지속 실행 |
| `ralplan` | 합의를 만들며 반복 계획 |
| `ulw` | 최대 병렬 실행(ultrawork) |
| `plan` | 계획 인터뷰 시작 |
| `autopilot` / `ap` | 자율 실행 플로우 |

그리고 멈추고 싶을 때는 “stop/cancel/abort”처럼 말하면 맥락에 맞춰 중단한다.[^github]

---

## 5. OMC가 제공하는 ‘패키지’ 구성

공식 문서 기준으로 OMC는 크게 다음을 한 번에 제공한다.[^github][^full]

- **특화 에이전트 세트(27개)**: architect, researcher, designer, writer, critic, planner, qa-tester 등 역할군(티어 변형 포함)[^github]
- **스킬 세트(28개)**: orchestrate, ultrawork, ralph, planner, git-master, frontend-ui-ux, learner 등[^github]
- **HUD Statusline**: 오케스트레이션 진행 상황을 Claude Code 상태바에 요약 표시[^github]
- **메모리/노트 시스템**: 컨텍스트 컴팩션 이후에도 핵심 정보를 남기려는 3-Tier 메모리 아이디어(우선순위/작업 메모리/수동 노트)[^full]

구체적인 내부 동작과 라우팅 철학은 `docs/ARCHITECTURE.md`에서 “스킬 기반 라우팅을 어떻게 운영체제처럼 만든다”는 관점으로 설명한다.[^arch]

---

## 6. 언제 특히 유용한가 / 무엇이 트레이드오프인가

OMC는 특히 다음 상황에서 빛이 난다.

1. **멀티 파일·멀티 역할 작업**: 설계-구현-검증이 동시에 굴러가야 하는 기능 개발
2. **컨텍스트가 자주 무너지는 장기 세션**: 노트/메모리로 “잊지 말아야 할 것”을 남기는 패턴
3. **계획이 필요한데 시간을 쓰기 싫을 때**: “plan” 한 마디로 계획 인터뷰를 강제하는 흐름

반대로, 명확한 비용도 있다.

1. **토큰·시간·비용 증가**: 병렬화와 보강 스킬은 기본적으로 더 많은 호출/생각을 유도한다.
2. **자동화의 불투명성**: “왜 지금 이 행동을 했는지”가 즉시 이해되지 않을 수 있다.
3. **플러그인 운영 리스크**: 자율 실행이 강할수록 권한·가드레일(명령 중단, 범위 제한)에 더 민감해진다.

---

## 7. 맺음말

oh-my-claudecode는 “Claude Code를 잘 쓰는 팁”을 넘어서, **Claude Code를 팀처럼 쓰기 위한 기본값 세트**를 제공한다.[^github] 스킬 합성이라는 Claude Code의 구조를 정면으로 활용해, 사용자는 자연어로 지시하고 시스템은 알아서 계획·병렬·완료 보증을 조립한다. Claude Code를 ‘도구’가 아니라 ‘운영 환경’으로 보는 사람이라면, OMC는 꽤 설득력 있는 출발점이 될 것이다.

---

## 참고 자료

- [Yeachan Heo, *oh-my-claudecode* (GitHub)](https://github.com/Yeachan-Heo/oh-my-claudecode)
- [oh-my-claudecode, *ARCHITECTURE*](https://github.com/Yeachan-Heo/oh-my-claudecode/blob/main/docs/ARCHITECTURE.md)
- [oh-my-claudecode, *Full Reference Documentation*](https://github.com/Yeachan-Heo/oh-my-claudecode/blob/main/docs/FULL-README.md)
- [Anthropic, *Claude Code Docs*](https://docs.anthropic.com/claude-code)

[^github]: https://github.com/Yeachan-Heo/oh-my-claudecode
[^arch]: https://github.com/Yeachan-Heo/oh-my-claudecode/blob/main/docs/ARCHITECTURE.md
[^full]: https://github.com/Yeachan-Heo/oh-my-claudecode/blob/main/docs/FULL-README.md

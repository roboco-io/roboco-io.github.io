---
title: "프로덕트"
description: "로보코가 만드는 바이브 코딩 시대의 도구들"
date: 2026-05-16T10:00:00+09:00
draft: false
---

## **로보코가 만드는, 바이브 코딩 시대의 도구들**

로보코는 컨설팅과 교육 현장에서 얻은 통찰을 자체 프로덕트로 발전시킵니다. 모두 누구나 사용할 수 있도록 공개하고 있으며, 의견과 기여를 환영합니다.

---

## **Intent Engineering**

> *Ship intent, not code.* — 의도를 명확히 기록하고, 나머지는 AI에게 위임하는 바이브 코딩 패러다임.

코드를 직접 작성하던 시대에서 AI에게 의도를 전달하는 시대로 넘어가는 지금, "무엇을 왜 만드는가"를 정확히 표현하는 일이 가장 중요한 작업이 되었습니다. Intent Engineering은 이 의도를 문서로 정리하고, 진화시키며, 팀과 공유하기 위한 실용적 방법론입니다.

### 이런 분에게 유용합니다

- AI에게 일을 위임하면서 의도가 흐릿해지는 경험을 한 분
- 프로젝트의 "왜"를 잃어버리지 않고 빠르게 만들고 싶은 분
- 팀 내에서 AI 협업의 공통 언어를 정착시키고 싶은 리더

### 링크

- 사이트: [intent.roboco.io](https://intent.roboco.io)
- GitHub: [roboco-io/intent-engineering](https://github.com/roboco-io/intent-engineering)

---

## **VibeMap**

> *아이디어에서 배포까지, 바이브 코딩의 전체 지도.* — 의도공학·Claude Code·Git·TDD·AWS 서버리스 등 60여 개 개념을 인터랙티브 그래프로 탐색.

바이브 코딩 생태계는 빠르게 확장되고 있고, 어디서부터 무엇을 익혀야 할지 막막한 경우가 많습니다. VibeMap은 핵심 개념들과 그 관계를 한 장의 인터랙티브 지도로 보여주어, 학습자와 팀이 자기 위치와 다음 길을 찾을 수 있도록 돕습니다.

### 이런 분에게 유용합니다

- 바이브 코딩을 처음 시작하며 학습 경로를 잡고 싶은 분
- 팀의 도구·프로세스·역량 매핑이 필요한 리더
- 강의나 워크숍에서 시각적 레퍼런스로 활용하고 싶은 강사

### 링크

- 사이트: [vibemap.roboco.io](https://vibemap.roboco.io)
- GitHub: [roboco-io/vibemap](https://github.com/roboco-io/vibemap)

---

## **오픈소스 도구와 리소스**

자체 사이트는 아직 없지만, 로보코가 컨설팅·교육 현장과 자체 연구에서 만들고 다듬어 온 도구·실험·큐레이션을 GitHub에 공개하고 있습니다. 모두 실제 프로젝트, 강의, 그리고 "이게 정말 작은 비용으로 가능한가"를 직접 확인한 실험의 결과물입니다.

### **roboco-cli**

Claude Code와 바이브 코딩을 위한 AI-네이티브 개발 스캐폴딩 CLI. 로보코의 컨설팅 방법론 — 어떻게 프로젝트를 시작하고, AI 에이전트가 잘 작업할 수 있도록 저장소를 구조화하는지 — 을 명령어 한 줄로 압축한 도구입니다.

- GitHub: [roboco-io/roboco-cli](https://github.com/roboco-io/roboco-cli)

### **awesome-vibecoding**

바이브 코딩의 리소스·튜토리얼·베스트 프랙티스·예제를 모아둔 awesome 큐레이션 리스트. 한국·해외 자료를 폭넓게 다루며, 새로 등장하는 도구와 사례를 지속적으로 반영합니다.

- GitHub: [roboco-io/awesome-vibecoding](https://github.com/roboco-io/awesome-vibecoding)

### **hwp2md**

HWP(한글 워드프로세서) 문서를 LLM이 다룰 수 있는 Markdown으로 변환하는 도구. 한국 비즈니스 환경에서 AI를 도입할 때 가장 먼저 마주치는 문서 호환성 문제를 해결하기 위해 만들었습니다.

- GitHub: [roboco-io/hwp2md](https://github.com/roboco-io/hwp2md)

### **plugins**

Claude Code의 사용성을 확장하는 Skills·Commands·Agents·Hooks 플러그인 모음. 로보코가 컨설팅·교육 워크플로우에서 다듬어 온 패턴을 누구나 설치해 쓸 수 있도록 정리해 두었습니다.

- GitHub: [roboco-io/plugins](https://github.com/roboco-io/plugins)

### **s3-experiments**

Amazon S3를 단순 스토리지가 아닌 Key-Value Store, Event Store, 내구성 RDBMS(Litestream+SQLite), 서버리스 RDBMS(Athena), 파일 I/O 대안으로 활용하는 방법을 탐구하는 실험 프로젝트. CDK로 배포 가능한 동작 코드와 전용 서비스(DynamoDB, RDS, Aurora) 대비 정직한 트레이드오프 벤치마크를 함께 제공합니다 — 전담 클라우드 연구팀 없이도 아키텍처 결정의 가이드레일을 작은 비용으로 검증할 수 있게.

- GitHub: [roboco-io/s3-experiments](https://github.com/roboco-io/s3-experiments)

### **serverless-autoresearch**

Karpathy의 autoresearch를 AWS SageMaker Spot에서 재현·확장하는 프로젝트. H100 한 대를 8시간 점유해야 가능했던 야간 자동 모델 개선 실험을 2.3× 빠르고 5–18× 저렴하게 운영했고, 48개 실험 전체를 $3.94에 완료했습니다. HUGI 패턴을 적용한 병렬 진화 파이프라인과 8장의 핸즈온 튜토리얼도 함께 공개합니다.

- GitHub: [roboco-io/serverless-autoresearch](https://github.com/roboco-io/serverless-autoresearch)

### **vibe-ready-cli**

내 저장소가 바이브 코딩(AI 에이전트 기반 개발)에 얼마나 준비되어 있는지 한 명령으로 점검해 주는 CLI. Claude Agent SDK를 활용해 LLM이 직접 저장소를 탐색하고 6개 카테고리에 점수를 매긴 뒤, 종합 등급과 구체적인 개선 권장 사항을 제시합니다(`npx vibe-ready .` 로 즉시 실행 가능).

- GitHub: [roboco-io/vibe-ready-cli](https://github.com/roboco-io/vibe-ready-cli)

### **ghx-cli**

공식 GitHub CLI(`gh`)가 다루지 못하는 영역을 채우는 확장 CLI. GitHub Projects v2의 뷰·워크플로·필드 관리와 GitHub Discussions CRUD를 GraphQL API로 직접 조작할 수 있게 해 줍니다(`ghx project`, `ghx item`, `ghx field`, `ghx view` 등). 프로젝트 관리 자동화·일괄 처리·템플릿 적용 같은 실무 시나리오를 한 명령으로.

- GitHub: [roboco-io/ghx-cli](https://github.com/roboco-io/ghx-cli)

---

## **더 많은 활동**

위 외에도 다양한 데모·실험·교육 자료를 공개하고 있습니다.

- [github.com/roboco-io](https://github.com/roboco-io)

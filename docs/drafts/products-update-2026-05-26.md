---
source: products.md
generated_at: 2026-05-26
window: 2025-11-26 ~ 2026-05-26 (최근 6개월)
data_source: gh repo list roboco-io --visibility public
candidates_considered: 22
candidates_selected: 4
---

# products.md 업데이트 초안 (2026-05-26)

> 이 파일은 **초안**이다. `content/products.md` 원본은 수정되지 않았다. 사용자가 검토 후 원하는 부분만 직접 반영한다.
>
> 흐름 B(GitHub `roboco-io` org 스캔, public + 6개월 활동) 결과로 4개 리포지토리가 H3 블록으로 추가 후보.

---

## A. 신규 H2 풀 제품 블록

> 이번 라운드에는 없음. (선택된 4개 리포지토리 모두 `homepageUrl` 미설정 → H3 분류)

---

## B. 신규 H3 오픈소스 도구 블록

> `## **오픈소스 도구와 리소스**` 섹션 안, 기존 `### **plugins**` 다음에 이어서 추가하는 안.

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

## C. 본문 보강 패치 제안 (선택)

### C1. "오픈소스 도구와 리소스" 도입 문구

**변경 전 (현재):**
> 자체 사이트는 아직 없지만, 로보코가 컨설팅·교육 현장에서 만들고 다듬어 온 도구와 큐레이션을 GitHub에 공개하고 있습니다. 모두 실제 프로젝트와 강의에서 활용 중인 결과물입니다.

**변경 후 (제안):**
> 자체 사이트는 아직 없지만, 로보코가 컨설팅·교육 현장과 자체 연구에서 만들고 다듬어 온 도구·실험·큐레이션을 GitHub에 공개하고 있습니다. 모두 실제 프로젝트, 강의, 그리고 "이게 정말 작은 비용으로 가능한가"를 직접 확인한 실험의 결과물입니다.

**근거:** s3-experiments, serverless-autoresearch 등이 단순 도구가 아니라 비용·성능 실험 성격이라는 점을 도입에서 신호.

---

## D. 부록 — 스캔 메타데이터

- **데이터 소스:** `gh repo list roboco-io --visibility public --json name,description,url,pushedAt,isArchived,isFork,primaryLanguage,stargazerCount,homepageUrl`
- **스캔 윈도우:** 2025-11-26 ~ 2026-05-26 (최근 6개월, pushedAt 기준)
- **정렬:** 활동순(pushedAt) 내림차순
- **검토한 후보 (활동순, 22건):**
  vibecoding-workshop, officeagent-devops-onboarding-challenge, officeagent-onboarding-challenge, roboco-io.github.io, roboco-cli, s3-experiments, awesome-vibecoding, vibemap, hwp2md, plugins, serverless-autoresearch, .github, intent-engineering, vmux, vibe-ready-cli, gura-remover-mac, topology-efficient-deep-learning, PortfolioHackerton, ghx-cli, ralph-mem, vibe-coding-recommendations, upstage-demo

### 자동 제외 + 사유

- **products.md 중복:** roboco-cli, awesome-vibecoding, vibemap, hwp2md, plugins, intent-engineering
- **자기 자신:** roboco-io.github.io
- **인프라성 메타 리포지토리:** .github
- **채용 과제(공개 제품 톤 부적합):** officeagent-devops-onboarding-challenge, officeagent-onboarding-challenge
- **해커톤/데모성:** PortfolioHackerton, upstage-demo
- **description 부재 + 별도 신호 약함:** vibecoding-workshop, gura-remover-mac
- **사용자 선택에서 제외 (이번 라운드):** vmux, topology-efficient-deep-learning, ralph-mem, vibe-coding-recommendations

### 사용자가 H3로 확정한 항목 (4건)

| 리포지토리 | 마지막 활동 | ⭐ | 분류 | 결정 |
|---|---|---|---|---|
| s3-experiments | 2026-05-04 | 7 | H3 | 초안 그대로 |
| serverless-autoresearch | 2026-04-17 | 20 | H3 | 초안 그대로 |
| vibe-ready-cli | 2026-04-04 | 2 | H3 | 초안 그대로 |
| ghx-cli | 2026-02-06 | 5 | H3 | 초안 그대로 |

### 다른 페이지와의 관계

- `s3-experiments`, `serverless-autoresearch` 는 `docs/drafts/about-update-2026-05-26.md` 와 `solutions-update-2026-05-26.md` 의 "AI를 연구원으로 활용한 자체 실험" 블록에도 등장. **의도된 교차 노출**(products에서는 도구/실험 자체, about/solutions에서는 역량·서비스 근거로 활용).
- `Serverless OpenClaw`(`opensource/serverless-openclaw`)는 roboco-io org 밖이라 이번 흐름 B 스캔 결과에는 포함되지 않음. 필요 시 사용자가 명시적으로 추가 요청해야 함.

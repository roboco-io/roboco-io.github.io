---
source: about.md
generated_at: 2026-05-26
window: 2025-11-26 ~ 2026-05-26 (최근 6개월)
candidates_considered: 36
candidates_selected: 8
revision: v2 (codex review + 구조 분리 반영)
---

# about.md 업데이트 초안 (2026-05-26)

> 이 파일은 **초안**이다. `content/about.md` 원본은 수정되지 않았다. 사용자가 검토 후 원하는 부분만 직접 반영한다.
>
> **v2 변경점**
> - 사례를 두 그룹으로 분리: (1) **고객 비즈니스에 직접 기여** vs (2) **AI를 연구원으로 활용한 자체 실험**
> - codex 리뷰 4축 반영: 비즈니스 임팩트 언어 / 기술 민주화 / 주도성(Agency) 컨설팅 / 피드백 루프
> - Serverless OpenClaw 추가 (`opensource/serverless-openclaw`, 2026-04-22)

---

## A. 신규 추가 제안 — "최근 진행 프로젝트" 섹션

> about.md 본문 마지막(### 모든 규모의 기업과 함께합니다 다음)에 새 H3 섹션으로 추가하는 안.

### 최근 진행 프로젝트 — 컨설팅과 연구의 선순환

로보코는 두 방향으로 동시에 움직이며 경험을 빠르게 누적합니다. 첫째, 고객사 현장에서 비즈니스 임팩트를 만드는 컨설팅·교육. 둘째, AI를 연구원으로 활용해 예전이라면 전담 조직과 큰 예산이 필요했을 실험을 짧은 시간과 적은 비용으로 직접 돌려보는 자체 연구. 두 흐름에서 검증된 패턴은 다시 다음 고객의 진단·교육·PoC 설계로 흘러 들어가, 컨설팅의 속도와 정확도를 높입니다.

#### 1) 고객 비즈니스에 직접 기여한 프로젝트

대신 만들어주는 것이 아니라, **대표·리더·실무자가 AI를 활용해 직접 배우고 개선하는 운영 방식을 조직 안에 남기는 것**을 목표로 합니다.

- **국내 보안 SW 그룹사 바이브 코딩 도입 컨설팅** — 개발자 70명 도입론, 시니어 리더 20명 대상 모던 SW 엔지니어링, 풀데이 도입 워크숍으로 이어지는 Why·What·How 3단계 프로그램. 리더가 방향을 이해하고, 실무자가 직접 실험하며, 운영자가 성과를 측정할 수 있도록 역할별 학습 루프를 설계했습니다.
- **글로벌 서비스 기업 한국 법인의 K-FSI 감사 대응 지원** — AI로 정책·증적 정리·답변서 작성 워크플로를 함께 설계·도입해 감사관 질의에 대한 응답 시간과 일관성을 끌어올림. 답변서만 만들어 주는 외주가 아니라, 내부 인력이 익명화·검증·답변 품질 관리를 반복 운영할 수 있는 가이드라인까지 정착시켜 컴플라이언스 리스크를 구조적으로 낮췄습니다.
- **바이브 코딩 워크숍 커리큘럼** — 시니어 개발자와 비개발 직군을 분리된 트랙으로 다루어, 개발자는 AI를 동료로 활용해 개발 속도를 높이고 비개발 직군은 반복 업무를 직접 자동화해 운영 시간을 줄이도록 설계.
- **Challenge Driven Learning** — HR·피플 매니저·교육생·운영자 네 역할을 명시적으로 분리한 교육 플랫폼. 현업 문제를 가지고 들어와 학습 성과가 조직 차원에서 측정·정착되도록 만들어, 교육 예산이 비용이 아닌 자산으로 남도록 설계.

#### 2) AI를 연구원으로 활용한 자체 실험 — 기술의 민주화 증명

예전에는 전담 클라우드 팀, 데이터 사이언티스트, 큰 인프라 예산이 있어야 가능했던 실험을 **AI를 연구원처럼 활용해 1인·짧은 기간·적은 비용으로** 직접 돌려보고 결과를 공개합니다. 같은 접근을 고객 조직에도 이식할 수 있도록 가이드합니다.

- **Persona Insight** — Git/GitHub·GitLab 활동 데이터를 Claude·GPT·Gemini 세 LLM으로 병렬 분석해 개발자·팀의 비즈니스 임팩트를 추론. Business 40 / Customer 25 / Code Quality 20 / Engineering Practice 15의 4차원 스코어링과 평가 근거 전면 공개 원칙으로, 별도 데이터 사이언스 조직 없이도 데이터에 근거한 인사·우선순위 결정이 가능함을 보여줍니다.
- **S3 Deep Dive** — Amazon S3를 Key-Value Store, Event Store, 내구성 RDBMS(Litestream+SQLite), 서버리스 RDBMS(Athena)로 확장한 실험. CDK 배포 가능한 동작 코드와 전용 서비스 대비 정직한 트레이드오프 벤치마크를 함께 공개해, 전담 클라우드 연구팀 없이도 빅테크식 아키텍처 결정을 작은 비용으로 검증할 수 있음을 입증.
- **Serverless Autoresearch** — Karpathy의 autoresearch를 SageMaker Spot에서 재현. H100을 8시간 점유해야 가능했던 야간 자동 모델 개선 실험을 **2.3× 빠르고 5–18× 저렴하게** 운영했고, H100 Spot에서 upstream 보고치 0.998을 능가하는 0.9951 val_bpb를 **약 $3.5에 달성**, 48개 실험 전체를 **$3.94**로 완료. 8장의 핸즈온 튜토리얼도 함께 공개해 같은 접근을 누구나 복제할 수 있게 만들었습니다.
- **Serverless OpenClaw** — OpenClaw를 AWS 서버리스(Lambda Container + ECS Fargate Spot)에서 on-demand로 실행. 개인용 기준 **월 $1–2 운영**, 콜드 스타트 1.35초, 유휴 시 비용 0원. ALB 대신 API Gateway 사용으로 고정비 월 $18–25를 제거하는 등, "LLM 에이전트 서비스를 운영하려면 큰 인프라가 필요하다"는 통념을 직접 반증.

> 이 자체 실험에서 확인된 비용 패턴·실패 조건·보안 리스크는 그대로 고객 컨설팅의 가이드레일로 흡수되어, 고객은 더 적은 시행착오로 같은 접근을 자기 환경에 도입할 수 있습니다.

---

## B. 본문 보강 패치 제안

> 기존 문장 단위 보강안. 적용 위치와 변경 전/후를 함께 표기.

### B1. "3대 핵심 역량 > AI 활용 전문성"

**변경 전 (현재):**
> **AI 활용 전문성**: 경영/업무 전반에 AI를 통합하는 실전 방법론을 교육합니다. 바이브 코딩을 통해 비개발자도 소프트웨어를 만들 수 있게 하되, 함정과 위험을 미리 알려드립니다.

**변경 후 (제안):**
> **AI 활용 전문성**: 경영/업무 전반에 AI를 통합하는 실전 방법론을 교육합니다. 바이브 코딩을 통해 비개발자도 소프트웨어를 만들 수 있게 하되, 함정과 위험을 미리 알려드립니다. 멀티 LLM 병렬 분석(Persona Insight), S3 패턴 한계 실험(S3 Deep Dive), 48개 실험을 $3.94에 완료한 SageMaker Spot 기반 autoresearch 재현, 월 $1–2로 운영하는 서버리스 LLM 에이전트(Serverless OpenClaw) 같은 자체 연구를 통해 "어디까지가 가능하고 어디서부터가 위험한가"를 직접 확인해 가이드합니다.

**근거 프로젝트:** persona-insight, S3 Deep Dive, Serverless Autoresearch, Serverless OpenClaw

---

### B2. "3대 핵심 역량 > 글로벌 빅테크 경험"

**변경 전 (현재):**
> **글로벌 빅테크 경험**: 아마존과 구글 출신 창립 멤버들의 경험이 안전한 가이드레일 역할을 합니다. 빠르게 배우되, 위험한 실수는 피할 수 있도록 곁에서 가이드합니다.

**변경 후 (제안):**
> **글로벌 빅테크 경험**: 아마존과 구글 출신 창립 멤버들의 경험이 안전한 가이드레일 역할을 합니다. 전담 연구조직이나 대규모 인프라 예산이 없어도, 검증된 클라우드 패턴과 AI 도구를 활용하면 빅테크식 비용 효율(Spot 운영, S3 다목적 활용, 멀티 LLM 분석)을 작은 비용으로 시작할 수 있다는 것을 자체 실험으로 입증하고, 그 결과를 한국 고객 환경에 그대로 이식합니다.

**근거 프로젝트:** Serverless Autoresearch, S3 Deep Dive, Persona Insight, Serverless OpenClaw

---

### B3. "3대 핵심 역량 > 교육과 역량 이전"

**변경 전 (현재):**
> **교육과 역량 이전**: 로보코의 모든 서비스의 궁극적 산출물은 보고서나 시스템이 아닌, 귀사 내부에 축적된 역량입니다. 고객의 자립이 로보코의 성공입니다.

**변경 후 (제안):**
> **교육과 역량 이전**: 로보코의 모든 서비스의 궁극적 산출물은 보고서나 시스템이 아닌, 귀사 내부에 축적된 역량입니다. 대표와 리더가 방향을 이해하고, 실무자가 직접 실험하며, 운영자가 성과를 측정할 수 있도록 **역할별 학습 루프**를 설계합니다. 바이브 코딩 워크숍이 시니어 개발자와 비개발 직군을 분리된 트랙으로 다루고, Challenge Driven Learning이 HR·피플 매니저·교육생·운영자 네 역할을 명시적으로 분리해 조직 차원에서 학습 성과가 측정·정착되도록 설계된 이유입니다. 고객의 자립이 로보코의 성공입니다.

**근거 프로젝트:** vibecoding-workshop, Challenge Driven Learning

---

### B4. "주도권은 귀사에 있습니다"

**변경 전 (현재):**
> 외주에 맡기면 빠를 수 있지만, 지식은 외부로 빠져나갑니다. 로보코는 다른 길을 선택했습니다.
>
> **고객이 모든 주도권을 가지고, AI와 클라우드의 힘을 빌려, 안전하고 비용 효율적으로 AI 트랜스포메이션을 직접 이끌어 나가는 것.** 로보코는 그 여정의 파트너입니다.

**변경 후 (제안):**
> 외주에 맡기면 빠를 수 있지만, 지식은 외부로 빠져나갑니다. 로보코는 다른 길을 선택했습니다.
>
> **고객이 모든 주도권을 가지고, AI와 클라우드의 힘을 빌려, 안전하고 비용 효율적으로 AI 트랜스포메이션을 직접 이끌어 나가는 것.** 로보코는 그 여정의 파트너입니다. 한 글로벌 서비스 기업 한국 법인의 K-FSI 감사 대응에서도, 답변서 작성 워크플로만 만들고 끝내는 것이 아니라 **내부 인력이 익명화·검증·답변 품질 관리를 직접 운영할 수 있는 가이드라인**을 함께 정착시킨 이유입니다.

**근거 프로젝트:** K-FSI 감사 대응 지원

---

### B5. "AI는 대체가 아닌 증폭입니다" — 마지막 단락 보강

**변경 전 (현재):**
> 고급 인력이 부족해서 할 수 없었던 일 — 데이터 기반 의사결정, 소프트웨어 개발, 업무 프로세스 혁신, 고객 분석 — 이 모든 것을 AI의 힘을 빌려 지금 바로 시작할 수 있습니다.
>
> 단, **"가능하다"와 "안전하고 효과적으로 한다"는 다른 문제입니다.** 바로 여기에 로보코가 있습니다.

**변경 후 (제안):**
> 고급 인력이 부족해서 할 수 없었던 일 — 데이터 기반 의사결정, 소프트웨어 개발, 업무 프로세스 혁신, 고객 분석 — 이 모든 것을 AI의 힘을 빌려 지금 바로 시작할 수 있습니다. 로보코는 자체 연구로 이것을 직접 증명합니다. 48개의 모델 개선 실험을 $3.94에 끝내고, S3 하나로 KV·이벤트·DB·서버리스 패턴을 검증하고, LLM 에이전트 서비스를 월 $1–2로 운영하는 식입니다. 전담 연구팀이 없어도 가능합니다.
>
> 단, **"가능하다"와 "안전하고 효과적으로 한다"는 다른 문제입니다.** 바로 여기에 로보코가 있습니다.

**근거 프로젝트:** Serverless Autoresearch, S3 Deep Dive, Serverless OpenClaw

---

### B6. "모든 규모의 기업과 함께합니다" 리스트

**변경 전 (현재):**
> - **AI 활용을 확대하려는 기업**: 옆에서 함께 성장하는 파트너가 되어드립니다

**변경 후 (제안):**
> - **AI 활용을 확대하려는 기업**: 개발자 70명 도입론 → 시니어 리더 20명 모던 SW 엔지니어링 → 풀데이 도입 워크숍으로 이어지는 다단계 프로그램(국내 보안 SW 그룹사 사례)처럼, 조직 규모와 성숙도에 맞춰 옆에서 함께 성장하는 파트너가 되어드립니다.

**근거 프로젝트:** jiran-ai-transformation (익명 표현)

---

## C. 부록 — 스캔 메타데이터

- **스캔 윈도우:** 2025-11-26 ~ 2026-05-26 (최근 6개월, 기본값)
- **스캔 루트:** `/Users/dohyunjung/Workspace/roboco-io/` + 사용자가 직접 추가한 `/Users/dohyunjung/Workspace/opensource/serverless-openclaw`
- **대상 카테고리:** tools/, education/, research/, consulting/, services/, demos/ (+ opensource/는 사용자 명시 항목만)

### 자동 제외 + 사유

- **git 저장소 아님:** tools/vibe-sync, education/workshop, education/vibe-coding-for-kids, consulting/notion, consulting/bookangtech
- **윈도우(6개월) 밖:** vibe-coding-workshop, KSAT-AI-Benchmark, code-review-recommendation, handson-vibecoding-demo, DivViewQuickStart, agentic-coding-recommendation, vibe-coding-toolkit, vibe-coding-intro-workshop, ttimes-vibecoding-conference, vibe-lead, vibe-coding-news-archive, ecs-fargate-fast-scaleout, task-master-viewer, vibecoding-demo-calculator, data-analysis-demo, tm-demo, google-prompt-engineering-whitepaper, vibecoding-demo-jiran
- **products.md 중복으로 제외:** roboco-cli, awesome-vibecoding, hwp2markdown, plugins, vibemap
- **사용자 선택에서 제외 (이번 라운드):** semiconductor-design, vmux, vibe-ready-cli, gura-remover-mac, AI-DLC, topology-efficient-deep-learning, gh-project-cli, vibe-coding-recommendations, WorkshopStudio, mklanding, Project-Hwalbindang, Project-Swallow

### 사용자 추가 (스캔에 없던 항목)

- **K-FSI 감사 대응 프로젝트** — 비공개 저장소이므로 자동 스캔에는 잡히지 않음. 5단계에서 사용자가 직접 추가, 6단계에서 익명화 표현("글로벌 서비스 기업 한국 법인") 확정.
- **Serverless OpenClaw** — `opensource/` 디렉토리에 있어 기본 스캔 범위 밖. 사용자가 추가 요청.

### 카테고리 → 구조 재배치 (v2)

| 신규 분류 | 의도 | 포함 항목 |
|---|---|---|
| **① 고객 비즈니스에 직접 기여** | "주도성·자립" 톤 강화, 매출/비용/리스크/시간 같은 비즈니스 임팩트 언어로 번역 | jiran-ai-transformation(익명), K-FSI 감사 대응, vibecoding-workshop, Challenge Driven Learning |
| **② AI를 연구원으로 활용한 자체 실험** | "기술의 민주화" — 전담 조직·예산 없이도 짧은 시간·적은 비용에 빅테크식 결과 도출 | Persona Insight, S3 Deep Dive, Serverless Autoresearch, Serverless OpenClaw |

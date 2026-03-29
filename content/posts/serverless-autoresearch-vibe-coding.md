---
title: "Serverless Autoresearch: 바이브 코딩으로 ML 실험 파이프라인을 서버리스화한 기록"
date: 2026-03-29T16:00:00+09:00
draft: false
toc: false
images:
tags:
  - vibe-coding
  - agentic-dev
  - ml-engineering
  - aws
  - sagemaker
---

> 바이브 코딩의 진짜 가치는 코드를 빨리 쓰는 데만 있지 않다. 비싼 실험을 더 싸고 더 빠르게 반복할 수 있는 운영 방식을 설계하는 데 있다.

{{< figure src="/posts/images/Dohyun.png" title="정도현 - 로보코 수석 컨설턴트" style=".author-image">}}

대부분의 사람은 바이브 코딩을 웹 앱 프로토타이핑이나 CRUD 자동화와 먼저 연결한다. 하지만 로보코의 [`serverless-autoresearch`](https://github.com/roboco-io/serverless-autoresearch) 저장소는 이 프레임을 훨씬 넓힌다. 이 프로젝트는 Andrej Karpathy의 `autoresearch`가 전제하는 "H100 하나를 몇 시간 붙잡아 두는" 방식 대신, AWS SageMaker Spot 위에서 병렬 실험을 짧게 폭발적으로 실행하는 구조를 만든다.[^1]

이 사례가 흥미로운 이유는 결과만 싸게 나왔기 때문이 아니다. 이 저장소에는 **처음 아이디어를 다듬는 심층 인터뷰**, **계획 중심의 아키텍처 설계**, **클라우드 인프라 디버깅**, **반복 실험의 자동화**, **실패를 문서와 스킬로 환원하는 과정**이 모두 남아 있다. 특히 `docs/vibe-coding-tutorial`은 코드 설명서가 아니라, 대화형 AI 코딩이 실제로 어떻게 엔지니어링 산출물로 굳어지는지 보여주는 로그에 가깝다.[^2]

먼저 숫자부터 정리할 필요가 있다. 튜토리얼은 2026년 3월 27일~28일의 초기 실행 구간을 중심으로 **25회 실험, 총 비용 0.44달러, 최고 `val_bpb` 1.0643**을 기록한다.[^2][^10] 반면 저장소 README는 이후 확장된 그림으로 **83회 실험을 약 3.5시간, 약 1.33달러**에 수행하는 방향을 제시하며, 원래의 순차 실행 대비 **2.3배 빠르고 5~18배 저렴한 구조**를 강조한다.[^1] 즉 "0.44달러"는 초기 검증의 비용이고, "1.33달러"는 확장된 운영 모델의 비용이다. 두 수치는 충돌하지 않고 서로 다른 단계의 결과다.

## 1. 이 프로젝트가 실제로 바꾼 것

Karpathy의 원본 `autoresearch`는 한 번에 하나의 실험을 돌리며, 기본적으로 H100 같은 고성능 GPU를 오래 점유하는 흐름에 가깝다. `serverless-autoresearch`는 이 흐름을 **병렬 진화(parallel evolution)** 로 바꿨다.[^1][^4]

핵심은 두 가지다.

- 실험 하나를 오래 붙드는 대신 여러 후보를 동시에 짧게 실행한다.
- GPU를 24시간 켜 두는 대신, 필요할 때만 Spot 인스턴스를 띄우고 끝나면 바로 내린다.

이 저장소는 이를 **HUGI(Hurry Up and Get Idle)** 패턴이라고 부른다.[^1] 서버를 오래 유지하는 대신, 짧게 몰아서 계산하고 곧바로 유휴 상태로 돌아가는 방식이다. 이 단순한 전환이 비용 구조를 완전히 바꾼다. "서버리스"라는 말이 함수 호출만 뜻하는 것이 아니라, GPU 워크로드에도 적용 가능한 운영 철학임을 보여주는 셈이다.

튜토리얼 기준으로 보면 실제 검증도 꽤 구체적이다.

| 구간 | 내용 | 비용 |
|---|---|---|
| 초기 성공 실험 | L40S Spot에서 첫 end-to-end 성공 | $0.06 |
| 배치 크기 함정 검증 | 4회 병렬 실험으로 잘못된 가설 제거 | $0.07 |
| 5세대 자율 진화 | 20회 실험으로 최적 파라미터 탐색 | $0.31 |
| 합계 | 25회 실험 | **$0.44** |

즉 이 프로젝트의 포인트는 "저렴한 GPU로도 돌아간다"가 아니라, **값싼 실패를 많이 살 수 있다**는 데 있다.[^6][^7][^8][^10]

## 2. 튜토리얼이 보여주는 진짜 포인트

### 2.1 모호한 요청은 심층 인터뷰로 좁혀야 한다

튜토리얼의 첫 장면은 코드가 아니라 질문이다. 사용자는 "autoresearch 실험을 재현하고 싶다"는 요청과 함께, 필요하면 심층 인터뷰를 하라고 지시한다.[^3] 그 결과 목표는 단순 재현이 아니라 다음 세 가지로 다시 정의된다.

- SageMaker Managed Spot Training 기반의 서버리스 실행
- OMC 기반의 자율 반복 실험
- 교육용/데모용으로 재사용 가능한 문서화

이건 작아 보이지만 매우 중요한 전환이다. 막연한 "재현"은 종종 원본을 흉내 내는 데 그친다. 반면 인터뷰를 거치면 "무엇을 배울 것인가", "무엇을 자동화할 것인가", "무엇을 남길 것인가"가 명확해진다. 바이브 코딩은 프롬프트를 길게 쓰는 기술이 아니라, **좋은 문제 정의를 끌어내는 인터뷰 기술**에 가깝다는 사실을 보여준다.

### 2.2 구현보다 먼저 계획 모드가 필요하다

두 번째 장에서 AI는 곧바로 코드를 쓰지 않는다. 먼저 상위 `autoresearch` 코드베이스와 사용자의 기존 SageMaker 패턴을 탐색한 뒤, 후보 생성기, 배치 런처, 결과 수집기, 선택 모듈로 나뉜 파이프라인 구조를 계획한다.[^4]

중간에 사용자가 "클라우드의 장점인 병렬 실행과 HUGI를 적극 활용하라"는 조건을 추가하자, 설계는 순차 실행에서 **population-based parallel evolution** 구조로 바뀐다.[^4] 이 대목은 바이브 코딩이 "AI가 알아서 짠 코드"가 아니라, **계획 단계에서 아키텍처를 수정할 수 있을 때 비로소 쓸모가 커진다**는 점을 잘 보여준다.

실제로 튜토리얼은 이 세션에서 23개 파일이 만들어졌고, `make dry-run`으로 전체 경로를 검증했다고 기록한다.[^4] 중요한 것은 생성 속도보다, 생성 전에 구조가 합의됐다는 점이다.

### 2.3 인프라 문제는 주변 이슈가 아니라 핵심 설계 변수다

세 번째 장은 이 프로젝트의 백미다. 코드는 준비됐지만 AWS 인프라가 발목을 잡는다. GPU Spot 할당량은 기본값이 0이고, 리전마다 Spot 가용성도 극단적으로 다르다.[^5][^11]

튜토리얼에서 가장 실전적인 교훈은 `aws ec2 get-spot-placement-scores`다. 같은 `g7e` 계열 인스턴스도 `us-west-2`에서는 점수 1~2로 거의 잡히지 않지만, `us-east-1`에서는 점수 9로 빠르게 할당된다.[^5][^11] 많은 팀이 여기서 시간을 허비한다. 인프라 문제를 "코드가 다 된 뒤에 해결할 일"로 보기 때문이다. 하지만 이 저장소는 반대로 말한다. **어느 리전을 쓸지, 어떤 인스턴스를 쓸지, 할당량이 얼마나 빨리 승인되는지가 곧 파이프라인 설계의 일부**다.

여기서 또 하나 눈에 띄는 대목은 GPU 유형에 따른 승인 차이다. `g7e`는 비교적 빠르게 승인되지만, `p5`나 `p6`는 수동 심사로 며칠씩 걸릴 수 있다.[^5][^11] 이런 지식은 코드 안에 드러나지 않는다. 그래서 문서화와 운영 메모리가 더 중요해진다.

### 2.4 값싼 실험은 값싼 교훈을 빠르게 준다

네 번째와 다섯 번째 장은 "싼 실험"의 진짜 의미를 보여준다. 첫 성공 실험에서 L40S는 Flash Attention 3를 제대로 지원하지 않아 런타임 CUDA 에러를 냈고, 결국 GPU capability를 명시적으로 체크해 PyTorch SDPA로 폴백하는 로직이 들어갔다.[^6] 이 수정으로 첫 성공 실험은 돌아갔지만, MFU는 H100 대비 절반 수준인 약 20.5%에 머물렀다.[^6]

여기서 끝나지 않는다. 다음 실험에서는 VRAM이 남아 있으니 `DEVICE_BATCH_SIZE`를 키우면 좋아질 것 같았지만, 결과는 오히려 나빠졌다. 이유는 총 토큰 수가 늘지 않은 채 gradient accumulation만 줄었기 때문이다.[^7][^11] 이건 많은 ML 팀이 실제로도 헷갈리는 포인트다. GPU 메모리를 더 썼다고 해서 학습이 더 많이 된 것은 아니다.

이 프로젝트는 이런 오해를 값싸게 검증한다. 큰 예산이 들어가는 H100 실험에서 같은 실수를 반복했다면 훨씬 비쌌을 것이다.

### 2.5 자율 실험은 "과감한 변화"보다 "작은 조정"에서 성과를 냈다

자율 진화 단계에서 가장 흥미로운 결과는 화려한 아키텍처 변경이 아니라, **보수적인 학습률 조정이 가장 잘 먹혔다**는 점이다. `EMBEDDING_LR`과 `SCALAR_LR`의 작은 변경은 개선으로 이어졌지만, `DEPTH` 증가, `TOTAL_BATCH_SIZE` 확대, `WINDOW_PATTERN` 변경 같은 중간 규모 이상의 개입은 대부분 악화되거나 타임아웃으로 끝났다.[^8][^10]

이 패턴은 생각보다 중요하다. 짧은 5분 훈련 예산에서는 복잡한 구조 변경이 수렴할 시간을 얻지 못한다. 그래서 이 환경에서의 AI 에이전트는 "대담한 발명가"보다 "작은 수치를 집요하게 조정하는 운영자"일 때 더 강하다. 바이브 코딩이 늘 창의적 도약을 만드는 것이 아니라, **짧은 피드백 루프 안에서 작은 개선을 빠르게 누적시키는 데 강하다**는 뜻이다.

## 3. 실패를 스킬로 환원하는 방식이 특히 좋다

이 저장소가 로보코 관점에서 특히 좋은 이유는 마지막 처리 방식이다. 실험이 끝난 뒤 결과를 요약하는 데서 멈추지 않고, `docs/insights.md`에 12개의 인사이트를 정리한 뒤 이를 Claude Code용 재사용 스킬로 연결한다.[^9][^11]

여기 담긴 내용은 단순 메모가 아니다.

- 리전마다 Spot 점수가 극단적으로 다르다.
- 작은 인스턴스가 항상 더 싼 것은 아니다.
- `DEVICE_BATCH_SIZE`는 처리량이 아니라 VRAM 사용량에 더 가깝다.
- 저렴한 Spot GPU는 비싼 H100 훈련 전 가설 검증용 프록시로 충분히 쓸 수 있다.

이런 형태의 정리는 바이브 코딩의 성숙도를 가른다. 많은 팀은 AI와의 세션이 끝나면 배운 것을 잊어버린다. 하지만 잘하는 팀은 실패를 문서로 만들고, 문서를 다시 스킬과 규칙으로 바꾼다. 그러면 다음 세션의 품질이 올라간다. 즉 생산성의 원천이 모델 자체가 아니라, **축적되는 운영 지식**이 된다.

## 4. 로보코가 여기서 보는 결론

`serverless-autoresearch`는 바이브 코딩이 장난감 수준의 앱 제작을 넘어, ML 실험 파이프라인과 클라우드 운영 설계까지 다룰 수 있다는 점을 보여준다. 그리고 그 성패는 코드 생성량보다 다음 네 가지에 달려 있다.

- 처음 요청을 얼마나 잘 인터뷰해서 문제를 좁히는가
- 구현 전에 아키텍처를 얼마나 명확히 합의하는가
- 인프라와 비용 구조를 얼마나 빨리 검증하는가
- 실패를 얼마나 빠르게 문서와 스킬로 환원하는가

결국 이 프로젝트의 핵심 메시지는 단순하다. 바이브 코딩은 엔지니어링을 대체하지 않는다. 대신 엔지니어링의 중심을 **직접 타이핑하는 일**에서 **질문하고, 설계하고, 실험하고, 교훈을 축적하는 일**로 옮긴다. `serverless-autoresearch`는 그 이동이 실제로 어떤 모습인지 잘 보여주는 사례다.

원본 저장소와 튜토리얼을 함께 읽어보면, "AI가 코드를 써 줬다"보다 훨씬 흥미로운 장면이 보인다. **AI와 함께 실험 시스템 자체를 설계한 과정**이 남아 있기 때문이다.[^1][^2]

---

[^1]: Serverless Autoresearch README: https://github.com/roboco-io/serverless-autoresearch/blob/main/README.md
[^2]: Vibe Coding Tutorial README: https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/README.md
[^3]: Chapter 1, "The Idea": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/01-the-idea.md
[^4]: Chapter 2, "Building the Pipeline": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/02-building-the-pipeline.md
[^5]: Chapter 3, "Infrastructure Adventures": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/03-infrastructure-adventures.md
[^6]: Chapter 4, "First Experiment": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/04-first-experiment.md
[^7]: Chapter 5, "The Batch Size Trap": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/05-the-batch-size-trap.md
[^8]: Chapter 6, "Autonomous Evolution": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/06-autonomous-evolution.md
[^9]: Chapter 7, "Insights & Skills": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/07-insights-and-skills.md
[^10]: Chapter 8, "Results & Comparison": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/08-results-and-comparison.md
[^11]: Key Insights: https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/insights.md

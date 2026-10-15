---
source: content/ko/research.md
generated_at: 2026-10-16T00:00:00+09:00
candidates_selected: 2
---

# research.md 업데이트 초안 (2026-10-16)

> 이 파일은 초안이다. content/ko/research.md 원본은 수정하지 않았다. 반영 시 en/ja 번역도 함께 동기화해야 한다.

## A. 목차 목록 패치

**변경 후** (도입부 목록에 2줄 추가)

```markdown
- [랄프루프 완주 비교](#ralph-loop)
- [수능 AI 벤치마크](#ksat-benchmark)
- [서버리스 자동 학습 실험](#serverless-autoresearch)
- [위상수학 기반 딥러닝 효율 실험](#topology-efficient-dl)
- [반도체 EDA 실험](#semiconductor-design)
- [S3 실험](#s3-experiments)
- [Aurora DSQL 비교 실험](#dsql-experiments)
```

`*소개 기준: 2026-09-25.*` 줄은 반영일로 갱신한다.

## B. 신규 섹션

> `## 랄프루프 완주 비교` 섹션 다음에 수능 벤치마크를, `## 서버리스 자동 학습 실험` 섹션 다음에 위상수학 실험을 넣는 안이다. 기존 섹션과 같은 질문·방법·관찰·해석 범위 구조를 따른다.

## 수능 AI 벤치마크 {#ksat-benchmark}

**2026학년도 결과 공개 · 2027학년도 수능 직후 평가 예정**

**질문:** 최신 AI 모델은 대한민국 수능 문제를 얼마나 풀 수 있을까요? 모델과 실행 도구에 따라 정답률, 시간, 비용은 어떻게 달라질까요?

**방법:** 2026학년도 수능 홀수형 원본 PDF를 이미지로 렌더링해 문제 본문을 텍스트로 옮기지 않고 그대로 제시합니다. 국어·수학·영어의 147개 고유 문항을 OpenAI, Anthropic, 오픈 모델 계열의 여러 모델로 풀게 하고, 도구·검색·플러그인은 끕니다. 모델이 확신하지 못하는 문항은 기권할 수 있으며, 기권은 실행 오류와 구분해 기록합니다.

**관찰:** 모델별 답안과 채점 결과, 문항별 시간·토큰·비용 추정치를 대시보드로 공개합니다. 매년 수능 전에 전년도 문제를, 수능 직후에 새 문제를 같은 모델·프로토콜로 평가해 연도별 비교가 가능하도록 운영합니다.

**해석 범위:** 공개된 전년도 문제는 모델 학습 데이터에 포함됐을 가능성이 있습니다. 원점수를 학생의 표준점수·백분위·등급으로 환산하지 않습니다. 영어 듣기는 공식 대본 이미지로 평가하므로 음성 청취 평가와 다릅니다. 비용은 묶음 요청 값을 문항별로 균등 배분한 추정치입니다.

- [결과 대시보드](https://roboco.io/KSAT-AI-Benchmark/)
- [프로젝트 저장소](https://github.com/roboco-io/KSAT-AI-Benchmark)

---

## 위상수학 기반 딥러닝 효율 실험 {#topology-efficient-dl}

**Track A 완료(가설 기각) · Track B·C 진행 상황은 저장소 참고**

**질문:** 위상수학과 구조 수학을 활용하면 딥러닝 모델의 계산량(FLOPs, 메모리, 학습 시간)을 줄이거나, 같은 계산량에서 성능을 높일 수 있을까요?

**방법:** 세 트랙으로 나눠 검증합니다. Track A는 시계열 분류에서 Persistent Homology 요약 피처로 모델 크기를 줄이는지, Track B는 그래프에서 Simplicial/Cell Complex로 전역 attention을 피할 수 있는지, Track C는 텐서 분해로 가중치를 압축해 연산량을 줄이는지 확인합니다. 실험은 SageMaker Managed Spot Training에서 3개 시드로 반복합니다.

**관찰:** Track A에서 작은 모델(PH-MLP)은 4개 데이터셋 모두에서 비교 모델(InceptionTime)보다 F1이 8–32%p 낮아, 성공 기준(1%p 이내 하락)을 달성하지 못했습니다. 시간 패턴이 피처 변환 과정에서 손실되고, 긴 시계열에서 계산 비용이 커지는 것이 원인으로 분석됐습니다. Track A 전체 실험 비용은 약 0.40달러였습니다.

**해석 범위:** 이 결과는 Track A의 기법과 데이터셋에 한정됩니다. 위상수학 접근 전체가 효과 없다는 결론은 아닙니다. Track B·C의 결과는 이 초안 작성 시점(2026-10-16)에 README에서 확인하지 못했으므로, 반영 전에 확인이 필요합니다.

- [프로젝트 저장소](https://github.com/roboco-io/topology-efficient-deep-learning)
- [Track A 상세 결과](https://github.com/roboco-io/topology-efficient-deep-learning/blob/main/results/track_a_results.md)

---

## C. 기존 섹션 보강 제안

`advisor-strategy-experiment`(강한 모델이 조언하고 약한 모델이 실행하는 전략 측정)는 사용자 확인에 따라 `coding-agent-benchmark`로 피벗됐다. 따라서 별도 섹션을 만들지 않는다. 필요하면 `## 랄프루프 완주 비교` 섹션의 방법 문단 끝에 다음 문장을 추가한다.

> 이 실험은 강한 모델이 조언하고 약한 모델이 실행하는 Advisor 전략 측정에서 출발해, 모델과 작업 환경 조합의 완주 비교로 범위를 넓혔습니다.

(이 문장의 사실관계, 즉 피벗 순서와 범위는 사용자 확인 필요.)

## D. 부록

- 사용자 선택: KSAT-AI-Benchmark, topology-efficient-deep-learning, advisor-strategy-experiment(→ coding-agent-benchmark로 피벗, 별도 섹션 없음)
- 근거 자료: 각 리포지토리 README (2026-10-16 조회)

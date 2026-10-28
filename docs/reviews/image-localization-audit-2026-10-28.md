# 번역 페이지 이미지·다이어그램 조사

- 범위: `content/en/`, `content/ja/`의 조사 시작 시점의 Markdown 132개. 초안 포함 Hugo 생성 HTML의 img·OG 이미지도 조사했다.
- 원본 본문 이미지: 로컬 12종 + 외부 SVG 1종. 공통 로고·OG 이미지도 별도 확인했다.
- SVG text/title/desc/foreignObject, 비트맵 5종의 실제 화면, 인라인 Mermaid의 대상 언어가 아닌 설명 레이블을 확인했다.
- 결과: 언어별 SVG 16개 생성. 영어·일본어 LLM 글과 일본어 기존 글 2개에서 사용한다. 일본어 기존 글 3개의 Mermaid 10개도 현지화했다.

| 원본 | 판정 | 반영 |
|---|---|---|
| `llm-cache/01`~`07` | 한국어 설명·노드·조건이 있어 EN/JA 모두 필요 | `static/posts/images/llm-cache/{en,ja}/`에 14개 생성, `how-llm-caching-works.md`의 해당 언어 참조 교체 |
| `SmallTeamsAreTheFuture.png` | 영어 원본은 EN에서 유지, JA에는 설명 번역 필요 | `static/posts/images/ja/SmallTeamsAreTheFuture.svg`, `content/ja/posts/ai-be-my-nakama.md`에 사용 |
| 외부 ECS Fargate architecture.svg | 영어 원본은 EN에서 유지, JA에는 설명 번역 필요 | `static/posts/images/ja/ecs-fargate-architecture.svg`, `content/ja/posts/how-to-draw-diagram.md`에 사용 |
| `Dohyun.png` | 텍스트 없는 저자 아바타 | 공용 유지 |
| `run-from-ai.png` | 텍스트 없는 삽화 | 공용 유지 |
| `ai-be-my-nakama.png` | 텍스트 없는 삽화, 코드 기호는 번역 대상 아님 | 공용 유지 |
| `agent-smith-300.png` | 텍스트 없는 사진 | 공용 유지 |
| 사이트 로고·기본 OG | 브랜드·도메인 표기 | 공용 유지 |
| 인라인 Mermaid | 일본어 글 3개에 영어 설명 레이블 잔존 | `ruflo-claude-code-multi-agent-orchestration` 2개, `organizational-design-for-vibe-coding` 1개, `claude-code-deep-dive` 7개 현지화. 노드 ID·연결·제품명·숫자는 보존 |

## 보존한 내용

- 인포그래픽 수치는 원도표의 주장 그대로 번역했으며 현재 성과로 재검증한 수치가 아니다. Ben Lang 출처와 영어 원본 링크를 유지했다.
- 아키텍처 원본: https://raw.githubusercontent.com/Hands-On-Vibe-Coding/ecs-fargate-fast-scaleout/abbb4dee4d89070692fc4edc0e81a313c910c52b/docs/diagrams/architecture.svg
- 아키텍처의 노드·화살표·CIDR·5초/10초 조건과 AWS 제품명은 유지했다. HTML foreignObject 레이블을 SVG text로 옮겨 이미지 렌더러에서도 일본어가 보이게 했다.
- LLM 그림 7의 구간별 공유 지원 조건과 vLLM 요청 단위 salt의 차이를 양쪽 번역에 유지했다.

## 검증

16개 새 SVG를 렌더링해 문구 배치와 잘림을 확인했다. 한국어 원본은 보존했다. Hugo 빌드와 번역 페이지의 언어별 이미지 경로·파일 존재 여부, 이미지 내부 한글 잔존, 링크·각주를 검사했다. Mermaid 10개는 Mermaid CLI로 실제 렌더링했다. 외부 원본 이미지의 미래 변경은 조사 범위 밖이며 아키텍처는 고정 커밋 URL을 기록했다.

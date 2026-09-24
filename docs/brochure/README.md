# 회사 소개 브로셔

소프트웨어 공장을 중심으로 회사와 서비스를 소개하는 A4 4페이지 자료입니다.

## 원본과 배포 파일

- 한국어: `roboco-brochure.html` / `roboco-brochure.pdf`
- 영어: `roboco-brochure.en.html` / `roboco-brochure.en.pdf`
- 일본어: `roboco-brochure.ja.html` / `roboco-brochure.ja.pdf`
- 공통 인쇄 스타일: `brochure.css`
- 웹 다운로드: `static/brochure/`의 같은 이름 PDF

HTML은 이 폴더의 공통 CSS를 함께 사용합니다. PDF를 직접 수정하지 않고 HTML을 수정한 뒤 다시 생성합니다.

## 다시 생성하기

저장소 루트에서 실행합니다. Google Chrome, Python 3, Poppler의 `pdfinfo`가 필요합니다.

```bash
./scripts/generate_brochure_pdfs.sh
```

기본 Chrome 경로는 macOS의 `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`입니다. 다른 실행 파일은 `BROCHURE_CHROME` 환경 변수로 지정할 수 있습니다. 렌더링에 쓰는 한·일 글꼴도 설치되어 있어야 합니다.

스크립트는 격리된 임시 Chrome 프로필에서 PDF를 생성하고, 세 언어 모두 4페이지인지 확인한 뒤 이 폴더와 웹 다운로드 폴더에 복사합니다. PDF 쓰기가 완료된 뒤에도 Chrome이 남아 있으면 해당 렌더링 프로세스만 종료합니다.

## 검수

페이지 수 검사만으로 잘림이나 글꼴 문제를 확인할 수는 없습니다. 수정 후 세 언어 12페이지를 이미지로 렌더링해 확인합니다.

```bash
pdftoppm -r 120 -png docs/brochure/roboco-brochure.pdf /tmp/roboco-brochure-page
```

한국어 PDF는 텍스트 추출 결과 대신 렌더링과 HTML 원문으로 검수합니다. PDF 안의 링크, `docs/brochure/`와 `static/brochure/`의 파일 일치도 확인합니다.

## 콘텐츠 기준

- 핵심: 고객이 소유하고 운영하는 소프트웨어 공장과 역량 이전.
- 도입: 실전 파일럿 → 공장 구축 → 운영 고도화. 교육과 자문은 단계별로 통합.
- 파일럿: 범위·기간·비용·성공 기준을 개별 합의.
- 고객 사례: 익명 유지. 한 달은 해당 사례의 프로토타입 출시 기간이며, 공장 전환은 진행 중.
- 주요 고객 사례: 개발 내재화, 소프트웨어 조직의 AI 도입, 글로벌 SaaS의 평가 준비 지원을 익명으로 소개.
- 수행 자료에서 확인한 지원 내용과 진행 상태만 기재하며, 제안 단계의 과제를 수행 실적으로 표시하지 않음.
- 회사명·제품명·부서명·정확한 인원·계약 정보·비공개 경로 등 고객 식별 단서는 브로셔와 공개 원본에 포함하지 않음.

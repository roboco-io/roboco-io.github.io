@AGENTS.md

## Claude Code 연결 설정

- 공통 규칙과 스킬 원본은 `AGENTS.md` 및 `.agents/`에 있다. `.claude/skills/<이름>`은 해당 공통 스킬 디렉터리를 가리키는 링크다. 수정은 `.agents/`의 원본에서 한다.
- `.claude/settings.json`은 Claude 전용 훅을 등록한다. 한국어 편집 후 알림은 번역 상태 확인용이며 원문 확인이나 사용자의 언어 범위 지시를 대신하지 않는다.
- `blog-from-ideation`의 기존 수동 호출 정책은 `.claude/settings.json`의 `skillOverrides`로 유지한다. Codex의 자동 스킬 선택에는 영향을 주지 않는다.

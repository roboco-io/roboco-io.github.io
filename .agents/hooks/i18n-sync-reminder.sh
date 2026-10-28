#!/bin/bash
# Claude PostToolUse adapter. Codex uses the same rule through AGENTS.md.
input=$(cat)
fp=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
case "$fp" in
  content/ko/*.md) rel=${fp#content/ko/} ;;
  */content/ko/*.md) rel=${fp#*/content/ko/} ;;
  *) exit 0 ;;
esac
jq -n --arg rel "$rel" '{
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: ("[i18n] content/ko/" + $rel + " 변경: 대응하는 content/en/" + $rel + ", content/ja/" + $rel + "의 번역 상태를 확인한다. 공통 절차는 .agents/skills/translate-content/SKILL.md에 있다. 원문 작성·수정 작업은 사용자 확인 후 번역하며, 이미 확인된 원문의 직접 번역 요청에는 확인을 반복하지 않는다. 번역 보류·언어 제한 지시가 우선이며, 이미 동기화했다면 추가 작업은 필요 없다.")
  }
}'

#!/bin/bash
# PostToolUse hook: content/ko/ 마크다운이 수정되면 en/ja 번역 동기화를 상기시킨다.
input=$(cat)
fp=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

case "$fp" in
  */content/ko/*.md)
    rel=${fp#*content/ko/}
    cat <<EOF
{"decision": "block", "reason": "[i18n] content/ko/${rel} 이(가) 변경되었습니다. 대응하는 content/en/${rel}, content/ja/${rel} 번역도 이번 작업에서 함께 갱신해야 합니다. .claude/skills/translate-content/SKILL.md 절차(번역 규칙: references/translation-rules.md)를 따르세요. 이미 갱신했거나 사용자가 번역 제외를 지시한 경우 이 안내는 무시해도 됩니다."}
EOF
    ;;
esac
exit 0

#!/usr/bin/env bash
# PreToolUse guard: refuse any tool call that touches credential files.
#
# Covers .env files and ~/.ssh. Why this exists: permission rules are per-tool,
# so `deny: ["Read(.env)"]` stops the Read tool and nothing else — any shell
# command (cat, grep, sed, awk, source, python) can still read the file. This
# closes the incidental case for every tool at once, and unlike a path deny rule
# it can tell committed templates (.env.example) from real secrets.
#
# Reads the hook payload on stdin. Prints a deny decision and exits 0 when the
# call references a protected path; otherwise stays silent.
#
# Limits, stated plainly: it inspects command strings and paths, not file
# contents, and deliberate obfuscation (`.en''v`, a path in a variable) defeats
# it. The target is the accidental read, not an adversary.
set -uo pipefail

payload=$(cat)

if command -v jq >/dev/null 2>&1; then
  # Bash puts it in .command; Read/Edit/Write in .file_path; Grep/Glob in .path.
  subject=$(printf '%s' "$payload" | jq -r '[.tool_input.command, .tool_input.file_path, .tool_input.path, .tool_input.notebook_path] | map(select(. != null)) | join(" ")')
else
  # No jq: scan the raw payload. Over-blocks rather than under-blocks.
  subject=$payload
fi

# A path can begin after these; requiring one is what keeps `process.env`,
# `import.meta.env`, `printenv`, `NODE_ENV`, and `openssh` from tripping the guard.
BOUNDARY='(^|[[:space:]"'"'"'`=/~(<>|&;,{])'
# ...and a path token ends at one of these.
TERMINATOR='($|[[:space:]"'"'"'`)&|;,}])'

deny() {
  # $1 = reason sentence. Emitted as JSON via jq so quoting can't break the payload.
  jq -nc --arg reason "$1" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
  exit 0
}

# --- .env ---------------------------------------------------------------------
# Committed templates hold no secrets — drop them before testing.
probe=$(printf '%s' "$subject" | sed -E 's/\.env\.(example|sample|template|dist|defaults?)//g')
if printf '%s' "$probe" | grep -qE "${BOUNDARY}\.env"; then
  deny "Blocked by the local credential guard: this call references a .env file. Do not read, grep, source, or probe .env — not even to check whether a variable is set. Ask the user instead; they can run the command themselves with the ! prefix. .env.example and friends are fine."
fi

# --- ~/.ssh -------------------------------------------------------------------
# Matches path references into the directory, not the `ssh` command itself, so
# git-over-ssh and plain `ssh host` keep working.
if printf '%s' "$subject" | grep -qE "${BOUNDARY}\.ssh(/|${TERMINATOR})"; then
  deny "Blocked by the local credential guard: this call references ~/.ssh. Private keys and known_hosts are off limits — don't read, list, or copy them. Ask the user; they can run the command themselves with the ! prefix. Using ssh or git over ssh is unaffected."
fi

exit 0

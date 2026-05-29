#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_DIR"

EXAMPLES=(
  "simple_stream"
  "sync_run"
  "model_selection"
  "mode_agent_plan_ask"
  "permission_and_trust"
  "session_resume_continue"
  "typed_events_tooling"
  "mcp_helpers"
  "worktree_options"
  "plugin_dirs_and_headers"
  "configuration_stagger"
  "governed_launch_demo"
  "error_handling"
  "command_module"
  "options_schema"
  "env_api_key"
  "promotion_path/sdk_direct_cursor"
)

usage() {
  cat <<'EOF'
Usage:
  bash examples/run_all.sh [example_name ...] [--forwarded-flags]

Examples:
  bash examples/run_all.sh
  bash examples/run_all.sh simple_stream
  bash examples/run_all.sh promotion_path/sdk_direct_cursor --cwd /repo
  bash examples/run_all.sh --cli-command /path/to/agent
EOF
}

contains_example() {
  local needle="$1"
  local item

  for item in "${EXAMPLES[@]}"; do
    if [[ "$item" == "$needle" ]]; then
      return 0
    fi
  done

  return 1
}

selectors=()
forward_args=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --*)
      forward_args+=("$1")
      shift
      if [[ $# -gt 0 && "$1" != --* ]]; then
        forward_args+=("$1")
        shift
      fi
      ;;
    *)
      selectors+=("$1")
      shift
      ;;
  esac
done

if [[ ${#selectors[@]} -eq 0 ]]; then
  selectors=("${EXAMPLES[@]}")
fi

pass=0
fail=0
skip=0

echo "CursorCliSdk examples"
echo "project=${PROJECT_DIR}"
mix compile --warnings-as-errors || exit 1

for example in "${selectors[@]}"; do
  if ! contains_example "$example"; then
    echo "unknown example: $example" >&2
    exit 1
  fi

  echo
  echo "== ${example} =="
  if [[ ${#forward_args[@]} -eq 0 ]]; then
    mix run "examples/${example}.exs"
  else
    mix run "examples/${example}.exs" -- "${forward_args[@]}"
  fi
  exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    pass=$((pass + 1))
  elif [[ $exit_code -eq 20 ]]; then
    skip=$((skip + 1))
  else
    fail=$((fail + 1))
  fi
done

echo
echo "results_pass=${pass}"
echo "results_skip=${skip}"
echo "results_fail=${fail}"

if [[ $fail -gt 0 ]]; then
  exit 1
fi

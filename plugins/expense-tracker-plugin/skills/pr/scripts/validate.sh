#!/usr/bin/env bash
# Проверяет, что из текущей ветки можно открыть PR в master.
#
# Использование: validate.sh
#
# Коды выхода:
#   0 — всё в порядке (имя ветки печатается в stdout)
#   1 — ветка или рабочее дерево не проходят проверку (причина — в stderr)
#   2 — ошибка окружения (не git-репозиторий, gh не авторизован, лишние аргументы)

set -euo pipefail

BRANCH_PATTERN='^(feat|fix|refactor|perf|docs|style|test|build|ci|chore)/[a-z0-9]+(-[a-z0-9]+)+$'

fail() {
  echo "validate: $1" >&2
  exit "${2:-1}"
}

[ "$#" -eq 0 ] || fail "аргументы не принимаются — проверяется текущая ветка" 2

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "не git-репозиторий" 2

gh auth status >/dev/null 2>&1 || fail "gh не авторизован — выполни gh auth login" 2

branch="$(git branch --show-current)"
[ -n "$branch" ] || fail "detached HEAD (или незавершённый rebase) — переключись на рабочую ветку"

[ "$branch" != "master" ] || fail "PR из master не создаётся — нужна рабочая ветка <type>/<scope>-<описание>"

[[ "$branch" =~ $BRANCH_PATTERN ]] || fail "ветка '$branch' не соответствует формату <type>/<scope>-<описание> (type: feat|fix|refactor|perf|docs|style|test|build|ci|chore; латиница в нижнем регистре, kebab-case)"

git_dir="$(git rev-parse --git-dir)"
for state in MERGE_HEAD rebase-merge rebase-apply CHERRY_PICK_HEAD REVERT_HEAD; do
  [ ! -e "$git_dir/$state" ] || fail "незавершённая операция git ($state) — заверши или отмени её"
done

[ -z "$(git status --porcelain)" ] || fail "есть незакоммиченные изменения — сначала /commit"

echo "$branch"

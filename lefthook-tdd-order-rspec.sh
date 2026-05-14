# shellcheck shell=bash
# Lefthook-compatible TDD order enforcer for RSpec.
# Verifies every commit touching app/**/*.rb or app/views/**/*.html.erb
# has its matching spec in the same commit tree.
# Config: LEFTHOOK_TDD_ORDER_BASE_REF (default: origin/main)
#         LEFTHOOK_TDD_ORDER_ALLOW_GAP=1 to bypass (emergency only)
# NOTE: sourced by writeShellApplication - no shebang or set needed.

if [ "${LEFTHOOK_TDD_ORDER_ALLOW_GAP:-0}" = "1" ]; then
    exit 0
fi

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT" || exit

base="${LEFTHOOK_TDD_ORDER_BASE_REF:-origin/main}"
if ! git rev-parse --verify --quiet "$base" >/dev/null; then
    exit 0
fi

rev_args=("$base..HEAD")
if [ -f .tdd-order-baseline ]; then
    baseline="$(sed -n '/^[^#[:space:]]/{p;q;}' .tdd-order-baseline | tr -d '[:space:]')"
    if [ -n "$baseline" ] &&
        git rev-parse --verify --quiet "${baseline}^{commit}" >/dev/null 2>&1; then
        rev_args+=("^$baseline")
    fi
fi

mapfile -t commits < <(git rev-list "${rev_args[@]}" 2>/dev/null)
if [ "${#commits[@]}" -eq 0 ]; then
    exit 0
fi

failed=0
for c in "${commits[@]}"; do
    while IFS= read -r f; do
        [ -n "$f" ] || continue
        bash @IS_SKIPPED_PATH@ "$f" && continue

        spec="$(bash @SPEC_PATH_FOR_PATH@ "$f")"
        [ -z "$spec" ] && continue

        if ! git cat-file -e "$c:$spec" 2>/dev/null; then
            printf 'tdd-order: %s touches %s but %s missing in its tree\n' \
                "$(git log -1 --format=%h "$c")" "$f" "$spec" >&2
            failed=1
        fi
    done < <(git show --no-renames --name-only --pretty=format: \
        --diff-filter=AM "$c" \
        -- ':(glob)app/**/*.rb' \
        ':(glob)app/views/**/*.html.erb' \
        2>/dev/null)
done

if [ "$failed" -ne 0 ]; then
    {
        echo
        echo "WARNING: spec gap(s) detected. Add the missing spec in"
        echo "         the same commit, or split the spec into an earlier"
        echo "         commit. Bypass: LEFTHOOK_TDD_ORDER_ALLOW_GAP=1"
    } >&2
    exit 1
fi
exit 0

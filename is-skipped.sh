# shellcheck shell=bash
# Checks if a given app file should be skipped from TDD order enforcement.
# Usage: bash is-skipped.sh <file-path>
# Exit 0 = skipped, Exit 1 = not skipped.
# Reads .structural-spec-allowlist from cwd if present.

f="$1"

SKIP_FILES=(
    "app/controllers/application_controller.rb"
    "app/models/application_record.rb"
    "app/mailers/application_mailer.rb"
    "app/helpers/application_helper.rb"
    "app/jobs/application_job.rb"
    "app/models/current.rb"
)

case "$f" in
    app/controllers/concerns/*) exit 0 ;;
    app/channels/application_cable/*) exit 0 ;;
    app/views/layouts/*) exit 0 ;;
esac

for s in "${SKIP_FILES[@]}"; do
    [ "$f" = "$s" ] && exit 0
done

case "$f" in
    app/controllers/*/base_controller.rb) exit 0 ;;
esac

declare -A allowlisted=()
if [ -f .structural-spec-allowlist ]; then
    while IFS= read -r line; do
        line="${line%%#*}"
        line="$(echo "$line" | xargs)"
        [ -z "$line" ] && continue
        allowlisted["$line"]=1
    done <.structural-spec-allowlist
fi

[ -n "${allowlisted[$f]:-}" ] && exit 0

exit 1

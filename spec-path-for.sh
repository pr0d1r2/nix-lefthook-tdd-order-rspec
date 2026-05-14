# shellcheck shell=bash
# Maps an app file path to its corresponding RSpec spec path.
# Usage: bash spec-path-for.sh <file-path>
# Echoes the spec path to stdout.

f="$1"

case "$f" in
    app/controllers/*)
        echo "$f" | sed 's|^app/controllers/|spec/requests/|; s|_controller\.rb$|_spec.rb|'
        ;;
    app/views/*)
        echo "$f" | sed 's|^app/views/|spec/views/|; s|\.html\.erb$|.html.erb_spec.rb|'
        ;;
    app/*)
        echo "$f" | sed 's|^app/|spec/|; s|\.rb$|_spec.rb|'
        ;;
esac

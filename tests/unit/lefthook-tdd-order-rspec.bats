#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TMP="$BATS_TEST_TMPDIR"
    git init "$TMP/repo" >/dev/null 2>&1
    cd "$TMP/repo" || return
    git config user.email "test@test.com"
    git config user.name "Test"
    touch README.md
    git add README.md
    git commit -m "initial" >/dev/null 2>&1
    git checkout -b work >/dev/null 2>&1
}

make_app_with_spec() {
    cd "$TMP/repo" || return
    mkdir -p app/models spec/models
    echo "class Foo; end" > app/models/foo.rb
    echo "RSpec.describe Foo" > spec/models/foo_spec.rb
    git add -A
    git commit -m "add foo with spec" >/dev/null 2>&1
}

make_app_without_spec() {
    cd "$TMP/repo" || return
    mkdir -p app/models
    echo "class Bar; end" > app/models/bar.rb
    git add -A
    git commit -m "add bar without spec" >/dev/null 2>&1
}

@test "no commits exits 0" {
    cd "$TMP/repo" || return
    # shellcheck disable=SC2030
    export LEFTHOOK_TDD_ORDER_BASE_REF="HEAD"
    run lefthook-tdd-order-rspec
    assert_success
}

@test "ALLOW_GAP=1 exits 0" {
    cd "$TMP/repo" || return
    make_app_without_spec
    # shellcheck disable=SC2031
    export LEFTHOOK_TDD_ORDER_BASE_REF="HEAD~1"
    # shellcheck disable=SC2030
    export LEFTHOOK_TDD_ORDER_ALLOW_GAP=1
    run lefthook-tdd-order-rspec
    assert_success
}

@test "app file with matching spec passes" {
    cd "$TMP/repo" || return
    make_app_with_spec
    # shellcheck disable=SC2031
    export LEFTHOOK_TDD_ORDER_BASE_REF="HEAD~1"
    run lefthook-tdd-order-rspec
    assert_success
}

@test "app file without matching spec fails" {
    cd "$TMP/repo" || return
    make_app_without_spec
    # shellcheck disable=SC2031
    export LEFTHOOK_TDD_ORDER_BASE_REF="HEAD~1"
    run lefthook-tdd-order-rspec
    assert_failure
    assert_output --partial "tdd-order"
    assert_output --partial "bar.rb"
}

@test "application_controller.rb is skipped" {
    cd "$TMP/repo" || return
    mkdir -p app/controllers
    echo "class ApplicationController; end" > app/controllers/application_controller.rb
    git add -A
    git commit -m "add application_controller" >/dev/null 2>&1
    # shellcheck disable=SC2031
    export LEFTHOOK_TDD_ORDER_BASE_REF="HEAD~1"
    run lefthook-tdd-order-rspec
    assert_success
}

@test "allowlisted file is skipped" {
    cd "$TMP/repo" || return
    mkdir -p app/models
    echo "class Baz; end" > app/models/baz.rb
    echo "app/models/baz.rb" > .structural-spec-allowlist
    git add -A
    git commit -m "add allowlisted baz" >/dev/null 2>&1
    # shellcheck disable=SC2031
    export LEFTHOOK_TDD_ORDER_BASE_REF="HEAD~1"
    run lefthook-tdd-order-rspec
    assert_success
}

@test "controller maps to requests spec" {
    cd "$TMP/repo" || return
    mkdir -p app/controllers spec/requests
    echo "class FoosController; end" > app/controllers/foos_controller.rb
    echo "RSpec.describe 'foos'" > spec/requests/foos_spec.rb
    git add -A
    git commit -m "add controller with request spec" >/dev/null 2>&1
    # shellcheck disable=SC2031
    export LEFTHOOK_TDD_ORDER_BASE_REF="HEAD~1"
    run lefthook-tdd-order-rspec
    assert_success
}

@test "base ref not found exits 0" {
    cd "$TMP/repo" || return
    make_app_without_spec
    # shellcheck disable=SC2031
    export LEFTHOOK_TDD_ORDER_BASE_REF="origin/nonexistent"
    run lefthook-tdd-order-rspec
    assert_success
}

@test "baseline file limits commit range" {
    cd "$TMP/repo" || return
    make_app_without_spec
    baseline_sha="$(git rev-parse HEAD)"
    make_app_with_spec
    echo "$baseline_sha" > .tdd-order-baseline
    git add .tdd-order-baseline
    git commit --amend --no-edit >/dev/null 2>&1
    # shellcheck disable=SC2031
    export LEFTHOOK_TDD_ORDER_BASE_REF="HEAD~2"
    run lefthook-tdd-order-rspec
    assert_success
}

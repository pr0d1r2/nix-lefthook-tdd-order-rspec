#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    SCRIPT="${BATS_TEST_DIRNAME}/../../is-skipped.sh"
    TMP="$BATS_TEST_TMPDIR"
    mkdir -p "$TMP"
    cd "$TMP" || return
}

@test "skips app/controllers/application_controller.rb" {
    run bash "$SCRIPT" "app/controllers/application_controller.rb"
    assert_success
}

@test "skips app/models/application_record.rb" {
    run bash "$SCRIPT" "app/models/application_record.rb"
    assert_success
}

@test "skips app/mailers/application_mailer.rb" {
    run bash "$SCRIPT" "app/mailers/application_mailer.rb"
    assert_success
}

@test "skips app/helpers/application_helper.rb" {
    run bash "$SCRIPT" "app/helpers/application_helper.rb"
    assert_success
}

@test "skips app/jobs/application_job.rb" {
    run bash "$SCRIPT" "app/jobs/application_job.rb"
    assert_success
}

@test "skips app/models/current.rb" {
    run bash "$SCRIPT" "app/models/current.rb"
    assert_success
}

@test "skips app/controllers/concerns/ files" {
    run bash "$SCRIPT" "app/controllers/concerns/authenticatable.rb"
    assert_success
}

@test "skips app/channels/application_cable/ files" {
    run bash "$SCRIPT" "app/channels/application_cable/connection.rb"
    assert_success
}

@test "skips app/views/layouts/ files" {
    run bash "$SCRIPT" "app/views/layouts/application.html.erb"
    assert_success
}

@test "skips base_controller.rb in nested controllers" {
    run bash "$SCRIPT" "app/controllers/api/base_controller.rb"
    assert_success
}

@test "does not skip regular model" {
    run bash "$SCRIPT" "app/models/user.rb"
    assert_failure
}

@test "does not skip regular controller" {
    run bash "$SCRIPT" "app/controllers/users_controller.rb"
    assert_failure
}

@test "does not skip regular mailer" {
    run bash "$SCRIPT" "app/mailers/user_mailer.rb"
    assert_failure
}

@test "does not skip regular helper" {
    run bash "$SCRIPT" "app/helpers/users_helper.rb"
    assert_failure
}

@test "does not skip regular job" {
    run bash "$SCRIPT" "app/jobs/cleanup_job.rb"
    assert_failure
}

@test "skips file listed in .structural-spec-allowlist" {
    echo "app/models/special.rb" > "$TMP/.structural-spec-allowlist"
    run bash "$SCRIPT" "app/models/special.rb"
    assert_success
}

@test "does not skip file not in .structural-spec-allowlist" {
    echo "app/models/other.rb" > "$TMP/.structural-spec-allowlist"
    run bash "$SCRIPT" "app/models/user.rb"
    assert_failure
}

@test "allowlist ignores comments" {
    printf '%s\n' "# this is a comment" "app/models/special.rb" > "$TMP/.structural-spec-allowlist"
    run bash "$SCRIPT" "app/models/special.rb"
    assert_success
}

@test "allowlist ignores blank lines" {
    printf '%s\n' "" "app/models/special.rb" "" > "$TMP/.structural-spec-allowlist"
    run bash "$SCRIPT" "app/models/special.rb"
    assert_success
}

@test "allowlist handles inline comments" {
    printf '%s\n' "app/models/special.rb # legacy" > "$TMP/.structural-spec-allowlist"
    run bash "$SCRIPT" "app/models/special.rb"
    assert_success
}

@test "no allowlist file does not skip regular file" {
    run bash "$SCRIPT" "app/models/user.rb"
    assert_failure
}

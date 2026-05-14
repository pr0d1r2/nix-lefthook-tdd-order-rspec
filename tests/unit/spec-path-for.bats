#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    SCRIPT="${BATS_TEST_DIRNAME}/../../spec-path-for.sh"
}

@test "controller maps to requests spec" {
    run bash "$SCRIPT" "app/controllers/foos_controller.rb"
    assert_success
    assert_output "spec/requests/foos_spec.rb"
}

@test "nested controller maps to nested requests spec" {
    run bash "$SCRIPT" "app/controllers/api/v1/users_controller.rb"
    assert_success
    assert_output "spec/requests/api/v1/users_spec.rb"
}

@test "model maps to spec/models" {
    run bash "$SCRIPT" "app/models/user.rb"
    assert_success
    assert_output "spec/models/user_spec.rb"
}

@test "mailer maps to spec/mailers" {
    run bash "$SCRIPT" "app/mailers/user_mailer.rb"
    assert_success
    assert_output "spec/mailers/user_mailer_spec.rb"
}

@test "helper maps to spec/helpers" {
    run bash "$SCRIPT" "app/helpers/users_helper.rb"
    assert_success
    assert_output "spec/helpers/users_helper_spec.rb"
}

@test "job maps to spec/jobs" {
    run bash "$SCRIPT" "app/jobs/cleanup_job.rb"
    assert_success
    assert_output "spec/jobs/cleanup_job_spec.rb"
}

@test "view maps to spec/views with erb_spec.rb suffix" {
    run bash "$SCRIPT" "app/views/users/index.html.erb"
    assert_success
    assert_output "spec/views/users/index.html.erb_spec.rb"
}

@test "nested view maps correctly" {
    run bash "$SCRIPT" "app/views/admin/users/show.html.erb"
    assert_success
    assert_output "spec/views/admin/users/show.html.erb_spec.rb"
}

@test "service maps to spec/services" {
    run bash "$SCRIPT" "app/services/payment_service.rb"
    assert_success
    assert_output "spec/services/payment_service_spec.rb"
}

@test "non-app path produces no output" {
    run bash "$SCRIPT" "lib/something.rb"
    assert_success
    assert_output ""
}

# nix-lefthook-tdd-order-rspec

[![CI](https://github.com/pr0d1r2/nix-lefthook-tdd-order-rspec/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-lefthook-tdd-order-rspec/actions/workflows/ci.yml)

> This code is LLM-generated and validated through an automated integration process using [lefthook](https://github.com/evilmartians/lefthook) git hooks, [bats](https://github.com/bats-core/bats-core) unit tests, and GitHub Actions CI.

Lefthook-compatible TDD order enforcer for [RSpec](https://rspec.info/), packaged as a Nix flake.

Verifies every commit touching `app/**/*.rb` or `app/views/**/*.html.erb` has its matching spec in the same commit tree. Enforces test-driven development discipline by catching spec gaps before push.

## Usage

### Option A: Lefthook remote (recommended)

Add to your `lefthook.yml` — no flake input needed, just the wrapper binary in your devShell:

```yaml
remotes:
  - git_url: https://github.com/pr0d1r2/nix-lefthook-tdd-order-rspec
    ref: main
    configs:
      - lefthook-remote.yml
```

### Option B: Flake input

Add as a flake input:

```nix
inputs.nix-lefthook-tdd-order-rspec = {
  url = "github:pr0d1r2/nix-lefthook-tdd-order-rspec";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Add to your devShell:

```nix
nix-lefthook-tdd-order-rspec.packages.${pkgs.stdenv.hostPlatform.system}.default
```

Add to `lefthook.yml`:

```yaml
pre-push:
  commands:
    tdd-order-rspec:
      run: timeout ${LEFTHOOK_TDD_ORDER_RSPEC_TIMEOUT:-30} lefthook-tdd-order-rspec
```

### Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `LEFTHOOK_TDD_ORDER_BASE_REF` | `origin/main` | Base ref for commit range |
| `LEFTHOOK_TDD_ORDER_ALLOW_GAP` | `0` | Set to `1` to bypass (emergency only) |

### Skip files

Standard Rails files are skipped automatically (`application_controller.rb`, `application_record.rb`, etc.).

For project-specific skips, create `.structural-spec-allowlist` with one path per line:

```text
app/models/current.rb
app/controllers/concerns/authenticatable.rb
```

### Baseline

To start enforcing from a specific commit (ignoring older history), create `.tdd-order-baseline` with the commit SHA:

```text
abc1234
```

### Configuring timeout

The default timeout is 30 seconds. Override per-repo via environment variable:

```bash
export LEFTHOOK_TDD_ORDER_RSPEC_TIMEOUT=60
```

## Development

The repo includes an `.envrc` for [direnv](https://direnv.net/) — entering the directory automatically loads the devShell with all dependencies:

```bash
cd nix-lefthook-tdd-order-rspec  # direnv loads the flake
bats tests/unit/
```

If not using direnv, enter the shell manually:

```bash
nix develop
bats tests/unit/
```

## License

MIT

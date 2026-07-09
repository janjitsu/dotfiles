#!/bin/bash
############################
# test/test.sh
# Builds a systemd-enabled container for the given distro, copies the
# current working tree in, runs the full setup.sh (desktop apps included —
# this is not testing --no-desktop), and reports pass/fail. The container
# and image are always removed afterwards, pass or fail.
#
# arm-alpine/arm-ubuntu test setup/arm.sh directly (not setup.sh) against
# plain, non-privileged containers on the host's native architecture — no
# real aarch64 emulation is available here, and setup/arm.sh never touches
# systemd anyway, so there's nothing architecture-specific being exercised:
# just package-manager detection, dependency installs, and symlinks. The
# Termux/`pkg` variant (setup/arm/deps-pkg.sh) can't be tested this way
# since `pkg` only exists inside real Termux.
#
# This is a heavy end-to-end smoke test (real package installs, real
# downloads) meant to be run on demand before a release, not on every commit.
#
# Usage:
#   test/test.sh ubuntu
#   test/test.sh fedora
#   test/test.sh arm-alpine
#   test/test.sh arm-ubuntu
#   test/test.sh all
############################

set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$DIR/.." && pwd)"

run_test() {
    local distro="$1"
    local image="dotfiles-test-$distro"
    local container="dotfiles-test-$distro-run"

    echo "=== [$distro] Building image ==="
    if ! docker build -f "$DIR/Dockerfile.$distro" -t "$image" "$REPO_ROOT"; then
        echo "=== [$distro] FAIL (build) ==="
        return 1
    fi

    echo "=== [$distro] Starting systemd container ==="
    # --cgroupns=host: needed when the Docker host itself runs inside a
    # container (e.g. CI, sandboxed dev environments) — without it, the
    # nested private cgroup namespace conflicts with systemd's own cgroup
    # management and it fails to boot (exit 255, no log output).
    docker rm -f "$container" >/dev/null 2>&1 || true
    docker run -d --name "$container" --privileged --cgroupns=host \
        --tmpfs /tmp --tmpfs /run --tmpfs /run/lock \
        -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
        "$image" >/dev/null

    echo "=== [$distro] Waiting for systemd to reach a stable state ==="
    docker exec "$container" systemctl is-system-running --wait >/dev/null 2>&1 || true

    echo "=== [$distro] Running full setup.sh (desktop + apps included) ==="
    local result=0
    if docker exec "$container" bash -lc "cd /root/dotfiles && bash setup.sh"; then
        echo "=== [$distro] PASS ==="
    else
        echo "=== [$distro] FAIL (setup.sh) ==="
        result=1
    fi

    echo "=== [$distro] Cleaning up ==="
    docker rm -f "$container" >/dev/null 2>&1
    docker rmi -f "$image" >/dev/null 2>&1

    return $result
}

run_test_arm() {
    local variant="$1"
    local image="dotfiles-test-$variant"
    local container="dotfiles-test-$variant-run"

    echo "=== [$variant] Building image ==="
    if ! docker build -f "$DIR/Dockerfile.$variant" -t "$image" "$REPO_ROOT"; then
        echo "=== [$variant] FAIL (build) ==="
        return 1
    fi

    echo "=== [$variant] Starting container ==="
    docker rm -f "$container" >/dev/null 2>&1 || true
    docker run -d --name "$container" "$image" sleep infinity >/dev/null

    echo "=== [$variant] Running setup/arm.sh ==="
    local result=0
    if docker exec "$container" bash -lc "cd /root/dotfiles && bash setup/arm.sh"; then
        echo "=== [$variant] PASS ==="
    else
        echo "=== [$variant] FAIL (arm.sh) ==="
        result=1
    fi

    echo "=== [$variant] Cleaning up ==="
    docker rm -f "$container" >/dev/null 2>&1
    docker rmi -f "$image" >/dev/null 2>&1

    return $result
}

targets="${1:-all}"
overall=0

case "$targets" in
    ubuntu|fedora)
        run_test "$targets" || overall=1
        ;;
    arm-alpine|arm-ubuntu)
        run_test_arm "$targets" || overall=1
        ;;
    all)
        run_test ubuntu || overall=1
        run_test fedora || overall=1
        run_test_arm arm-alpine || overall=1
        run_test_arm arm-ubuntu || overall=1
        ;;
    *)
        echo "Usage: $0 [ubuntu|fedora|arm-alpine|arm-ubuntu|all]" >&2
        exit 2
        ;;
esac

exit $overall

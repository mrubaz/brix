#!/usr/bin/env bash
# Everything CI checks, in one command. Run it before every release:
# format, analyze and tests of every package, the example apps, the brix_cli
# template, an app made with `brix create`, and the public API check.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
native_root="$root"
if command -v cygpath >/dev/null 2>&1; then
  native_root="$(cygpath -m "$root")"
fi

step() { echo; echo "── $*"; }

check_dart() {
  step "$1"
  cd "$root/packages/$1"
  dart pub get > /dev/null
  dart format --output=none --set-exit-if-changed "${@:2}"
  dart analyze --fatal-infos
  dart test
}

check_flutter() {
  step "$1"
  cd "$root/packages/$1"
  flutter pub get > /dev/null
  dart format --output=none --set-exit-if-changed "${@:2}"
  flutter analyze --fatal-infos
  flutter test
}

check_app() {
  step "$1"
  cd "$root/$1"
  flutter pub get > /dev/null
  flutter analyze --fatal-infos
  flutter test
}

check_dart brix lib test example
(cd "$root/packages/brix" && dart run example/main.dart > /dev/null)
check_dart brix_network lib test example
check_flutter brix_storage lib test example
check_flutter brix_ui lib test example/lib example/test
check_app packages/brix_ui/example
check_flutter brix_getx lib test example/lib example/test
check_app packages/brix_getx/example
check_flutter brix_riverpod lib test example/lib example/test
check_app packages/brix_riverpod/example
check_flutter brix_bloc lib test example/lib example/test
check_app packages/brix_bloc/example
check_dart brix_cli lib test bin templates/*/lib templates/*/test
for state in getx bloc riverpod; do
  check_app "packages/brix_cli/templates/$state"
done

step "brix create"
app_dir="$(mktemp -d)"
trap 'rm -rf "$app_dir"' EXIT
cd "$app_dir"
for state in getx bloc riverpod; do
  dart run "$root/packages/brix_cli/bin/brix.dart" create "check_$state" --state "$state" > /dev/null
  cat > "check_$state/pubspec_overrides.yaml" <<YAML
dependency_overrides:
  brix: {path: $native_root/packages/brix}
  brix_$state: {path: $native_root/packages/brix_$state}
  brix_network: {path: $native_root/packages/brix_network}
  brix_storage: {path: $native_root/packages/brix_storage}
  brix_ui: {path: $native_root/packages/brix_ui}
YAML
  (cd "$app_dir/check_$state" && flutter pub get > /dev/null && flutter analyze --fatal-infos && flutter test)
done

step "Public API"
"$root/tool/api_check.sh"

echo
echo "Ready to release."

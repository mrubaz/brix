#!/bin/bash
# Makes a state package's example with `brix create`, so every example is
# the same app as the one a user gets, on the brix packages in this repo.
#
#   tool/make_example.sh brix_getx
#
# Run it again after a change to the brix_cli template.
set -euo pipefail

package="${1:?Give the package, for example: tool/make_example.sh brix_getx}"
root="$(cd "$(dirname "$0")/.." && pwd)"
target="$root/packages/$package/example"
name="${package}_example"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "Creating $name with brix create ..."
(cd "$tmp" && dart run "$root/packages/brix_cli/bin/brix.dart" create "$name" --org dev.brix > /dev/null)
app="$tmp/$name"

# Phones and the web are enough for an example.
rm -rf "$app/macos" "$app/linux" "$app/windows" "$app/build" "$app/.dart_tool"

# Develop against the packages in this repo, not the ones on pub.dev.
cat > "$app/pubspec_overrides.yaml" << 'YAML'
# Run the example against the brix in this repo, not the one on pub.dev.
dependency_overrides:
  brix:
    path: ../../brix
  brix_getx:
    path: ../../brix_getx
  brix_network:
    path: ../../brix_network
  brix_storage:
    path: ../../brix_storage
  brix_ui:
    path: ../../brix_ui
YAML

rm -rf "${target:?}"
cp -R "$app" "$target"
(cd "$target" && flutter pub get > /dev/null)
echo "Done: packages/$package/example"

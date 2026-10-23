#!/usr/bin/env bash
# Build every template from scratch and the demo paper with ./build.sh, then validate.
#
# Usage: tests/run-tests.sh [--setup]
#   --setup  first install the toolchain (pandoc, pandoc-crossref, TinyTeX if no
#            system TeX, Python packages) with ./build.sh setup; used in CI.
#
# Tools are shared between the test projects through PAPER_FORGE_TOOLS and
# PAPER_FORGE_VENV (default: tests/.cache). Without --setup, an existing cache
# or tools on PATH are used.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PAPER_FORGE_TOOLS="${PAPER_FORGE_TOOLS:-$ROOT/tests/.cache/tools}"
export PAPER_FORGE_VENV="${PAPER_FORGE_VENV:-$ROOT/tests/.cache/venv}"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/paper-forge-tests.XXXXXX")"
TEMPLATES="ieee-conference ieee-journal acm springer-lncs elsevier generic-article"
failed=0

pass() { echo "PASS  $1"; }
fail() { echo "FAIL  $1${2:+ ($2)}"; failed=1; }

# new_project DIR TEMPLATE [demo]
new_project() {
  mkdir -p "$1"
  cp -R "$ROOT/templates/common/." "$1/"
  if [ "${3:-}" = demo ]; then
    cp -R "$ROOT/tests/demo-paper/." "$1/"
    rm -rf "$1/build" "$1/latex/generated"
  fi
  cp -R "$ROOT/templates/$2/." "$1/"
}

build() {
  local name="$1" dir="$2"
  if (cd "$dir" && ./build.sh >"$WORK/$name.log" 2>&1); then
    pass "$name"
  else
    fail "$name" "$(grep -m1 '^FAILED' "$WORK/$name.log" || tail -1 "$WORK/$name.log")"
  fi
}

if [ "${1:-}" = --setup ]; then
  new_project "$WORK/setup" ieee-conference
  if (cd "$WORK/setup" && ./build.sh setup); then pass setup; else fail setup; exit 1; fi
fi

for template in $TEMPLATES; do
  new_project "$WORK/fresh-$template" "$template"
  build "fresh-$template" "$WORK/fresh-$template"
done

# The demo paper itself (ieee-conference), then its content with every other template.
demo="$WORK/demo-paper"
cp -R "$ROOT/tests/demo-paper" "$demo"
rm -rf "$demo/build" "$demo/latex/generated"
build demo-paper "$demo"
for template in $TEMPLATES; do
  [ "$template" = ieee-conference ] && continue
  new_project "$WORK/demo-$template" "$template" demo
  build "demo-$template" "$WORK/demo-$template"
  grep -q 'check: 0 error' "$WORK/demo-$template.log" || fail "check demo-$template"
done

if (cd "$demo" && ./build.sh check --max-pages 6 >"$WORK/check.log"); then
  pass "check demo-paper"
else
  fail "check demo-paper" "see $WORK/check.log"
fi

if (cd "$demo" && ./build.sh snapshot 01-test >/dev/null) &&
   test -f "$demo/drafts/01-test/paper.pdf" &&
   test -f "$demo/drafts/01-test/paper/sections/01-introduction.md" &&
   ! (cd "$demo" && ./build.sh snapshot 01-test >/dev/null 2>&1) &&
   ! (cd "$demo" && ./build.sh snapshot 00-raw >/dev/null 2>&1); then
  pass "snapshot demo-paper"
else
  fail "snapshot demo-paper"
fi

# A broken build must report the failing Markdown source.
broken="$WORK/broken"
cp -R "$demo" "$broken"
printf '\nThis sentence uses an \\undefinedmacro here.\n' >>"$broken/paper/sections/06-conclusion.md"
(cd "$broken" && ./build.sh >"$WORK/broken.log" 2>&1) || true
if grep -q '^FAILED latex' "$WORK/broken.log" && grep -q 'at: paper/sections/06-conclusion.md' "$WORK/broken.log"; then
  pass "diagnose broken build"
else
  fail "diagnose broken build" "see $WORK/broken.log"
fi

if [ "$failed" -eq 0 ]; then
  rm -rf "$WORK"
else
  echo "logs kept in $WORK"
fi
exit "$failed"

#!/usr/bin/env bash
#
# auto_build.sh - tu dong build LaTeX bang latexmk.
# Build project LaTeX theo FOLDER ban dang dung (current directory).
# Neu folder hien tai khong co main.tex, script tu tim trong cac thu muc con.

set -euo pipefail

usage() {
  cat <<'EOF'
auto_build.sh - tu dong build LaTeX bang latexmk

No build theo FOLDER ban dang dung (current directory).

Cach dung:
  cd <folder-co-main.tex>
  ./auto_build.sh             Watch mode: luu file la tu build lai + mo Evince (Ctrl+C de dung)
  ./auto_build.sh --once      Build mot lan roi thoat
  ./auto_build.sh --clean     Don file sinh ra (.aux/.log/...) roi build lai mot lan
  ./auto_build.sh <duong-dan> Build project o duong dan chi dinh (folder hoac main.tex)
  ./auto_build.sh --help      Hien tro giup nay

Neu folder hien tai khong co main.tex, script se tu tim trong cac thu muc con.
EOF
}

MODE="watch"
TARGET=""
for arg in "$@"; do
  case "$arg" in
    --once)    MODE="once" ;;
    --clean)   MODE="clean" ;;
    --watch)   MODE="watch" ;;
    -h|--help) usage; exit 0 ;;
    -*)        echo "Tham so khong hop le: $arg" >&2; usage; exit 1 ;;
    *)         TARGET="$arg" ;;
  esac
done

# Chon thu muc project + file main theo folder dang dung
if [[ -n "$TARGET" ]]; then
  if [[ -f "$TARGET" ]]; then
    PROJECT_DIR="$(cd "$(dirname "$TARGET")" && pwd)"; MAIN="$(basename "$TARGET")"
  else
    PROJECT_DIR="$(cd "$TARGET" && pwd)"; MAIN="main.tex"
  fi
elif [[ -f "./main.tex" ]]; then
  PROJECT_DIR="$(pwd)"; MAIN="main.tex"
else
  # Khong co main.tex ngay tai day -> tim trong cac thu muc con
  mapfile -t FOUND < <(find . -maxdepth 6 -name 'main.tex' \
      -not -path '*/archive/*' -not -path '*/.git/*' -not -path '*/.omc/*' 2>/dev/null)
  if [[ ${#FOUND[@]} -eq 1 ]]; then
    PROJECT_DIR="$(cd "$(dirname "${FOUND[0]}")" && pwd)"; MAIN="main.tex"
  elif [[ ${#FOUND[@]} -eq 0 ]]; then
    echo "ERROR: khong tim thay main.tex tai '$(pwd)' hay thu muc con." >&2
    echo "Hay 'cd' vao folder co main.tex, hoac chay: ./auto_build.sh <duong-dan>" >&2
    exit 1
  else
    echo "Tim thay nhieu main.tex, hay chon 1 (cd vao do hoac truyen duong dan):" >&2
    printf '  %s\n' "${FOUND[@]}" >&2
    exit 1
  fi
fi

cd "$PROJECT_DIR"
[[ -f "$MAIN" ]] || { echo "ERROR: khong thay $MAIN trong $PROJECT_DIR" >&2; exit 1; }

echo ">> Project: $PROJECT_DIR"
echo ">> Main:    $MAIN"

case "$MODE" in
  once)
    echo ">> Build mot lan..."
    latexmk -pdf "$MAIN"
    ;;
  clean)
    echo ">> Clean roi build lai..."
    latexmk -C "$MAIN" >/dev/null 2>&1 || true
    latexmk -pdf "$MAIN"
    ;;
  watch)
    echo ">> WATCH: luu file (Ctrl+S) la tu build lai. Bam Ctrl+C de dung."
    latexmk -pdf -pvc "$MAIN"
    ;;
esac

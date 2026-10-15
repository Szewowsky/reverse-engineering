#!/bin/bash
# Transkrypt filmu z timestampami: napisy (ręczne albo automatyczne) przez yt-dlp,
# bez pobierania wideo. Wynik w ./dowody/ (uruchamiaj w folderze re-<nazwa-celu>/).
#
# Użycie: transkrypt.sh <url> [języki]     języki domyślnie: pl,en (pierwszy znaleziony wygrywa)
#         transkrypt.sh <plik.vtt>          sama konwersja gotowego pliku vtt
#
# Kody wyjścia: 0 ok, 1 błąd pobrania/konwersji, 2 brak yt-dlp.
set -u

DOWODY="dowody"
OUT="$DOWODY/transkrypt.txt"
META="$DOWODY/film.txt"

if [ $# -lt 1 ]; then
  echo "Użycie: $0 <url> [języki, np. pl,en]   albo   $0 <plik.vtt>" >&2
  exit 1
fi
SRC="$1"
LANGS="${2:-pl,en}"

# vtt -> "[mm:ss] tekst": jedna linia na fragment (minuty liczone łącznie, np. [75:12]), bez tagów <c> i znaczników czasu
# w środku linii, bez powtórzeń z przewijanych napisów automatycznych.
vtt_to_txt() {
  awk '
    function stamp(t,   a, n, h, m, s) {
      n = split(t, a, ":")
      if (n == 3) { h = a[1]; m = a[2]; s = a[3] } else { h = 0; m = a[1]; s = a[2] }
      sub(/[.,].*/, "", s)
      return sprintf("[%02d:%02d]", h * 60 + m, s)
    }
    function flush(   i, out) {
      out = ""
      for (i = 1; i <= nl; i++) out = out (out == "" ? "" : " ") buf[i]
      if (out != "") print cur " " out
      nl = 0
    }
    { sub(/\r$/, "") }
    /-->/ { flush(); cur = stamp($1); incue = 1; next }
    /^$/ { flush(); incue = 0; next }
    incue {
      line = $0
      gsub(/<[^>]*>/, "", line)
      gsub(/&nbsp;/, " ", line); gsub(/&amp;/, "\\&", line)
      gsub(/&lt;/, "<", line); gsub(/&gt;/, ">", line)
      gsub(/[[:space:]]+/, " ", line)
      sub(/^ /, "", line); sub(/ $/, "", line)
      if (line == "" || line == last1 || line == last2) next
      buf[++nl] = line
      last2 = last1; last1 = line
    }
    END { flush() }
  ' "$1"
}

summary() {
  local lines last
  lines=$(wc -l < "$OUT" | tr -d ' ')
  last=$(tail -n 1 "$OUT" | cut -d' ' -f1)
  echo "Transkrypt: $OUT ($lines linii, ostatni fragment $last)"
  [ -f "$META" ] && echo "Metadane:   $META ($(grep -m1 '^Długość:' "$META" || echo 'Długość: ?'))"
  [ -n "${1:-}" ] && echo "Napisy:     $1"
}

mkdir -p "$DOWODY"

if [ -f "$SRC" ]; then
  vtt_to_txt "$SRC" > "$OUT" || exit 1
  summary "$SRC"
  exit 0
fi

if ! command -v yt-dlp >/dev/null 2>&1; then
  echo "Brak yt-dlp. Zainstaluj jedną z komend i uruchom skrypt ponownie:" >&2
  echo "  brew install yt-dlp" >&2
  echo "  pip3 install yt-dlp" >&2
  exit 2
fi

rm -f "$DOWODY"/film.*.vtt
if ! yt-dlp --skip-download --write-subs --write-auto-subs \
      --sub-langs "$LANGS" --sub-format vtt \
      -o "$DOWODY/film.%(ext)s" \
      --print-to-file "Tytuł: %(title)s" "$META.tmp" \
      --print-to-file "Kanał: %(channel)s" "$META.tmp" \
      --print-to-file "Data: %(upload_date>%Y-%m-%d)s" "$META.tmp" \
      --print-to-file "Długość: %(duration>%H:%M:%S)s" "$META.tmp" \
      --print-to-file "URL: %(webpage_url)s" "$META.tmp" \
      --print-to-file "Opis:
%(description)s" "$META.tmp" \
      --quiet --no-warnings "$SRC"; then
  if [ -s "$META.tmp" ]; then mv -f "$META.tmp" "$META"; echo "Metadane zapisane mimo błędu: $META" >&2; else rm -f "$META.tmp"; fi
  echo "yt-dlp nie pobrał napisów (np. HTTP 429 albo film bez napisów)." >&2
  echo "Druga droga: wklej transkrypt z YouTube (\"Pokaż transkrypcję\") do $OUT." >&2
  exit 1
fi
mv -f "$META.tmp" "$META"

VTT=""
IFS=',' read -ra ORDER <<< "$LANGS"
for l in "${ORDER[@]}"; do
  if [ -f "$DOWODY/film.$l.vtt" ]; then VTT="$DOWODY/film.$l.vtt"; break; fi
done
[ -z "$VTT" ] && VTT=$(ls "$DOWODY"/film.*.vtt 2>/dev/null | head -n 1)
if [ -z "$VTT" ]; then
  echo "Film nie ma napisów w językach: $LANGS. Podaj inne języki albo wklej transkrypt do $OUT." >&2
  exit 1
fi

vtt_to_txt "$VTT" > "$OUT" || exit 1
echo "Język napisów: $(basename "$VTT" | cut -d. -f2)" >> "$META"
summary "$VTT"

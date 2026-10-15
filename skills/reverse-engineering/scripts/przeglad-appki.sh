#!/bin/bash
# Najtańszy przegląd appki na dysku: tylko czyta cel, wyniki zapisuje do ./dowody/.
# Użycie: przeglad-appki.sh <ścieżka do .app | binarki | katalogu paczki npm | .asar | .zip | .tgz | .dmg>
# Narzędzia: wyłącznie wbudowane w macOS. Kolejne uruchomienie nadpisuje pliki 00-06.
set -u
export LC_ALL=C

if [ $# -ne 1 ] || [ ! -e "$1" ]; then
  echo "Użycie: $(basename "$0") <ścieżka do celu>" >&2
  echo "Cel: .app, binarka, katalog paczki npm, .asar, .zip, .tgz albo .dmg" >&2
  exit 1
fi

CEL="${1%/}"
OUT="$PWD/dowody"
case "$OUT/" in "$CEL"/*) echo "Uruchom skrypt poza folderem celu (dowody/ nie może trafić do celu)." >&2; exit 1;; esac
mkdir -p "$OUT"
P0="$OUT/00-przeglad.txt"; P1="$OUT/01-pliki.txt"; P2="$OUT/02-strings.txt"
P3="$OUT/03-urls.txt"; P4="$OUT/04-symbole.txt"; P5="$OUT/05-plist-lub-package.txt"
P6="$OUT/06-sekrety-UWAGA.txt"
for f in "$P0" "$P1" "$P2" "$P3" "$P4" "$P5" "$P6"; do : > "$f"; done

TYP="nieznany"; MULTI_ASAR=0; BIN=""; PLIST=""; PKG=""; WERSJA="nie znaleziono"; LICENCJA=""; UWAGI=""

# Odczyt nagłówka asar bez instalacji: bajty 12-15 = długość JSON, JSON od bajtu 16.
asar_naglowek() {
  local dl
  dl=$(od -An -tu4 -j12 -N4 "$1" | tr -d ' ')
  [ -n "$dl" ] && tail -c +17 "$1" | head -c "$dl"
}

pole_json() { grep -m1 -E "\"$1\"[[:space:]]*:" "$2" | sed -E "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"?([^\",}]*)\"?.*/\1/"; }

if [ -d "$CEL" ] && [ -f "$CEL/Contents/Info.plist" ]; then
  PLIST="$CEL/Contents/Info.plist"
  EXE=$(plutil -extract CFBundleExecutable raw -o - "$PLIST" 2>/dev/null)
  [ -n "$EXE" ] && BIN="$CEL/Contents/MacOS/$EXE"
  ASAR=$(find "$CEL/Contents/Resources" -maxdepth 1 -name 'app.asar' 2>/dev/null | head -1)
  if [ -d "$CEL/Contents/Frameworks/Electron Framework.framework" ] || [ -n "$ASAR" ]; then
    TYP="aplikacja Electron (.app)"
    if [ -n "$ASAR" ]; then
      UWAGI="Binarka główna to ogólny Electron; napisy (02) pochodzą ze wszystkich .asar w Contents/Resources (linia '=== PLIK:' otwiera każdy)."
      BIN="$ASAR"; MULTI_ASAR=1
    fi
  else
    TYP="natywna aplikacja macOS (.app)"
  fi
  WERSJA="$(plutil -extract CFBundleShortVersionString raw -o - "$PLIST" 2>/dev/null) (build $(plutil -extract CFBundleVersion raw -o - "$PLIST" 2>/dev/null))"
  LICENCJA=$(plutil -extract NSHumanReadableCopyright raw -o - "$PLIST" 2>/dev/null)
elif [ -d "$CEL" ] && [ -f "$CEL/package.json" ]; then
  TYP="paczka npm (katalog)"; PKG="$CEL/package.json"
  WERSJA=$(pole_json version "$PKG"); LICENCJA=$(pole_json license "$PKG")
  MAIN=$(pole_json main "$PKG")
  if [ -n "$MAIN" ] && [ -f "$CEL/$MAIN" ]; then BIN="$CEL/$MAIN"
  else BIN=$(find "$CEL" -name '*.js' -not -path '*/node_modules/*' -type f -exec stat -f '%z %N' {} + 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
  fi
elif [ -d "$CEL" ]; then
  TYP="katalog (bez Info.plist i package.json)"
  UWAGI="Wskaż konkretną .app, paczkę z package.json albo binarkę z listy 01, żeby dostać napisy (02)."
elif [ -f "$CEL" ]; then
  case "$CEL" in
    *.asar) TYP="archiwum asar (Electron)"; BIN="$CEL" ;;
    *.zip)  TYP="archiwum zip" ;;
    *.tgz|*.tar.gz) TYP="archiwum tar (np. npm pack)" ;;
    *.dmg)  TYP="obraz dmg" ;;
    *) if file -b "$CEL" | grep -q 'Mach-O'; then TYP="binarka Mach-O"; BIN="$CEL"
       else TYP="plik: $(file -b "$CEL" | cut -c1-80)"; BIN="$CEL"; fi ;;
  esac
fi

# 01 - lista plików z rozmiarami (bajty), od największych
case "$TYP" in
  "archiwum zip") unzip -l "$CEL" > "$P1" 2>&1 ;;
  "archiwum tar"*) tar -tvzf "$CEL" > "$P1" 2>&1 ;;
  "obraz dmg") hdiutil imageinfo "$CEL" > "$P1" 2>&1
    UWAGI="Obraz dmg: tylko hdiutil imageinfo, bez montowania. Po zgodzie użytkownika: hdiutil attach -readonly -nobrowse, potem skrypt na .app ze środka." ;;
  "archiwum asar"*) asar_naglowek "$CEL" | grep -oE '"[^"]+":\{"(size|files|offset|unpacked|link)"' | sed -E 's/^"([^"]+)".*/\1/' > "$P1"
    echo "(nazwy wpisów z nagłówka JSON asar; pełny nagłówek: tail -c +17 plik.asar | head -c <długość>)" >> "$P1" ;;
  *) if [ -d "$CEL" ]; then find "$CEL" -type f -exec stat -f '%z %N' {} + 2>/dev/null | sort -rn > "$P1"
     else stat -f '%z %N' "$CEL" > "$P1"; fi ;;
esac

# zip/tgz: Info.plist albo package.json czytane strumieniem, bez rozpakowania na dysk
if [ "$TYP" = "archiwum zip" ]; then
  W=$(unzip -Z1 "$CEL" 2>/dev/null | grep -m1 -E '(^|/)Contents/Info\.plist$|(^|/)package\.json$')
  [ -n "$W" ] && unzip -p "$CEL" "$W" > "$P5.tmp" 2>/dev/null
  UWAGI="Archiwum zip: lista z unzip -l, napisy (02) puste. Rozpakuj do osobnego pustego folderu i uruchom skrypt na wyniku."
elif [ "$TYP" = "archiwum tar (np. npm pack)" ]; then
  W=$(tar -tzf "$CEL" 2>/dev/null | grep -m1 -E '(^|/)package\.json$')
  [ -n "$W" ] && tar -xOzf "$CEL" "$W" > "$P5.tmp" 2>/dev/null
  UWAGI="Archiwum tar: lista z tar -tvzf, napisy (02) puste. Rozpakuj do osobnego pustego folderu i uruchom skrypt na wyniku."
fi
if [ -f "$P5.tmp" ]; then
  if grep -q '<plist\|bplist' "$P5.tmp"; then plutil -p "$P5.tmp" > "$P5" 2>&1; WERSJA=$(grep -m1 CFBundleShortVersionString "$P5" | sed -E 's/.*=> "(.*)"/\1/')
  else cat "$P5.tmp" > "$P5"; WERSJA=$(pole_json version "$P5"); LICENCJA=$(pole_json license "$P5"); fi
  rm -f "$P5.tmp"
fi

# 05 - Info.plist / package.json
[ -n "$PLIST" ] && plutil -p "$PLIST" > "$P5" 2>&1
[ -n "$PKG" ] && cat "$PKG" > "$P5"

# Architektury; nm/otool czytają architekturę hosta, gdy binarka jest universal
ARCH=""; ARCHS="nie dotyczy"
if [ -n "$BIN" ] && file -b "$BIN" | grep -q 'Mach-O'; then
  ARCHS=$(lipo -archs "$BIN" 2>/dev/null || file -b "$BIN" | head -1)
  H=$(uname -m); case " $ARCHS " in *" $H "*) [ "$(echo "$ARCHS" | wc -w)" -gt 1 ] && ARCH="$H" ;; esac
fi

# 02 - napisy ze wszystkich architektur (slice x86_64 bywa bogatszy niż arm64), numerowane
if [ "$MULTI_ASAR" = 1 ]; then
  for a in "$CEL"/Contents/Resources/*.asar; do echo "=== PLIK: $a"; strings -a -n 6 "$a"; done | nl -ba > "$P2"
elif [ -n "$BIN" ] && [ -f "$BIN" ]; then
  strings -a -n 6 "$BIN" | nl -ba > "$P2"
fi

# 03 - URL-e i ścieżki z 02 (pierwsza kolumna = numer linii w 02)
grep -E 'https?://|wss?://|~/|/Users/|\.json|\.plist' "$P2" > "$P3"

# 04 - biblioteki i symbole (tylko Mach-O)
if [ -n "$ARCHS" ] && [ "$ARCHS" != "nie dotyczy" ]; then
  AFLAG=(); [ -n "$ARCH" ] && AFLAG=(-arch "$ARCH")
  { echo "== otool -L (biblioteki ładowane przez binarkę) =="
    otool ${AFLAG[@]+"${AFLAG[@]}"} -L "$BIN"
    echo; echo "== nm -gU (symbole zdefiniowane, eksportowane) =="
    nm ${AFLAG[@]+"${AFLAG[@]}"} -gU "$BIN" 2>&1
    echo; echo "== nm -u (symbole importowane) =="
    nm ${AFLAG[@]+"${AFLAG[@]}"} -u "$BIN" 2>&1
  } > "$P4"
fi

# 06 - linie z możliwymi sekretami. Skracane do 4 znaków + …: wartość po = lub :
# oraz każdy ciąg 20+ znaków z literami i cyframi (wygląda na klucz). Nazwy bez cyfr zostają.
grep -iE 'token|secret|password|api[_-]?key' "$P2" \
  | sed -E "s/([=:][[:space:]]*[\"']?)([^\"'[:space:],;&\/]{4})[^\"'[:space:],;&]+/\1\2…/g" \
  | awk '{ out=""; s=$0
      while (match(s, /[A-Za-z0-9_+\/=-]+/)) {
        t=substr(s, RSTART, RLENGTH)
        if (RLENGTH >= 20 && t ~ /[0-9]/ && t ~ /[A-Za-z]/) t=substr(t,1,4) "…"
        out=out substr(s,1,RSTART-1) t; s=substr(s,RSTART+RLENGTH) }
      print out s }' > "$P6"

# Licencja z plików LICENSE/COPYING w celu
if [ -d "$CEL" ]; then
  LF=$(find "$CEL" -maxdepth 4 \( -iname 'LICEN[CS]E*' -o -iname 'COPYING*' \) -not -path '*/node_modules/*' 2>/dev/null | head -5)
  [ -n "$LF" ] && LICENCJA="${LICENCJA:+$LICENCJA; }pliki: $(echo "$LF" | tr '\n' ' ')"
fi

# 00 - przegląd
ASLICE=""; [ -n "$ARCH" ] && ASLICE=" (nm i otool z architektury $ARCH; strings ze wszystkich)"
{
  echo "Cel:          $CEL"
  echo "Typ:          $TYP"
  echo "Rozmiar:      $(du -sh "$CEL" 2>/dev/null | cut -f1)"
  echo "Wersja:       ${WERSJA:-nie znaleziono}"
  echo "Licencja:     ${LICENCJA:-nie znaleziono (sprawdź repo albo zapytaj użytkownika)}"
  echo "Źródło napisów: ${BIN:-brak}"
  echo "Architektury: $ARCHS$ASLICE"
  [ -n "$PLIST" ] && grep -iE 'GitCommit|Commit|BuildTimestamp|BuildDate' "$P5" | sed 's/^ */Info.plist:   /'
  if [ -d "$CEL/Contents" ]; then
    echo "Części bundla:"
    find "$CEL/Contents" -maxdepth 4 \( -name '*.app' -o -name '*.appex' -o -name '*.xpc' -o -name '*.framework' -o -name '*.asar' -o -name '*.bundle' \) -prune -print 2>/dev/null | sed "s|^$CEL/|  |"
    [ -d "$CEL/Contents/Helpers" ] && ls "$CEL/Contents/Helpers" | sed 's/^/  Helpers\//'
  fi
  [ -n "$UWAGI" ] && echo "Uwaga:        $UWAGI"
} > "$P0"

echo "Przegląd: $TYP, wersja ${WERSJA:-?}"
for f in "$P0" "$P1" "$P2" "$P3" "$P4" "$P5" "$P6"; do
  printf '  %-60s %8s linii\n' "$f" "$(wc -l < "$f" | tr -d ' ')"
done
echo "Numer w pierwszej kolumnie 02/03/06 = linia w 02-strings.txt (dowód S:<n>)."
[ -s "$P6" ] && echo "06-sekrety-UWAGA.txt: sprawdź przed cytowaniem, w raporcie tylko 4 znaki i …"
exit 0

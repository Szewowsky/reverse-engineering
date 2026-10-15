# Tryb appka

Cel leży na dysku: `.app`, binarka, paczka npm, archiwum asar, `.zip`, `.tgz` albo `.dmg`.

## Rozpoznanie celu

| Sygnał | Rodzaj | Gdzie siedzą odpowiedzi |
|---|---|---|
| `Contents/MacOS/<binarka>`, `file` mówi `Mach-O` | natywna appka macOS | napisy binarki, symbole, `Info.plist`, `*.lproj/Localizable.strings` |
| symbole `$s…` w `nm` | Swift | nazwy typów i funkcji w symbolach (moduł appki bywa zestrippowany, frameworki nie) |
| `Contents/Frameworks/Electron Framework.framework`, `Resources/*.asar` | Electron | kod JS w asar; binarka główna to ogólny Electron |
| `package.json` w katalogu | paczka npm | pola `bin`, `main`, `exports`, `scripts`, pliki w `dist/` |
| `Mach-O` bez asar, w napisach `index.html`/`assets/` | appka z zaszytym webview (np. Tauri) | napisy binarki zawierają też kod strony |


## Najtańszy przegląd

Uruchom w folderze `re-<nazwa-celu>/` (skrypt tworzy tam `dowody/`):

```bash
<katalog skilla>/scripts/przeglad-appki.sh "/Applications/Nazwa.app"
```

Skrypt tylko czyta cel i za każdym razem nadpisuje `dowody/00-06`. Pliki: `00-przeglad` (typ, rozmiar, wersja, licencja, commit z `Info.plist`, części bundla), `01-pliki` (lista z rozmiarami), `02-strings` (numerowane napisy), `03-urls` (URL-e i ścieżki z 02), `04-symbole` (`otool -L`, `nm`), `05-plist-lub-package`, `06-sekrety-UWAGA` (linie z token/secret/password/api key, wartości skrócone). Electron: 02 zbiera wszystkie `.asar` z `Contents/Resources`, każdy otwiera linia `=== PLIK:`. Zip, tgz, dmg: skrypt podaje tylko listę i mówi, co dalej.

Czytaj w kolejności: 00 → 05 → 03 → wyszukiwanie w 02. Potem doczytujesz ręcznie to, czego pytanie potrzebuje, i każdy wynik zapisujesz do `dowody/` pod nazwą z tabeli:

| Potrzeba | Komenda (wynik do `dowody/`) |
|---|---|
| szukanie w napisach | `grep -n -iE 'refresh\|interval' dowody/02-strings.txt` |
| helpery, rozszerzenia, XPC (`Contents/Helpers`, `PlugIns/*.appex`) | `strings -a -n 6 <plik> \| nl -ba > dowody/07-strings-<nazwa>.txt` |
| teksty interfejsu i opcje ustawień | `plutil -p <bundle>/Contents/Resources/en.lproj/Localizable.strings \| nl -ba > dowody/08-l10n.txt` (szukaj też w `*.bundle/Contents/Resources/`) |
| uprawnienia (sieć, Keychain, sandbox) | `codesign -d --entitlements - <app> > dowody/09-entitlements.txt` |
| czytelne nazwy Swift | `nm -arch arm64 <bin> \| xcrun swift-demangle` (działa, gdy `xcrun --find swift-demangle` coś zwraca; bez tego czytasz zmanglowane nazwy wprost) |
| liczba zaszyta w kodzie, nie w napisach | adres funkcji z `nm`, potem `otool -arch arm64 -tV <bin>` i fragment od tego adresu do `dowody/asm-<funkcja>.txt` |
| plik z asar | nagłówek: `L=$(od -An -tu4 -j12 -N4 app.asar)`, `tail -c +17 app.asar \| head -c $L > dowody/asar-naglowek.json`; plik: `H=$(od -An -tu4 -j4 -N4 app.asar)`, wpis ma `offset` i `size`, treść to `tail -c +$((8+H+offset+1)) app.asar \| head -c size` |
| paczka npm | `cat package.json`, `ls dist/`, pliki `*.map` (pole `sources` = lista oryginalnych plików) |
| zip, tgz | rozpakuj do osobnego pustego folderu (`unzip -q x.zip -d rozpak/`, `tar -xzf x.tgz -C rozpak/`) i uruchom skrypt na wyniku |

**Gotowe:** `00-przeglad.txt` ma typ, wersję i licencję albo "nie znaleziono"; każde pytanie z kroku 2 ma w `dowody/` przynajmniej jeden plik, w którym szukałeś.

## Forma dowodu w tym trybie

| Skrót | Znaczy | Przykład wpisu w rejestrze |
|---|---|---|
| `S:<n>` | linia `n` w `dowody/02-strings.txt` (`strings -a -n 6`, wszystkie architektury) | `S:164273` - `https://api.anthropic.com/api/oauth/usage` |
| `S7-<nazwa>:<n>` | linia w kolejnym zrzucie napisów (`07-strings-<nazwa>.txt`) | `S7-helper:120` - komunikat helpera |
| `PLIST:<klucz>` | klucz z `05-plist-lub-package.txt` | `PLIST:CodexGitCommit` = `ed3c650e19e` |
| `SYM:<symbol>` | symbol z `04-symbole.txt` albo po demanglingu | `SYM:RateWindow.remainingPercent.getter` |
| `L10N:<n>` | linia w `08-l10n.txt` | `L10N:805` - opcja `refresh_manual` |
| `ENT:<klucz>` | uprawnienie z `09-entitlements.txt` | `ENT:com.apple.security.network.client` |
| `ASM@0x…` | adres instrukcji w zrzucie `otool -tV` | `ASM@0x1018d5b38` - stała 100.0 |
| `<plik>:<linia>` | plik paczki npm albo wyciągnięty z asar | `dist/index.js:812` |
| `<plik>@<bajt>` | jednowierszowy, zminifikowany JS: przesunięcie z `grep -ob` | `dist/cli.js@183402` |

Pierwsza kolumna w 02, 03 i 06 to numer linii w 02, więc trafienie z 03 cytujesz od razu jako `S:<n>`.

## Śledzenie pytania

| Pytanie | Punkty wejścia |
|---|---|
| skąd bierze dane | hosty z 03 (`grep -oE 'https?://[^/" ]+' dowody/02-strings.txt \| sort \| uniq -c \| sort -rn`), napisy w sąsiedztwie URL-a (nazwy pól JSON, nagłówki), symbole `*Response`, `*Fetcher`, `*Client`, komunikaty błędów typu "Run `x login`" |
| jak często odświeża | `Localizable.strings` (opcje interwału), napisy `interval`, `refresh`, `timer`, `seconds`; dokładne progi w deasemblacji funkcji od polityki odświeżania |
| jakie pliki czyta | ścieżki `~/`, `/Users/`, `Library/Application Support`, `.json`, `.plist` w 03; komunikaty "not found"; `security find-generic-password` i nazwy wpisów Keychain w 02; `ENT:keychain-access-groups` |
| co wysyła do sieci | lista hostów; `PLIST:SUFeedURL` (aktualizacje Sparkle); nazwy SDK telemetrii w `otool -L` i 01 (Sentry, Firebase, PostHog, Mixpanel); `ENT:com.apple.security.network.client` |
| jakie ma ustawienia | `Localizable.strings`, klucze `UserDefaults` w 02, ścieżka preferencji `~/Library/Preferences/<CFBundleIdentifier>.plist` (treść to dane użytkownika: stop-warunek poniżej) |
| npm: co robi przy instalacji i uruchomieniu | `scripts.postinstall`/`preinstall`, `bin`, wywołania `child_process`, `fetch(`, `process.env.` w `dist/` |


## Podkrok: porównanie wersji

Inwentarz opisuje wersję z dysku; repo bywa o wiele commitów dalej i ma inne ustawienia.

1. Wersja na dysku: `PLIST:CFBundleShortVersionString` albo `version` z `package.json`; commit z `00-przeglad.txt` albo `grep -n -iE 'commit|revision' dowody/02-strings.txt`.
2. Odpowiednik w repo: tag `v<wersja>` albo commit z kroku 1. Klon, który użytkownik ma lokalnie: `git -C <repo> log --oneline <commit>..HEAD | wc -l` (ile commitów za) i `git -C <repo> describe --tags <commit>`.
3. Dwie wersje appki: skrypt w dwóch folderach, potem `diff <(cut -f2 a/dowody/02-strings.txt | sort -u) <(cut -f2 b/dowody/02-strings.txt | sort -u) > dowody/diff-napisow.txt`.
4. Ficzer obecny tylko w repo dostaje w inwentarzu dopisek "w repo, brak w wersji z dysku" z E-numerem obu stron.

**Gotowe:** sekcja "Cel i tryb" podaje wersję z dysku z E-numerem, a każdy ficzer wzięty z repo ma oznaczoną wersję, z której pochodzi.

## Pułapki

- **Brak w strings to granica szukania.** Krótkie napisy Swift (do 15 bajtów) siedzą w instrukcjach, a slice arm64 zawiera ich mniej niż x86_64; skrypt czyta wszystkie architektury. Wpis: "szukałem `wzorzec` w 02 (`strings -n 6`), nie znalazłem".
- **Zestrippowany moduł appki** ma symbole tylko we frameworkach; nazwy funkcji appki odtwarzasz z napisów i komunikatów.
- **Zminifikowany JS** ma nazwy w stylu `a`, `b`; cytujesz napisy, URL-e i klucze obiektów, a nazwę funkcji z bundla traktujesz jako [WNIOSKUJĘ].
- **Fixture'y i paczki testów** (`*Tests.bundle`) pokazują kształt danych z testów; zachowanie produkcyjne to [WNIOSKUJĘ].
- **Sąsiedztwo w 02 to nie odwołanie.** Nagłówek, User-Agent albo komunikat przypisujesz do ścieżki (OAuth, PAT, CLI) dopiero wtedy, gdy łączy je symbol albo odwołanie w ASM (adres z `strings -t x`, potem `otool -tV`); przy samym sąsiedztwie do ledgera trafia tylko "napis X istnieje w binarce" [WIDZĘ], a przypisanie do ścieżki idzie do rejestru niewiadomych, bez uogólniania na całego dostawcę.
- **Komunikat błędu to ślad, nie ścieżka.** Stare komunikaty zostają w binarce po usunięciu funkcji; istnienie ścieżki potwierdza symbol albo kod, który komunikat wypisuje.
- **02 i 03 mają surowe wartości.** Plik 06 skraca tylko linie ze słowami-kluczami; client ID i klucze w innych liniach skracasz sam przy cytowaniu.

## Stop-warunki trybu

Dochodzą do tych z SKILL.md:

- Napisy to szum, 03 jest prawie puste, a odpowiedź siedzi w logice (binarka zaciemniona albo spakowana): pytasz, czy instalować dekompilator, albo kończysz z wpisem w rejestrze niewiadomych.
- Pytanie wymaga zajrzenia do plików z danymi lub sekretami użytkownika, które appka czyta (np. `~/.codex/auth.json`, wpis w Keychain): ścieżka z napisów wystarcza do inwentarza; otwarcie pliku tylko na wyraźną prośbę użytkownika.
- Obraz `.dmg`: montujesz go (`hdiutil attach -readonly -nobrowse`) po zgodzie użytkownika.
- Porównanie z repo wymaga pobrania repo, którego użytkownik nie ma lokalnie: pytasz o zgodę na `git clone`.

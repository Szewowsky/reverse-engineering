# Tryb www

Cel to strona albo webapp oglądana z zewnątrz. Pobierasz to, co pobiera przeglądarka przy zwykłym otwarciu adresu: HTML, jego skrypty i style, pliki JS doładowywane przy przejściu do widoku. Do tego dwa publiczne pliki pomocnicze: `robots.txt` i source mapę, gdy bundle sam ją wskazuje. Adresy API wypisujesz z kodu; ich nie wywołujesz.

## Rozpoznanie celu

| Sygnał w HTML (`dowody/strona.html`) | Rodzaj | Co z tego wynika |
|---|---|---|
| prawie pusty `<body>`, `<div id="root">` albo `id="app"`, duży bundle | SPA (React, Vue, Svelte) | logika i adresy API siedzą w JS |
| treść w HTML, `__NEXT_DATA__`, `__NUXT__`, `window.__INITIAL_STATE__` | SSR (Next.js, Nuxt) | część danych przychodzi gotowa w HTML; skrypt z JSON-em danych startowych to osobny dowód |
| `<script type="module" src="/assets/index-<hash>.js">` | build Vite | jeden wejściowy plik, reszta przez `import()` |
| `/_next/static/chunks/` | Next.js | lista chunków w `_buildManifest.js` |
| `ng-version=` | Angular | `main-<hash>.js` |
| na końcu bundla `//# sourceMappingURL=<plik>.map` albo nagłówek `SourceMap:` | jest source mapa | lista oryginalnych plików i ich nazw |
| strona z wyzwaniem (Cloudflare, captcha), 403 dla curl | ochrona przed botami | stop-warunek trybu |

## Najtańszy przegląd

Pracujesz w `re-<nazwa-celu>/`. Jeden User-Agent na cały przegląd, zapisany w rejestrze dowodów razem z datą:

```bash
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"
U="https://example.com/"
mkdir -p dowody/js
curl -sL -A "$UA" -D dowody/naglowki.txt -o dowody/strona.html "$U"
curl -sL -A "$UA" -o dowody/robots.txt "${U%/}/robots.txt"
{ grep -oE '<script[^>]+src="[^"]+"' dowody/strona.html | sed -E 's/.*src="([^"]+)".*/\1/'
  grep -oE '<link[^>]+modulepreload[^>]+href="[^"]+"' dowody/strona.html | sed -E 's/.*href="([^"]+)".*/\1/'
  grep -oE 'createElement\("script"\)|\.src\s*=\s*["\x27][^"\x27]+|import\("[^"]+"\)' dowody/strona.html dowody/js/*.js 2>/dev/null | sort -u
} | nl -ba > dowody/skrypty.txt
```

Każdy skrypt z listy pobierasz do `dowody/js/` (adres względny składasz z domeną strony):

```bash
curl -sL -A "$UA" -o dowody/js/<nazwa>.js "<pełny URL skryptu>"
```

Potem w każdym pliku JS:

```bash
grep -ob -E 'https?://[^"'\''` ]+' dowody/js/<nazwa>.js > dowody/js/<nazwa>.urls.txt
grep -ob -E '"/(api|v[0-9]+|graphql|rpc)[^"]*"' dowody/js/<nazwa>.js >> dowody/js/<nazwa>.urls.txt
grep -oE '.{0,60}(fetch\(|XMLHttpRequest|WebSocket\(|EventSource\().{0,60}' dowody/js/<nazwa>.js | head -50
tail -c 300 dowody/js/<nazwa>.js | grep -o 'sourceMappingURL=.*'
```

Chunki doładowywane przy przejściu do widoku (nazwy `*-<hash>.js` w bundlu, manifest Next.js) pobierasz tak samo, gdy pytanie dotyczy tego widoku. Source mapę pobierasz do `dowody/js/` i wypisujesz z niej `sources` (`grep -oE '"sources":\[[^]]*\]'`); pole `sourcesContent` czytasz do inwentarza.

Nagłówki w `naglowki.txt`: `server`, `x-powered-by` (stos), `content-security-policy` (dyrektywa `connect-src` wylicza domeny, z którymi strona może się łączyć), `set-cookie` (nazwy ciasteczek, wartości skracasz), `cache-control`.

Zachowanie widoczne dla użytkownika (ekrany, kolejność kroków, komunikaty) opisujesz ze zrzutów ekranu z własnego okna przeglądarki: zrzut robi użytkownik albo Ty we własnej przeglądarce, zapisujesz go jako `dowody/zrzut-<nr>-<opis>.png`.

**Gotowe:** w `dowody/` są `strona.html`, `naglowki.txt`, `robots.txt`, `skrypty.txt`, każdy skrypt wejściowy w `dowody/js/` z plikiem `.urls.txt` oraz zapisany UA, data pobrania i regulamin strony jako dowód albo wpis "nie znaleziono".

## Forma dowodu w tym trybie

| Skrót | Znaczy | Przykład wpisu w rejestrze |
|---|---|---|
| `<plik>:<linia>` | linia w pobranym pliku (HTML, sformatowany JS, `robots.txt`) | `dowody/strona.html:42` - `<div id="root">` |
| `<plik>@<bajt>` | zminifikowany, jednowierszowy JS: przesunięcie z `grep -ob` | `dowody/js/index-a1b2.js@183402` - `"/api/v2/scenes"` |
| `HDR:<nagłówek>` | nagłówek odpowiedzi z `naglowki.txt` + URL | `HDR:content-security-policy` (`https://example.com/`) |
| `MAP:<źródło>` | wpis z `sources` source mapy | `MAP:src/renderer/roughjs.ts` |
| `ZRZUT:<nr>` | zrzut ekranu własnego okna | `ZRZUT:3` - ekran wyboru godziny |

Przy każdym E-numerze z sieci zapisujesz pełny URL, datę pobrania i nazwę pliku z hashem: przy następnym wdrożeniu strona dostaje nowe pliki.

## Śledzenie pytania

| Pytanie | Punkty wejścia |
|---|---|
| skąd bierze dane | `.urls.txt` (ścieżki `/api/`, `graphql`, hosty zewnętrzne), `fetch(`/`WebSocket(` z kontekstem, `connect-src` w CSP, JSON danych startowych w HTML (SSR) |
| jak często odświeża | `setInterval(`, `setTimeout(`, `refetchInterval`, `staleTime`, `pollingInterval`, `EventSource`, `WebSocket` (push zamiast pytań); liczby w milisekundach obok tych słów |
| co zapisuje w przeglądarce | `localStorage`, `sessionStorage`, `indexedDB`, `document.cookie`, nazwy kluczy obok; `set-cookie` w nagłówkach |
| co wysyła do sieci poza własnym API | hosty zewnętrzne w `.urls.txt` i `<script src>` (analityka, czat, płatności, CDN), CSP |
| jakie ma ustawienia i opcje | teksty interfejsu w JS (pliki tłumaczeń `*.json` albo obiekty `{"key":"tekst"}`), flagi funkcji (`feature`, `flag`, `experiment`), parametry URL |
| jak liczy wynik (np. rysowanie, ceny) | stałe liczbowe przy nazwach z source mapy albo przy tekstach interfejsu; w zminifikowanym kodzie kontekst `grep -oE '.{0,80}<słowo>.{0,80}'` |

## Pułapki

- **Kod w bundlu to możliwość.** Endpoint obecny w JS mógł należeć do wyłączonego ficzera albo innego planu; użycie przy zwykłym otwarciu to [WNIOSKUJĘ].
- **Brak w pobranych plikach to granica szukania.** Chunki, których nie pobrałeś, i kod po stronie serwera są poza zasięgiem; wpis: "szukałem w <pliki>, nie znalazłem".
- **Minifikacja i obfuskacja:** nazwy funkcji z bundla nic nie znaczą; cytujesz napisy, klucze obiektów, URL-e i nazwy z source mapy.
- **curl widzi stronę inaczej niż przeglądarka.** Inny UA, brak ciasteczek i brak JS dają inny HTML; różnicę względem zrzutu z okna zapisujesz jako granicę szukania.
- **Regulamin i licencja.** Regulamin (ToS) strony czytasz przed pobraniem JS i zapisujesz jako dowód (zasada "Prawo do celu" z SKILL.md); szukasz go w HTML, a w SPA przez `grep -oiE 'terms|privacy|regulamin|legal' dowody/strona.html dowody/js/*.js` po pierwszym bundle; brak trafienia to wpis w rejestrze niewiadomych i dalsza praca w zakresie zwykłego oglądania strony. Strona open source: licencja repo jako dowód, a kod repo opisujesz osobno od tego, co serwuje strona (to drugie jest celem).

## Stop-warunki trybu

Dochodzą do tych z SKILL.md:

- Strona odpowiada wyzwaniem antybotowym, captchą albo 403 dla curl: kończysz na zrzutach z okna użytkownika.
- Odpowiedź wymaga wywołania endpointu API, wysłania formularza, DevTools na cudzej sesji albo serii automatycznych zapytań: wpis w rejestrze niewiadomych z tym, co by go rozstrzygnęło.

# reverse-engineering

Skill dla agentów AI, który rozbiera cudzą appkę, stronę, skill albo narzędzie z filmu na części: co umie i jak to robi. Każde twierdzenie ma dowód (plik i linię, napis w programie, timestamp filmu) i etykietę: widzę, wnioskuję albo nie wiem. Na koniec, jeśli chcesz, agent buduje Twoją własną wersję od zera i sprawdza ją obok oryginału.

## Instalacja

```bash
npx skills add Szewowsky/reverse-engineering
```

Działa w Claude Code, Codex i Cursor. Bez dodatkowych serwerów i programów: skill korzysta z narzędzi, które ma każdy Mac. Wyjątek to tryb film, który potrzebuje `yt-dlp` - skill sam sprawdzi, czy go masz, i poda komendę instalacji.

## Jak używać

Napisz agentowi, co chcesz zrozumieć. Skill sam dobierze tryb:

- **appka:** "Rozbierz appkę /Applications/CodexBar.app - skąd bierze dane o limitach i co wysyła do sieci?"
- **www:** "Jak działa rysowanie odręczne na excalidraw.com? Chcę zrobić coś podobnego."
- **skill:** "Rozbierz ten skill z GitHuba, zanim go zainstaluję - co ładuje do kontekstu i czy coś pobiera z sieci?"
- **film:** "Na tym filmie z YouTube ktoś pokazuje narzędzie do X. Jak ono działa? [link]"

Agent spisze 3-5 pytań, zrobi najtańszy przegląd, prześledzi każde pytanie i raz przejrzy całość. Zanim zacznie budować, pokaże plan i poczeka na Twoje "ok".

## Co dostajesz

Folder `re-<nazwa-celu>/` z plikiem `raport.md`:

- cel, wersja i licencja,
- Twoje pytania i odpowiedzi na nie,
- inwentarz ficzerów i mechanizmy, każde zdanie z dowodem i etykietą,
- rejestr dowodów i lista tego, czego agent nie wie (z tym, co by to rozstrzygnęło),
- plan własnej wersji i test obok oryginału.

## Granice

- Tylko cele, do których masz prawo: otwarta licencja, Twoja appka albo zgoda autora.
- Wynik to wiedza, nie kopia. Twoja wersja ma własny kod, nazwę i wygląd.
- Strony ogląda z zewnątrz, we własnym oknie, bez logowania i cudzych kont. Analizowanej appki nie uruchamia.
- Hasła i klucze skraca do 4 pierwszych znaków.
- Gdy trzeba coś zainstalować albo licencja jest niejasna, agent zatrzymuje się i pyta. To, czego nie da się ustalić bez logowania albo uruchomienia, trafia do listy niewiadomych.

## Skąd to wiemy

W teście na appce CodexBar sam prompt z tą metodą dał 73% kluczowych faktów przy 92% trafności w 6,4 min, a pakiet REA ze 170 narzędziami 23% w 50 min.

## Inspiracja

REA (morluto/rea, MIT). Z REA pochodzi struktura i dyscyplina pracy; tekst i przebieg są napisane od nowa, bez zależności od narzędzi REA.

## Licencja

MIT, zobacz [LICENSE](LICENSE).

---
name: reverse-engineering
description: Reverse engineering cudzego celu - inwentarz ficzerów i mechanizmów z dowodami, bez kopiowania kodu i wyglądu, potem własna wersja. Use when użytkownik chce zrozumieć, jak działa appka na dysku, strona www, cudzy skill lub plugin Claude Code albo narzędzie z filmu YouTube.
---

# Reverse engineering

Rozbierasz **cel** na części: co umie (inwentarz ficzerów) i jak to robi (mechanizmy). Każde twierdzenie stoi na **dowodzie** z rejestru i nosi **etykietę**. Na końcu, jeśli użytkownik chce, budujesz własną wersję od zera i sprawdzasz ją obok oryginału.

## Zasady i granica

- **Prawo do celu.** Rozbierasz cel z otwartą licencją, własny cel użytkownika albo cel, na który autor dał zgodę. Licencję zapisujesz jako dowód (plik licencji, metadane paczki albo wypowiedź użytkownika). Gdy regulamin zabrania rozbierania, zostaje obserwacja tego, co widzi zwykły użytkownik.
- **Inwentarz zamiast kopii.** Wynik to opis ficzerów, mechanizmów i liczb. Dowód cytujesz krótko: napis, nazwa funkcji, linia konfiguracji. Własna wersja dostaje własny kod, nazwę, wygląd i markę.
- **Sekrety.** Token, klucz, hasło, client ID, ciasteczko sesji: w raporcie i cytatach zapisujesz tylko 4 pierwsze znaki i `…`. Surowe zrzuty w `dowody/` mogą zawierać pełne wartości, więc zostają u użytkownika; przed przekazaniem folderu komuś skracasz je `sed`-em.
- **Obserwacja pasywna.** Czytasz pliki celu i to, co cel sam pokazuje. Strona www: tylko to, co przeglądarka pobiera przy zwykłym otwarciu, we własnym oknie. Analizowanej appki nie uruchamiasz, nie logujesz się i nie wywołujesz cudzego API: zachowanie w działaniu opisujesz z plików jako [WNIOSKUJĘ], a to, czego bez uruchomienia, logowania albo zapytania nie da się ustalić, wpisujesz do rejestru niewiadomych.
- **Stop i pytanie do użytkownika**, zanim pójdziesz dalej, gdy:
  - licencja jest niejasna albo jej brak,
  - potrzebna jest instalacja narzędzia,
  - cel jest niejasny. Pytasz, który cel; przykładowego celu nie wybierasz sam.

## Routing celu

Tryb wybierasz z tego, co użytkownik ma w ręku. Plik trybu ma najtańszy przegląd, formę dowodu, pułapki i stop-warunki tego trybu.

| Tryb | Cel | Plik |
|---|---|---|
| **appka** | program na dysku: binarka macOS (`.app`), paczka npm, Electron/asar; także porównanie dwóch wersji | [references/appka.md](references/appka.md) |
| **www** | strona albo webapp oglądana z zewnątrz, bez logowania, z publicznym JS | [references/www.md](references/www.md) |
| **skill** | cudzy SKILL.md, plugin albo repo dla Claude Code; w ledgerze dochodzi pięć czerwonych flag | [references/skill.md](references/skill.md) |
| **film** | narzędzie pokazane na filmie YouTube: transkrypt plus zrzuty ekranu od użytkownika | [references/film.md](references/film.md) |

Cel pasujący do dwóch trybów (np. strona z paczką npm na dysku): bierzesz tryb bliższy temu, co użytkownik dostaje do ręki, i zapisujesz wybór w raporcie.

## Dowody i etykiety

**Rejestr dowodów.** Każdy dowód dostaje numer E1, E2… i wpis: co to jest i gdzie dokładnie leży (forma zależy od trybu). Surowe wyniki przeglądu zapisujesz do plików w `dowody/`, żeby dowód wskazywał konkretną linię.

**Etykieta** stoi przy każdym zdaniu o celu:

- **[WIDZĘ]** - dosłowny odczyt: napis, wartość, nazwa, linia, klatka filmu. Tylko to, co jest zapisane w dowodzie słowo w słowo: URL w kodzie to [WIDZĘ], "cel pobiera stąd dane" to już [WNIOSKUJĘ].
- **[WNIOSKUJĘ]** - interpretacja: do czego coś służy, w jakiej kolejności działa, które wejście steruje którą wartością, co cel robi po uruchomieniu. Podajesz E-numery, na których wniosek stoi.
- **[NIE WIEM]** - brak dowodu. Trafia do rejestru niewiadomych.

**Jedno trafienie opisuje jedno miejsce.** Nagłówek, interwał albo wartość znaleziona przy jednym dostawcy, wywołaniu czy widoku opisuje tylko je; dla pozostałych szukasz osobno.

**Kolejność i wartość domyślna wymagają kodu, który je ustala.** Kolejność napisów, przypadków enuma czy kluczy w pliku to [WIDZĘ] o położeniu, a kolejność działania i słowo "domyślnie" to [WNIOSKUJĘ] - dowodem jest dopiero funkcja, która buduje listę albo inicjalizuje ustawienie. Bez niej zapis idzie do rejestru niewiadomych. Tekst interfejsu (etykiety, komunikaty) jest [WIDZĘ] tylko dla tego, co sam mówi; "cel wysyła / czyta / synchronizuje X" wyprowadzone z tego tekstu to [WNIOSKUJĘ] z dopiskiem "z tekstu UI", a zakres danych bez symboli typów idzie do niewiadomych.

**Rejestr niewiadomych.** Każda pozycja: pytanie, gdzie szukałeś ("szukałem w X, nie znalazłem"), co by to rozstrzygnęło. Brak trafienia opisujesz jako granicę szukania, nie jako dowód, że czegoś nie ma.

**Ledger** to tabela mechanizmów w raporcie: twierdzenie → etykieta → E-numery → granica szukania.

## Przebieg

Pracujesz w folderze `re-<nazwa-celu>/` w bieżącym katalogu: `raport.md` według szablonu [references/raport.md](references/raport.md) i `dowody/`. Raport wypełniasz na bieżąco, krok po kroku.

### 1. Ustal cel i tryb

Ustal nazwę, wersję, ścieżkę albo URL i licencję celu. Wybierz tryb z tabeli routingu i przeczytaj jego plik.
**Gotowe:** sekcja "Cel i tryb" w raporcie ma wszystkie pola, a wersja i licencja mają E-numery.

### 2. Spisz pytania

Zamień ciekawość użytkownika na 3-5 konkretnych pytań. Przy każdym zapisz, jaki dowód na nie odpowie. Pokaż listę użytkownikowi i uwzględnij jego poprawki; gdy użytkownik z góry poprosił o przebieg bez pytań, zapisujesz listę w raporcie i idziesz dalej (to samo w kroku 7).
**Gotowe:** sekcja "Pytania" ma 3-5 pytań, każde z rodzajem dowodu, a użytkownik widział listę.

### 3. Zrób najmniejszy przegląd

Wykonaj najtańszy przegląd z pliku trybu i zapisz wynik w `dowody/`. Z przeglądu zbuduj mapę celu w `dowody/mapa.md`: z jakich części się składa i gdzie każde pytanie ma punkt wejścia.
**Gotowe:** każde pytanie ma wskazany punkt wejścia z E-numerem albo wpis w rejestrze niewiadomych.

### 4. Śledź każde pytanie

Idź od punktu wejścia przez dane i stany do wyniku. Każde znalezisko wpisujesz od razu: dowód do rejestru, twierdzenie z etykietą do ledgera. Głębsze narzędzie bierzesz dopiero wtedy, gdy tańszy dowód zostawia konkretną lukę.
**Gotowe:** każde pytanie ma ścieżkę wejście → wynik w ledgerze albo pozycję w rejestrze niewiadomych.

### 5. Przejrzyj całość raz

Lista pytań zawęża pole widzenia. Przejdź raz przez całą mapę z kroku 3 i dopisz do inwentarza ficzerów to, czego pytania nie objęły: ustawienia, wartości domyślne, pliki, połączenia sieciowe, rzeczy poboczne. Przy każdym pytaniu wypisz wszystkie kandydujące drogi widoczne w przeglądzie (np. dla "skąd dane": każdy dostawca × każde źródło: API, plik, proces, sesja) i daj każdej wpis w ledgerze albo w rejestrze niewiadomych; nazwa łącząca kilka mechanizmów (np. "CLI: RPC albo PTY") dostaje osobny wiersz na każdy. Zanim napiszesz "brak symboli" albo "nie ma w module", zrób grep nazwy typu w zrzucie symboli i wpisz wynik w granicę szukania.
**Gotowe:** każda część mapy z kroku 3 ma co najmniej jedną pozycję w inwentarzu albo dopisek "przejrzane, nic nowego" z E-numerem; każda kandydująca droga ma wpis.

### 6. Wróć do listy pytań

Oceń każde pytanie na podstawie ledgera: odpowiedziane, częściowo albo otwarte. Przy częściowym i otwartym wskaż pozycję w rejestrze niewiadomych.
**Gotowe:** sekcja "Powrót do pytań" ma status przy każdym pytaniu z kroku 2.

### 7. Domknij raport

Sprawdź raport zdanie po zdaniu: każde twierdzenie o celu ma etykietę i E-numer, każdy E-numer jest w rejestrze dowodów, sekrety skrócone do 4 znaków. Pokaż użytkownikowi podsumowanie: inwentarz, odpowiedzi na pytania, największe niewiadome.
**Gotowe:** raport przechodzi tę kontrolę bez wyjątków, a użytkownik dostał podsumowanie.

### 8. Zaplanuj własną wersję

Rozpisz plan w raporcie: co bierzesz z wiedzy (liczby, formaty, protokoły, kolejność działań, każde z E-numerem) i co projektujesz sam (kod, nazwa, wygląd, architektura). Dopisz test rekonstrukcji: skończoną listę sprawdzalnych twierdzeń, np. te same liczby, zrzut obok oryginału, ten sam wynik testu. Pokaż plan i poczekaj na "ok" użytkownika.
**Gotowe:** użytkownik odpowiedział "ok" albo zdecydował, że kończy na raporcie.

### 9. Zbuduj

Buduj od zera w osobnym folderze, korzystając z raportu. Wiedzę z oryginału przenosisz jako liczby i zachowania z planu.
**Gotowe:** własna wersja uruchamia się, a każdy punkt planu ma w niej wskazane miejsce (plik albo funkcję).

### 10. Zrób test rekonstrukcji

Sprawdź każde twierdzenie z listy obok oryginału i zapisz wynik z dowodem (zrzut, wynik komendy, porównanie liczb). Stroną oryginału są dowody z raportu; świeży zrzut działającego oryginału robi użytkownik. Niezaliczone poprawiasz albo opisujesz w raporcie.
**Gotowe:** każde twierdzenie z listy ma wynik "zaliczone" albo "niezaliczone" z dowodem.

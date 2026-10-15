# Szablon raportu

Kopiujesz poniższy układ do `re-<nazwa-celu>/raport.md` i wypełniasz pola w nawiasach kwadratowych. Układ jest ten sam w każdym trybie; różni się tylko forma dowodu w rejestrze.

---

# Raport: [nazwa celu]

## Cel i tryb

- **Cel:** [nazwa]
- **Wersja:** [numer wersji, build albo data filmu] ([E-numer])
- **Ścieżka / URL:** [ścieżka na dysku albo adres]
- **Licencja:** [np. MIT] - skąd wiadomo: [plik licencji, metadane paczki albo wypowiedź użytkownika] ([E-numer])
- **Tryb:** [appka / www / skill / film] - [jedno zdanie, dlaczego ten tryb]

## Pytania

| # | Pytanie | Jaki dowód odpowie |
|---|---|---|
| P1 | [pytanie] | [np. adresy w napisach programu, kod JS strony, frontmatter skilla, ekran na filmie] |

## Inwentarz ficzerów

| # | Ficzer | Etykieta | Dowód |
|---|---|---|---|
| F1 | [co cel umie, jednym zdaniem] | [WIDZĘ / WNIOSKUJĘ] | [E-numery] |

## Mechanizmy

<!-- Ledger: jedno twierdzenie w wierszu. Granica szukania = gdzie szukałeś i czego nie sprawdziłeś. -->

| # | Pytanie | Twierdzenie | Etykieta | Dowód | Granica szukania |
|---|---|---|---|---|---|
| M1 | [P-numer] | [jak to działa] | [WIDZĘ / WNIOSKUJĘ] | [E-numery] | [np. przeszukane napisy całej binarki, bez deasemblacji] |

## Rejestr dowodów

<!-- Forma "gdzie" i skróty (S:<n>, HDR:, transkrypt.txt:[mm:ss]...) podaje sekcja "Forma dowodu" w pliku trybu. -->

| E | Co | Gdzie dokładnie |
|---|---|---|
| E1 | [np. napis z adresem API] | [S:1234, czyli dowody/02-strings.txt:1234] |

## Rejestr niewiadomych

| # | Pytanie | Gdzie szukałem | Co by to rozstrzygnęło |
|---|---|---|---|
| N1 | [czego brakuje] | [szukałem w X, nie znalazłem] | [np. uruchomienie appki, zrzut z 4:12, logowanie] |

## Powrót do pytań

| # | Status | Na czym stoi |
|---|---|---|
| P1 | [odpowiedziane / częściowo / otwarte] | [M-numery; przy częściowym i otwartym N-numer] |

## Plan własnej wersji

**Z wiedzy (bierzemy z raportu):**
- [liczba, format, protokół albo kolejność działań] ([E-numer])

**Projektujemy sami:**
- [kod, nazwa, wygląd, architektura]

## Test rekonstrukcji

<!-- Skończona lista. Każde twierdzenie sprawdzalne obok oryginału: liczba, zrzut, wynik testu. -->

| # | Twierdzenie do sprawdzenia | Jak sprawdzam | Wynik |
|---|---|---|---|
| T1 | [np. ta sama wartość limitu co w oryginale] | [zrzut obu obok siebie] | [zaliczone / niezaliczone + dowód] |

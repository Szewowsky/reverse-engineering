# Glosariusz

Pojęcia używane w skillu `reverse-engineering`. Same definicje; jak z nich korzystać, opisuje `skills/reverse-engineering/SKILL.md`.

**Cel** - rzecz, którą rozbieramy: appka, strona, skill albo narzędzie z filmu. Konkretny egzemplarz, z nazwą, wersją i miejscem (ścieżka lub URL), do którego użytkownik ma prawo.

**Tryb** - sposób pracy dobrany do rodzaju celu. Są cztery: appka, www, skill, film. Tryb wyznacza najtańszy przegląd, formę dowodu i stop-warunki.

**Rozbieranie** - ustalanie, co cel umie i jak to robi, na podstawie dowodów. Przeciwieństwo kopiowania: rozbieranie daje wiedzę (ficzery, mechanizmy, liczby), kopiowanie przenosi cudzy kod, wygląd, nazwę albo markę. Skill robi tylko to pierwsze.

**Dowód** - konkretne miejsce w celu, które potwierdza twierdzenie: linia pliku, napis w programie, odpowiedź strony, timestamp filmu ze zrzutem. Wypowiedź użytkownika (np. o licencji) też jest dowodem, oznaczonym jako taka.

**Etykieta** - znacznik przy każdym zdaniu o celu, mówiący, na ile zdanie stoi na dowodzie:
- **[WIDZĘ]** - dosłowny odczyt z dowodu.
- **[WNIOSKUJĘ]** - interpretacja oparta na dowodach, np. do czego coś służy albo jak działa po uruchomieniu.
- **[NIE WIEM]** - brak dowodu.

**Rejestr dowodów** - ponumerowana lista dowodów E1, E2… z opisem, co to jest i gdzie dokładnie leży. Twierdzenia w raporcie odwołują się do niej numerami.

**Ledger** - tabela mechanizmów w raporcie: twierdzenie, etykieta, numery dowodów, granica szukania.

**Granica szukania** - opis, gdzie szukano i czego nie sprawdzono. Brak trafienia w tych granicach to "nie znalazłem w X", a nie "tego nie ma".

**Rejestr niewiadomych** - lista pytań bez odpowiedzi, każde z granicą szukania i z tym, co by je rozstrzygnęło.

**Inwentarz ficzerów** - pełna lista tego, co cel umie, z dowodami. Obejmuje odpowiedzi na pytania i to, co wyszło przy przeglądzie całości.

**Mechanizm** - opis, jak cel realizuje ficzer: skąd bierze dane, co z nimi robi, dokąd je wysyła.

**Rekonstrukcja** - własna wersja zbudowana od zera na podstawie raportu. Bierze z celu wiedzę, a kod, nazwę i wygląd ma własne.

**Test rekonstrukcji** - skończona lista sprawdzalnych twierdzeń (te same liczby, zrzut obok oryginału, ten sam wynik testu), każde z wynikiem zaliczone albo niezaliczone.

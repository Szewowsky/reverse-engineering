# Tryb film

Cel to narzędzie pokazane na filmie, nie sam film. Źródła dowodu są dwa: słowa autora z transkryptu i ekran ze zrzutów, które przysyła użytkownik.

## Rozpoznanie celu

Do sekcji "Cel i tryb" zapisz:

- **link** do filmu (YouTube albo inny serwis z napisami) i datę publikacji,
- **narzędzie**, o które chodzi, z pisownią z opisu filmu albo ze strony narzędzia,
- **zamiar** użytkownika, jeden z trzech: inwentarz ficzerów pokazanego narzędzia, jego mechanika, przepis na to, jak autor osiągnął pokazany wynik.

Wersją celu jest data filmu: film pokazuje narzędzie z tego dnia.

## Najtańszy przegląd

Uruchom `<katalog skilla>/scripts/transkrypt.sh <url> [języki]` w folderze `re-<nazwa-celu>/` (języki domyślnie `pl,en`, pierwszy znaleziony wygrywa). Skrypt zapisuje:

- `dowody/transkrypt.txt` - jedna linia na fragment, w formie `[mm:ss] tekst`,
- `dowody/film.txt` - tytuł, kanał, data, długość, opis filmu.

Kod wyjścia 2 znaczy brak `yt-dlp`: skrypt wypisuje komendę instalacji, pokazujesz ją użytkownikowi i działasz według stop-warunku "instalacja narzędzia" z SKILL.md. Kod 1 znaczy brak napisów albo błąd pobrania. Przy obu kodach drugą drogą jest transkrypt wklejony przez użytkownika (YouTube → "...więcej" pod filmem → "Pokaż transkrypcję"); zapisujesz go do `dowody/transkrypt.txt`: z timestampami w formie `[mm:ss] tekst`, a bez timestampów jako numerowane zdania `[z12] tekst` (czas przy prośbach o zrzuty podajesz wtedy jako szacunek `~mm:ss` z proporcji słów do długości filmu). `dowody/film.txt` wypełniasz tym, co skrypt zdążył zapisać albo co poda użytkownik; minimum to URL i nazwa narzędzia z jego prośby.

**Gotowe:** `transkrypt.txt` ma timestampy albo numerowane zdania, `film.txt` ma co najmniej URL i nazwę narzędzia.

## Forma dowodu

- **Słowa:** `transkrypt.txt:[mm:ss]` albo `transkrypt.txt:[z12]` przy wklejce bez czasów.
- **Ekran:** `dowody/zrzut-mm-ss.png` od użytkownika.

Zrzuty zbierasz w jednej liście próśb, 5-8 na przebieg, każda z timestampem i powodem: "pokaż mi ekran z 4:12, gdzie autor otwiera ustawienia". Wybierasz momenty, od których zależy najwięcej pytań. Listę pokazujesz raz, po mapie filmu; gdy użytkownik nie odpowiada albo zrzutów nie będzie, idziesz dalej i wszystko o ekranie zostaje [WNIOSKUJĘ]. Każde zdanie o tym, co jest na ekranie, bez zrzutu z tego momentu dostaje [WNIOSKUJĘ] z E-numerem fragmentu transkryptu.

## Śledzenie pytania

1. Zbuduj **mapę filmu**: rozdziały z opisu w `film.txt` i momenty, w których autor coś pokazuje (słowa typu "zobacz", "tutaj", "kliknę", "otwieram", "wpisuję"). Każdy moment to wiersz z timestampem i E-numerem.
2. Każde pytanie przypnij do momentów z mapy. Te momenty są kandydatami na prośby o zrzut.
3. Liczby, nazwy ustawień, komendy wypowiedziane przez autora zapisujesz jako [WIDZĘ] z krótkim cytatem. Co dana liczba albo ustawienie robi w narzędziu, to [WNIOSKUJĘ].

**Gotowe:** każde pytanie ma co najmniej jeden moment z mapy albo pozycję w rejestrze niewiadomych.

## Pułapki

- "Zawsze", "nigdy", "każdy" w ustach autora to twierdzenie autora: [WIDZĘ] cytat, a sam fakt o narzędziu [WNIOSKUJĘ] albo [NIE WIEM].
- Napisy automatyczne przekręcają nazwy. Pisownię narzędzia, komend i ustawień sprawdzasz w opisie filmu (`film.txt`) i w prośbie użytkownika; przy kilku wariantach w napisach bierzesz nazwę od użytkownika, a warianty wypisujesz raz w rejestrze dowodów.
- Film pokazuje wersję z dnia nagrania. Dzisiejsza wersja narzędzia to osobny cel; różnicę zapisujesz w rejestrze niewiadomych.
- Twoja wiedza o narzędziu z pamięci modelu to inne źródło niż film. Zdanie spoza transkryptu i zrzutów dostaje [WNIOSKUJĘ] z dopiskiem "z pamięci modelu, poza filmem" albo trafia do rejestru niewiadomych.
- Raport opisuje narzędzie, nie autora: piszesz bezosobowo ("w filmie pada", "na ekranie widać"), a autor występuje tylko w sekcji "Cel i tryb" przy linku. Cytat słów z filmu to [WIDZĘ]; liczba wypowiedziana bez pokazania na ekranie dostaje [WIDZĘ] jako cytat z dopiskiem "wypowiedziane, nie pokazane", a jej znaczenie [WNIOSKUJĘ].

## Stop-warunki trybu

Dochodzą do stop-warunków z SKILL.md:

- Odpowiedź wymaga samego wideo albo dźwięku z filmu (skrypt bierze tylko napisy i metadane): prosisz użytkownika o zrzut z danego momentu.
- Brak napisów w podanych językach i brak transkryptu od użytkownika: pytasz użytkownika, czy wklei transkrypt albo poda inny film.
- Pytanie, na które odpowiada tylko narzędzie w działaniu (np. "jak szybko liczy"): proponujesz przejście do trybu appka albo www na samym narzędziu.

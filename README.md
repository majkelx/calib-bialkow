# calib-bialkow
Oprogramowanie do automatycznej kalibracji obserwacji wykonanych w Białkowie

## Instrukcje dotyczące użycia oprogramowania do automatycznej kalibracji obserwacji wykonanych w Białkowie. 
Wersja 2016.04.14

Skrypt główny calib_bialkow.bash przeprowadza pełną(*), automatyczną 
kalibrację obrazów CCD wykonanych kamerą ANDOR DW-432 w obserwatorium 
w Białkowie.

### 1. Instalacja, wymagania i zależności.

Oprogramowanie do automatycznej kalibracji dostępne jest
na komputerze fornax (156.17.59.11) w katalogu /home/zibi jako
archiwum calib-bialkow.tar.gz. Po skopiowaniu i rozpakowaniu
archiwum (tar xzvf calib-bialkow.tar.gz) należy skopiować plik 
.calib_phot_bialkow_rc do swojego katalogu domowego, a następnie
wpisać w tym pliku odpowiednią ścieżkę do katalogu z rozpakowanymi 
skryptami (.../calib-bialkow). Po wydaniu polecenia
 source $HOME/.calib_phot_bialkow_rc 
wszystkie programy/skrypty można uruchamiać w dowolnym katalogu
roboczym, w którym znajdują się odpowiednie obrazy kalibracyjne
oraz naukowe.

Do poprawnego działania wszystkich elementów skryptu wymagane są 
następujące programy zainstalowane w systemie Linux:
- bash, wersja >= 4.0,
- python, wersja >= 2.6,
- moduły języka python: numpy, pyfits, f2n,
- IRAF/PyRAF,
- gawk, sed, grep, gvim
- eclipse (ESO),
- gnuplot,
- jday,
- netpbm,  (http://netpbm.sourceforge.net)
- convert (ImageMagick http://www.imagemagick.org)

Dokumentacja i instrukcja instalacji modułu f2n znajduje się pod adresem
    http://obswww.unige.ch/~tewes/f2n_dot_py/

### 2. Argumenty wywołania, plik z dziennikiem obserwacyjnym.
  
Składnia i krótki opis wyświetlane są po uruchominiu bez argumentów.
Pierwszym i jedynym obowiązkowym argumentem jest nazwa pliku 
zawierającego odpowienio sformatowany dziennik obserwacyjny (DO).
W tym przypadku program czyta plik o zadanej nazwie, który 
powinien znajdować się w aktualnym katalogu. 
Drugi argument, pojedyńcza litera "l", jest opcjonalny i wymusza 
utworzenie nowego pliku zawierającego DO, o nazwie podanej jako pierwszy
argument. Plik ten jest tworzony na podstawie zawartości nagłówków 
wszystkich plików FITS znajdujących się w aktualnym katalogu.

Po każdym uruchomieniu skryptu z poprawnymi argumentami (jednym lub dwoma),
wyświetlany jest wedytorze vim (gvim) dziennik obserwacyjny w celu sprawdzenia
jego porawności i kompletności. W tym momencie można dokonać ostatnich 
korekt (a następnie je zapisać). Zbiór danych kalibracyjnych oraz 
naukowych objętych dalszym działaniem skryptu zdefiniowany jest w pliku DO. 
Do utworzenia nowego pliku z DO używany jest program mklog-bialkow.awk,
który może być uruchomiany niezależnie. 
Pliki FITS występujące w DO powinny znajdować się w aktualnym katalogu.


### 3. Ustawienia środowiska i zmiennych wewnętrznych.

Dostęp do wszystkich potrzebnych skryptów i danych pomocniczych
ustawiany jest przez wydanie polecenia:
 source .calib_phot_bialkow_rc
które tworzy zmienną środowiskową Calib_PATH i dopisuje odpowiednie 
lokalizacje do zmiennej systemowej PATH. 
Oczywiście wcześniej należy skopiować plik .calib_phot_bialkow_rc 
do własnego katalogu  domowego i wpisać w nim poprawne ścieżki do 
katalogów zawierających oprogramowanie do automatycznej kalibracji 
(Calib_PATH) i redukcji (Phot_PATH).
Jeśli chcemy mieć dostęp do programów kalibracyjnych ustawiony na stałe 
to należy dopisać to polecenie do ustawień startowych powłoki, 
np. do pliku .bashrc jeśli domyślnie korzystany z powłoki bash.

Edytując plik calib_bialkow.bash można zmienić ustawienia kilku
zmiennych wewnętrznych zdefiniowanych w jednym bloku na początku skryptu.

Ścieżki do katalogów:

CALIB_FILES_DIR - zawiera wszystkie obrazy kalibracyjne utworzne 
przez skrypt i użyte do kalibracji oraz dane diagnostyczne dotyczące
procesu kalibracji.

CDATA_DIR - po wykonaniu skryptu zawiera wszystkie skalibrowane obrazy
obiektów (w nagłówku FITS: DATA-TYP=OBJECT). 
 
AUX_FILES_DIR - zawiera dodatkowe pliki używane podczas kalibracji, 
które nie są tworzone podczas wykonywania skryptu,
np. uśrednione obrazy typu DARK z długimi czasami naświetlania.

Nazwy plików z wzorcowymi obrazami typu DARK:
long_dark_2 (dla prędkości odczytu 2) 
long_dark_16 (dla prędkości odczytu 16)
oraz odpowiadające im czasy integracji:
long_dark_2_exp, long_dark_16_exp

filter_seq - lista filtrów używanych podczas obserwacji.

flat_max_v, flat_min_v  - definiują zakres wartości średnich (w ADU)
dla obrazów typu FLAT-FIELD, które będą używane w procesie kalibracji.


### 4. Opis działania skryptu.


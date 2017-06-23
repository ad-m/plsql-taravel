## Taravel

Realizacja bazy danych on-line dla systemu rejestracji wycieczek turystycznych projektu pracy zaliczeniowej pisanej w Instytucie Informatyki pod kierunkiem mgr Zbigniewa Młynarskiego.

Projekt został zaprojektowany jako podstawa dla systemu biura podróży. Zapewnia możliwość rejestracji oferty, a także oferty i stanu dostępności oferty. 

Należy podkreślić, że przeznaczeniem systemu nie jest obsługa zamówień złożonych on-line, stąd nie został wprowadzony mechanizm roli.

## Problematyka

Zrealizowany system został projektowany w celu wewnętrznego usprawnienia pracy biura turystycznego odpowiedzialnego za organizacje wycieczek turystyczny. System informatyczny zapewnia możliwość rejestracji wycieczki, następnie zarejestrowania zamówienia na daną wycieczkę i ewidencje gości dla danego zamówienia. Dokonywane są obliczenia należnosci. Wówczas staje się adekwatnym odnotnowanie płatności spośród form płatności zdefiniownych w systemie. System informatyczny zapewnia też ewidencjonowanie lokalizacji wycieczek, a także kraj.

## Technologia

Projekt został zrealizowany zgodnie z postawionymi wymaganiami w technologii PL/SQL. Ponadto został wykorzystany Bootstrap v4. Zaczerpnięto m. in. z opublikowanych przykładów projektu.
Należy podkreślić, że z powodu zależności projektu konieczne jest wykorzystanie stosunkowo nowoczesnej przeglądarki.

## Instalacja

Projekt wykorzystuje standardowe mechanizmy budowania oparte na ``Makefile``. W celu zbudowania projektu należy wykonać ``make build``. Wówczas stają się dostępne są trzy pliki:

* ``build/db.sql`` - zapewnia strukturę bazy danych i minimalne inicjalne dane dla aplikacji,
* ``build/web.sql`` - zapewnia strukturę interfejsu webowego aplikacji, ze względu na cykliczne odwołania może zachodzić konieczność kilkukrotnego wczytania tych instrukcji.
* ``build/project.sql`` - skondensowane w/w.

Domyślne dane logowania to "admin" i "pass". Wprowadzona rejestracja nie umożliwia zalogowanie na tak utworzono konto. Gromadzone jest hasło użytkownika, ale konieczne jest nadanie uprawnień logowania dla użytkownika przez administratora.

## Zakres funkcjonalności

* Zarządzanie gośćmi
  * dodawanie gościa
  * usuwanie gościa
  * edycja gościa
  * wykaz gości

* Zarządzenie lokalizacji
  * dodawanie lokalizacji
  * usuwanie lokalizacji
  * edycja lokalizacji
  * wykaz lokalizacji

* Zarządzanie zamówieniami
  * dodawanie zamówienia
  * usuwanie zamówienia
  * edycja zamówienia
  * wykaz zamówienia

* Zarządzanie płatnościami
  * dodawanie płatności
  * usuwanie płatności
  * edycja płatności
  * wykaz płatności

* Zarządzenie formami płatności
  * dodawanie formy płatności
  * usuwanie formy płatności
  * edycja formy płatności
  * wykaz formy płatności
  * dezaktywacja formy płatności

* Zarządzanie ofertami wycieczki
  * dodawanie oferty wycieczki
  * usuwanie oferty wycieczki
  * edycja oferty wycieczki
  * wykaz oferty wycieczki
  * archiwizacja oferty wycieczki
  * wyszukiwanie oferty wycieczki

* Zarządzanie użytkownikami
  * rejestracja użytkownika
  * logowanie użytkownika
 
## Uwagi

* Model aplikacji w nieznacznym stopniu uległ modyfikacji. Aktualny schemat modelu bazy danych jest dostępny w pliku ``01-Taravel-schemat-modelu-koncowy.png``. Przyjęto politykę ograniczonej ingerencji w zaakceptowany model nawet kosztem innych wartości. 
* Aplikacja nie została przeznaczona do publikacji on-line, ze względu na ograniczone mechanizmy kontroli dostępu, nie mniej zrealizowano logowanie wykorzystując własną implementacje sesji.
 
## Cechy niefunkcjonalne

* Obsługa równoległych wycieczek
* Obsługa do 1000 archiwalnych wycieczek
* Graficzny interfejs użytkownika
* Aplikacja trójwarstwowa
* Estetyczny i schludny wygląd

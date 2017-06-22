## Taravel

Realizacja bazy danych on-line dla systemu rejestracji wycieczek turystycznych projektu pracy zaliczeniowej pisanej w Instytucie Informatyki pod kierunkiem mgr Zbigniewa Młynarskiego.

Projekt został zaprojektowany jako podstawa dla systemu biura podróży. Zapewnia możliwość rejestracji oferty, a także oferty i stanu dostępności oferty. 

Należy podkreślić, że przeznaczeniem systemu nie jest obsługa zamówień złożonych on-line, stąd nie został wprowadzony mechanizm roli.

## Technologia

Projekt został zrealizowany zgodnie z postawionymi wymaganiami w technologii PL/SQL. Ponadto został wykorzystany Bootstrap v4. Zaczerpnięto m. in. z opublikowanych przykładów projektu.
Należy podkreślić, że z powodu zależności projektu konieczne jest wykorzystanie stosunkowo nowoczesnej przeglądarki.

## Instalacja

Projekt wykorzystuje standardowe mechanizmy budowania oparte na ``Makefile``. W celu zbudowania projektu należy wykonać ``make build``. Wówczas stają się dostępne są trzy pliki:

* ``build/db.sql`` - zapewnia  strukturę bazy danych i dane zgromadzone w aplikacji
* ``build/web.sql`` - zapewnia strukturę interfejsu webowego aplikacji.
* ``build/project.sql`` - skondensowane w/w.

## Uwagi

* Model aplikacji w nieznacznym stopniu uległ modyfikacji. Aktualny schemat modelu bazy danych jest dostępny w pliku ``01-Taravel-schemat-modelu-koncowy.png``.
* Aplikacja nie została przeznaczona do publikacji on-line, ze względu na ograniczone mechanizmy kontroli dostępu, nie mniej zrealizowano logowanie wykorzystując własną implementacje sesji.

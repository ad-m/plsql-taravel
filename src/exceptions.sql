    EXCEPTION
        when NO_DATA_FOUND then
            danger('Oh no!', 'Nie znaleziono danych');
        WHEN PROGRAM_ERROR THEN
            danger('Oh no!', 'Blad bloku procedury');
        WHEN STORAGE_ERROR THEN
            danger('Oh no!', 'Blad pamieci');
        when INVALID_NUMBER then
            danger('Oh no!', 'Wprowadzono niepoprawna wartosc'); 
        when VALUE_ERROR then
            danger('Oh no!', 'Blad konwersji typów danych'); 
        when DUP_VAL_ON_INDEX then
            danger('Oh no!', 'Wprowadzone dane nie sa unikalne');
        when others then
            danger('Oh no!', 'Wystapil blad');

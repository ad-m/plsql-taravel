    EXCEPTION
        when NO_DATA_FOUND then
            ADAM_GUI.danger('Oh no!', 'Nie znaleziono danych');
        WHEN PROGRAM_ERROR THEN
            ADAM_GUI.danger('Oh no!', 'Blad bloku procedury');
        WHEN STORAGE_ERROR THEN
            ADAM_GUI.danger('Oh no!', 'Blad pamieci');
        when INVALID_NUMBER then
            ADAM_GUI.danger('Oh no!', 'Wprowadzono niepoprawna wartosc'); 
        when VALUE_ERROR then
            ADAM_GUI.danger('Oh no!', 'Blad konwersji typów danych'); 
        when DUP_VAL_ON_INDEX then
            ADAM_GUI.danger('Oh no!', 'Wprowadzone dane nie sa unikalne');
        when others then
            ADAM_GUI.danger(SQLCODE, sqlerrm);


    EXCEPTION when others then
            ADAM_GUI.danger(SQLCODE, sqlerrm);

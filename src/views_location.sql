SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE ADAM_LOCATION AS
PROCEDURE home;
PROCEDURE list(page number);
PROCEDURE detail(id_v number);
PROCEDURE create_form;
PROCEDURE create_sql (name_v varchar2, country_id_v number);
PROCEDURE update_form (id_v number);
PROCEDURE update_sql (id_v number, name_v varchar2, country_id_v number);
PROCEDURE delete_form(id_v number);
PROCEDURE delete_sql(id_v number);
PROCEDURE form_select(id varchar2, label varchar2, name varchar2, selected number);

END ADAM_LOCATION;
/
SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY ADAM_LOCATION AS
PROCEDURE home IS BEGIN ADAM_LOCATION.list(0); END home; 
PROCEDURE list(page number) IS BEGIN
    ADAM_GUI.header('ADAM_LOCATION');
    ADAM_GUI.button('ADAM_LOCATION.create_form', 'Dodaj lokalizacje');
    htp.print('<ul  class="nav flex-column">');
    FOR dane IN (SELECT location.id, location.name AS name, continent, country.name AS country_name 
               FROM location INNER JOIN country ON location.country_id = country.id) LOOP
        htp.print('<li  class="nav-item"><a  class="nav-link" href="' || ADAM_GUI.url('ADAM_LOCATION.detail?id_v=' || dane.id ) || '">' || dane.name ||' (' || dane.country_name || ')</a></li>');
    END LOOP;
    htp.print('</ul>');
    ADAM_GUI.footer;
    exception when others then
            ADAM_GUI.danger(SQLCODE, sqlerrm);
END list; 
PROCEDURE detail(id_v number) IS 
    location_v location%ROWTYPE;
    country_v country%ROWTYPE;
    trip_count NUMBER;
    BEGIN 
    ADAM_GUI.header('ADAM_LOCATION');
    BEGIN
        SELECT * INTO location_v FROM location WHERE id=id_v;
        SELECT * INTO country_v FROM country WHERE id=location_v.country_id;
        SELECT COUNT(id) INTO trip_count FROM trip WHERE location_id=id_v;
        ADAM_GUI.button_group('ADAM_LOCATION.update_form?id_v=' || id_v, 'Aktualizuj',
                              'ADAM_LOCATION.delete_form?id_v=' || id_v, 'Usuń');
        htp.print('<h1>' || location_v.name || '</h2>');
        htp.tableOpen('class="table"');
        ADAM_GUI.two_column('Kraj', '<a href="' || ADAM_GUI.url('ADAM_LOCATION.detail?id_v=' || location_v.country_id ) || '">' || country_v.name || '</a>');
        ADAM_GUI.two_column('Liczba wycieczek', trip_count);
        htp.tableClose;
        IF trip_count > 0 THEN
            htp.print('<h2>Wycieczki do lokalizacji</h2>');
            htp.print('<ul  class="nav flex-column">');
            FOR dane IN (SELECT * FROM trip WHERE location_id = id_v) LOOP
                htp.print('<li  class="nav-item"><a  class="nav-link" href="' || ADAM_GUI.url('ADAM_TRIP.detail?id_v=' || dane.id ) || '">' || dane.name || '</a></li>');
            END LOOP;
            htp.print('</ul>');
        END IF; 
    END;
    ADAM_GUI.footer;
END detail; 
PROCEDURE create_form IS BEGIN 
    ADAM_GUI.header('ADAM_LOCATION');
    htp.print('<form action="' || ADAM_GUI.url('ADAM_LOCATION.create_sql') || '">');
    ADAM_GUI.form_input_clean('name_v', 'text', 'Nazwa', 'name_v');
    ADAM_COUNTRY.form_select('country_id_v', 'Kraj', 'country_id_v', NULL);
    ADAM_GUI.form_submit('Dodaj lokalizacje');
    htp.print('</form>');
    ADAM_GUI.footer;
END create_form; 

PROCEDURE create_sql (name_v varchar2, country_id_v number) IS BEGIN 
    ADAM_GUI.header('ADAM_LOCATION');
    BEGIN
        INSERT INTO location VALUES (0, name_v, country_id_v);
        ADAM_GUI.success('Well done!', 'Dane zostały pomyślnie zapisane!');
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
                ADAM_GUI.danger('Oh no!', 'Wystapil blad');
    END;
    ADAM_GUI.footer;
END create_sql;

PROCEDURE update_form(id_v number) IS 
    location_v location%ROWTYPE;
    BEGIN 
    ADAM_GUI.header('ADAM_LOCATION');
    BEGIN
    SELECT * INTO location_v FROM location WHERE id=id_v;
    htp.print('<form action="' || ADAM_GUI.url('ADAM_LOCATION.update_sql') || '">');
    htp.formHidden('id_v', id_v, '');
    ADAM_GUI.form_input('name_v', 'text', 'Nazwa', 'name_v', location_v.name);
    ADAM_COUNTRY.form_select('country_id_v', 'Kraj', 'country_id_v', location_v.country_id);
    ADAM_GUI.form_submit('Dodaj lokalizacje');
    htp.print('</form>');
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
                ADAM_GUI.danger('Oh no!', 'Wystapil blad');
    END;
    ADAM_GUI.footer;
END update_form; 

PROCEDURE update_sql (id_v number, name_v varchar2, country_id_v number) IS BEGIN 
    ADAM_GUI.header('ADAM_LOCATION');
    BEGIN
        UPDATE location SET name=name_v, country_id=country_id_v WHERE id=id_v ;
        ADAM_GUI.success('Well done!', 'Dane zostały pomyślnie zaktualizowane!');
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
                ADAM_GUI.danger('Oh no!', 'Wystapil blad');
    END;
    ADAM_GUI.footer;
END update_sql;

PROCEDURE form_select(id varchar2, label varchar2, name varchar2, selected number) IS
  BEGIN
  htp.print('<div class="form-group">
    <label for="' || id || '">' || label || '</label>
    <select name="' || name || '" class="form-control" id="' || id || '">');
  FOR dane IN (SELECT location.id, location.name AS name, continent, country.name AS country_name 
               FROM location INNER JOIN country ON location.country_id = country.id) LOOP
      ADAM_GUI.form_option(dane.id, dane.name ||' (' || dane.country_name || ')',  selected);
  END LOOP;
  htp.print('</select>
  </div>');
  NULL;
END form_select;

PROCEDURE delete_form(id_v number) IS 
BEGIN 
    ADAM_GUI.delete_form(id_v, 'ADAM_LOCATION', 'name', 'location');
END delete_form;

PROCEDURE delete_sql(id_v number) IS 
    my_integration_error EXCEPTION;
    PRAGMA EXCEPTION_INIT (my_integration_error, -20101);
    count_trip number;
    location_name location.name%TYPE;
BEGIN
    ADAM_GUI.header('ADAM_LOCATION');
    BEGIN
        SELECT COUNT(id) INTO count_trip FROM trip WHERE location_id = id_v;
        IF count_trip > 0 THEN
            raise_application_error(-20101, 'Naruszenie integralności');
        END IF;
        SELECT name INTO location_name FROM location WHERE id = id_v;
        DELETE FROM location WHERE id = id_v;
        ADAM_GUI.success('Well done!', 'Pomyslnie usunieto "' || location_name || '".');
        EXCEPTION
            when my_integration_error then
                ADAM_GUI.danger('Oh no!', 'Naruszenie integralności');
            when NO_DATA_FOUND then
                ADAM_GUI.danger('Oh no!', 'Nie znaleziono danych');
            WHEN STORAGE_ERROR THEN
                ADAM_GUI.danger('Oh no!', 'Blad pamieci');
            when INVALID_NUMBER then
                ADAM_GUI.danger('Oh no!', 'Wprowadzono niepoprawna wartosc'); 
            when VALUE_ERROR then
                ADAM_GUI.danger('Oh no!', 'Blad konwersji typów danych');
            when others then
                ADAM_GUI.danger(SQLCODE, sqlerrm);
    END;
    ADAM_GUI.footer;
END delete_sql;

END ADAM_LOCATION;
/

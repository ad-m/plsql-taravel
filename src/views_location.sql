SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE ADAM_LOCATION AS
PROCEDURE home;
PROCEDURE show_locations(page number);
PROCEDURE form_select(id varchar2, label varchar2, name varchar2);
PROCEDURE show_location(id_v number);
PROCEDURE add_location_form;
PROCEDURE add_location_sql (name_v varchar2, country_id_v number);
PROCEDURE update_location_form (id_v number);
PROCEDURE update_location_sql (id_v number, name_v varchar2, country_id_v number);
END ADAM_LOCATION;
/
SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY ADAM_LOCATION AS
PROCEDURE home IS BEGIN ADAM_LOCATION.show_locations(0); END home; 
PROCEDURE show_locations(page number) IS BEGIN
    ADAM_GUI.header('ADAM_LOCATION');
    ADAM_GUI.button('ADAM_LOCATION.add_location_form', 'Dodaj lokalizacje');
    htp.print('<ul  class="nav flex-column">');
    FOR dane IN (SELECT location.id, location.name AS name, continent, country.name AS country_name 
               FROM location INNER JOIN country ON location.country_id = country.id) LOOP
        htp.print('<li  class="nav-item"><a  class="nav-link" href="' || ADAM_GUI.url('ADAM_LOCATION.show_location?id_v=' || dane.id ) || '">' || dane.name ||' (' || dane.country_name || ')</a></li>');
    END LOOP;
    htp.print('</ul>');
    ADAM_GUI.footer;
END show_locations; 
PROCEDURE show_location(id_v number) IS 
    location_v location%ROWTYPE;
    country_v country%ROWTYPE;
    trip_count NUMBER;
    BEGIN 
    ADAM_GUI.header('ADAM_LOCATION');
    BEGIN
        SELECT * INTO location_v FROM location WHERE id=id_v;
        SELECT * INTO country_v FROM country WHERE id=location_v.country_id;
        SELECT COUNT(id) INTO trip_count FROM trip WHERE location_id=id_v;
        ADAM_GUI.button('ADAM_LOCATION.update_location_form?id_v=' || id_v, 'Zaktualizuj lokalizacje');
        htp.tableOpen('class="table"');
        ADAM_GUI.two_column('Lokalizacja', location_v.name);
        ADAM_GUI.two_column('Kraj', country_v.name);
        ADAM_GUI.two_column('Liczba wycieczek', trip_count);
        htp.tableClose;
    END;
    ADAM_GUI.footer;
END show_location; 
PROCEDURE add_location_form IS BEGIN 
    ADAM_GUI.header('ADAM_LOCATION');
    htp.print('<form action="' || ADAM_GUI.url('ADAM_LOCATION.add_location_sql') || '">');
    ADAM_GUI.form_input_clean('name_v', 'text', 'Nazwa', 'name_v');
    ADAM_COUNTRY.form_select('country_id_v', 'Kraj', 'country_id_v', NULL);
    ADAM_GUI.form_submit('Dodaj lokalizacje');
    htp.print('</form>');
    ADAM_GUI.footer;
END add_location_form; 

PROCEDURE add_location_sql (name_v varchar2, country_id_v number) IS BEGIN 
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
END add_location_sql;

PROCEDURE update_location_form(id_v number) IS 
    location_v location%ROWTYPE;
    BEGIN 
    ADAM_GUI.header('ADAM_LOCATION');
    BEGIN
    SELECT * INTO location_v FROM location WHERE id=id_v;
    htp.print('<form action="' || ADAM_GUI.url('ADAM_LOCATION.update_location_sql') || '">');
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
END update_location_form; 

PROCEDURE update_location_sql (id_v number, name_v varchar2, country_id_v number) IS BEGIN 
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
END update_location_sql;

PROCEDURE form_select(id varchar2, label varchar2, name varchar2) IS
  BEGIN
  htp.print('<div class="form-group">
    <label for="' || id || '">' || label || '</label>
    <select name="' || name || '" class="form-control" id="' || id || '">');
  FOR dane IN (SELECT location.id, location.name AS name, continent, country.name AS country_name 
               FROM location INNER JOIN country ON location.country_id = country.id) LOOP
      htp.print('<option value=' || dane.id || '>' || dane.name ||' (' || dane.country_name || ')</option>');
  END LOOP;
  htp.print('</select>
  </div>');
  NULL;
END form_select;


END ADAM_LOCATION;


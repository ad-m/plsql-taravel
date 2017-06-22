SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE ADAM_COUNTRY AS
PROCEDURE home;
PROCEDURE list(page number);
PROCEDURE detail(id_v number);
PROCEDURE create_form;
PROCEDURE create_sql (name_v varchar2, continent_v number);
PROCEDURE update_form(id_v number);
PROCEDURE update_sql (id_v number, name_v varchar2, continent_v number);
PROCEDURE delete_form(id_v number);
PROCEDURE delete_sql(id_v number);
PROCEDURE form_select(id varchar2, label varchar2, name varchar2, selected varchar2);
PROCEDURE form_select_continent(id varchar2, label varchar2, name varchar2, selected varchar2);
END ADAM_COUNTRY;
/
SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY ADAM_COUNTRY AS
PROCEDURE home IS BEGIN ADAM_COUNTRY.list(0); END home; 
PROCEDURE list(page number) IS BEGIN
    ADAM_GUI.header('ADAM_COUNTRY');
    IF ADAM_USER.is_admin = TRUE THEN
        ADAM_GUI.button('ADAM_COUNTRY.create_form', 'Dodaj kraj');
    END IF ;
    htp.print('<ul  class="nav flex-column">');
    FOR dane IN (SELECT * FROM country) LOOP
        htp.print('<li  class="nav-item"><a  class="nav-link" href="' || ADAM_GUI.url('ADAM_COUNTRY.detail?id_v=' || dane.id ) || '">' || dane.name || '</a></li>');
    END LOOP;
    htp.print('</ul>');
    ADAM_GUI.footer;
END list; 
PROCEDURE detail(id_v number) IS 
    country_v country%ROWTYPE;
    location_count NUMBER;
    continent_name VARCHAR2(25);
    BEGIN 
    ADAM_GUI.header('ADAM_COUNTRY');
    BEGIN
        SELECT * INTO country_v FROM country WHERE id=id_v;
        SELECT DECODE(country_v.continent, 1, 'Europa',
                                              2, 'Azja',
                                                 'inne') INTO continent_name FROM country WHERE id=id_v;
        SELECT COUNT(id) INTO location_count FROM location WHERE country_id=id_v;
        IF ADAM_USER.is_admin = TRUE THEN
            ADAM_GUI.button_group('ADAM_COUNTRY.update_form?id_v=' || id_v, 'Aktualizuj',
                                  'ADAM_COUNTRY.delete_form?id_v=' || id_v, 'Usuń');
        END IF;
        htp.print('<h1>' || country_v.name || '</h1>');
        htp.tableOpen('class="table"');
        ADAM_GUI.two_column('Kontynent', continent_name);
        ADAM_GUI.two_column('Liczba lokalizacji', location_count);
        htp.tableClose;
        IF location_count > 0 THEN
            htp.print('<h2>Lokalizacje dla kraju</h2>');
            htp.print('<ul  class="nav flex-column">');
            FOR dane IN (SELECT * FROM location WHERE country_id = id_v) LOOP
                htp.print('<li  class="nav-item"><a  class="nav-link" href="' || ADAM_GUI.url('ADAM_LOCATION.detail?id_v=' || dane.id ) || '">' || dane.name || '</a></li>');
            END LOOP;
            htp.print('</ul>');
        END IF; 
    END;
    ADAM_GUI.footer;
END detail; 
PROCEDURE create_form IS BEGIN 
    ADAM_GUI.header('ADAM_COUNTRY');
    htp.print('<form action="' || ADAM_GUI.url('ADAM_COUNTRY.create_sql') || '">');
    ADAM_GUI.form_input_clean('name_v', 'text', 'Nazwa', 'name_v');
    ADAM_COUNTRY.form_select_continent('continent_v', 'Kontynent', 'continent_v', -1);
    ADAM_GUI.form_submit('Dodaj kraj');
    htp.print('</form>');
    ADAM_GUI.footer;
END create_form; 

PROCEDURE create_sql (name_v varchar2, continent_v number) IS BEGIN 
    ADAM_GUI.header('ADAM_COUNTRY');
    BEGIN
        INSERT INTO country VALUES (0, continent_v, name_v);
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
            when others then
                ADAM_GUI.danger('Oh no!', 'Wystapil blad');
    END;
    ADAM_GUI.footer;
END create_sql;

PROCEDURE form_select(id varchar2, label varchar2, name varchar2, selected varchar2) IS
  BEGIN
  htp.print('<div class="form-group">
    <label for="' || id || '">' || label || '</label>
    <select name="' || name || '" class="form-control" id="' || id || '">');
  FOR dane IN (SELECT * FROM country) LOOP
    ADAM_GUI.form_option(dane.id, dane.name, selected);
  END LOOP;
  htp.print('</select>
  </div>');
  NULL;
END form_select;

PROCEDURE update_form(id_v number) IS 
    country_v country%ROWTYPE;
    BEGIN 
    ADAM_GUI.header('ADAM_COUNTRY');
    BEGIN
    NULL;
    SELECT * INTO country_v FROM country WHERE id=id_v;
    htp.print('<form action="' || ADAM_GUI.url('ADAM_COUNTRY.update_sql') || '">');
    htp.formHidden('id_v', id_v, '');
    ADAM_GUI.form_input('name_v', 'text', 'Nazwa', 'name_v', country_v.name);
    ADAM_COUNTRY.form_select_continent('continent_v', 'Kontynent', 'continent_v', country_v.continent);
    ADAM_GUI.form_submit('Zaktualizuj lokalizacje');
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
            when others then
                ADAM_GUI.danger(SQLCODE, sqlerrm);
    END;
    ADAM_GUI.footer;
END update_form; 

PROCEDURE update_sql (id_v number, name_v varchar2, continent_v number) IS BEGIN 
    ADAM_GUI.header('ADAM_COUNTRY');
    BEGIN
        UPDATE country SET name=name_v, continent=continent_v WHERE id=id_v;
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
            when others then
                ADAM_GUI.danger(SQLCODE, sqlerrm);
    END;
    ADAM_GUI.footer;
END update_sql;

PROCEDURE delete_form(id_v number) IS 
BEGIN 
    ADAM_GUI.delete_form(id_v, 'ADAM_COUNTRY', 'name', 'country');
END delete_form;

PROCEDURE delete_sql(id_v number) IS 
    my_integration_error EXCEPTION;
    PRAGMA EXCEPTION_INIT (my_integration_error, -20101);
    count_location number;
    country_name country.name%TYPE;
BEGIN
    ADAM_GUI.header('ADAM_COUNTRY');
    BEGIN
        SELECT COUNT(id) INTO count_location FROM location WHERE country_id = id_v;
        IF count_location > 0 THEN
            raise_application_error(-20101, 'Naruszenie integralności');
        END IF;
        SELECT name INTO country_name FROM country WHERE id = id_v;
        DELETE FROM country WHERE id = id_v;
        ADAM_GUI.success('Well done!', 'Pomyslnie usunieto "' || country_name || '".');
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

PROCEDURE form_select_continent(id varchar2, label varchar2, name varchar2, selected varchar2) IS
BEGIN
    htp.print('<div class="form-group">');
    htp.print('<label for="' || id || '">' || label || '</label>');
    htp.print('<select name="' || name || '" class="form-control" id="' || id || '">');
    ADAM_GUI.form_option('1', 'Europa', selected);
    ADAM_GUI.form_option('0', 'Azja', selected);
    ADAM_GUI.form_option('0', 'Inne',  selected);
    htp.print('</select>');
    htp.print('</div>');
END form_select_continent;

END ADAM_COUNTRY;
/

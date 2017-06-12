SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE ADAM_COUNTRY AS
PROCEDURE home;
PROCEDURE show_countrys(page number);
PROCEDURE form_select(id varchar2, label varchar2, name varchar2, selected varchar2);
PROCEDURE show_country(id_v number);
PROCEDURE add_country_form;
PROCEDURE add_country_sql (name_v varchar2, continent_v number);
PROCEDURE update_country_form(id_v number);
PROCEDURE update_country_sql (id_v number, name_v varchar2, continent_v number);
PROCEDURE form_select_continent(id varchar2, label varchar2, name varchar2, selected varchar2);
END ADAM_COUNTRY;
/
SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY ADAM_COUNTRY AS
PROCEDURE home IS BEGIN ADAM_COUNTRY.show_countrys(0); END home; 
PROCEDURE show_countrys(page number) IS BEGIN
    ADAM_GUI.header('ADAM_COUNTRY');
    ADAM_GUI.button('ADAM_COUNTRY.add_country_form', 'Dodaj kraj');
    htp.print('<ul  class="nav flex-column">');
    FOR dane IN (SELECT * FROM country) LOOP
        htp.print('<li  class="nav-item"><a  class="nav-link" href="' || ADAM_GUI.url('ADAM_COUNTRY.show_country?id_v=' || dane.id ) || '">' || dane.name || '</a></li>');
    END LOOP;
    htp.print('</ul>');
    ADAM_GUI.footer;
END show_countrys; 
PROCEDURE show_country(id_v number) IS 
    country_v country%ROWTYPE;
    location_count NUMBER;
    BEGIN 
    ADAM_GUI.header('ADAM_COUNTRY');
    BEGIN
        SELECT * INTO country_v FROM country WHERE id=id_v;
        SELECT COUNT(id) INTO location_count FROM location WHERE country_id=id_v;
        ADAM_GUI.button('ADAM_COUNTRY.update_country_form?id_v=' || id_v, 'Zaktualizuj kraj');
        htp.tableOpen('class="table"');
        ADAM_GUI.two_column('Kraj', country_v.name);
        -- , DECODE(country_v.continent, 1, 'Europa',
        --                                       2, 'Azja',
        --                                          'inne') AS continent_name
        -- ADAM_GUI.two_column('Kontynent', country_v.continent_name);
        ADAM_GUI.two_column('Liczba lokalizacji', location_count);
        htp.tableClose;
    END;
    ADAM_GUI.footer;
END show_country; 
PROCEDURE add_country_form IS BEGIN 
    ADAM_GUI.header('ADAM_COUNTRY');
    htp.print('<form action="' || ADAM_GUI.url('ADAM_COUNTRY.add_country_sql') || '">');
    ADAM_GUI.form_input_clean('name_v', 'text', 'Nazwa', 'name_v');
    ADAM_COUNTRY.form_select_continent('continent_v', 'Kontynent', 'continent_v', -1);
    ADAM_GUI.form_submit('Dodaj kraj');
    htp.print('</form>');
    ADAM_GUI.footer;
END add_country_form; 

PROCEDURE add_country_sql (name_v varchar2, continent_v number) IS BEGIN 
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
            when DUP_VAL_ON_INDEX then
                ADAM_GUI.danger('Oh no!', 'Wprowadzone dane nie sa unikalne');
            when others then
                ADAM_GUI.danger('Oh no!', 'Wystapil blad');
    END;
    ADAM_GUI.footer;
END add_country_sql;

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

PROCEDURE update_country_form(id_v number) IS 
    country_v country%ROWTYPE;
    BEGIN 
    ADAM_GUI.header('ADAM_COUNTRY');
    BEGIN
    NULL;
    SELECT * INTO country_v FROM country WHERE id=id_v;
    htp.print('<form action="' || ADAM_GUI.url('ADAM_COUNTRY.update_country_sql') || '">');
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
            when DUP_VAL_ON_INDEX then
                ADAM_GUI.danger('Oh no!', 'Wprowadzone dane nie sa unikalne');
            when others then
                ADAM_GUI.danger('Oh no!', 'Wystapil blad');
    END;
    ADAM_GUI.footer;
END update_country_form; 

PROCEDURE update_country_sql (id_v number, name_v varchar2, continent_v number) IS BEGIN 
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
            when DUP_VAL_ON_INDEX then
                ADAM_GUI.danger('Oh no!', 'Wprowadzone dane nie sa unikalne');
            when others then
                ADAM_GUI.danger('Oh no!', 'Wystapil blad');
    END;
    ADAM_GUI.footer;
END update_country_sql;

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


SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE ADAM_TRIP AS
PROCEDURE home;
PROCEDURE list(page number);
PROCEDURE detail(id_v number);
PROCEDURE create_form;
PROCEDURE create_sql(base_price_v integer,
                        description_v varchar2,
                        main_image_v varchar2,
                        name_v varchar2,
                        space_v integer,
                        location_id_v integer);
PROCEDURE update_form(id_v varchar2);
PROCEDURE update_sql(id_v number,
                          base_price_v number,
                          description_v varchar2,
                          main_image_v varchar2,
                          name_v varchar2,
                          space_v number,
                          location_id_v number,
                          created_on_v date,
                          modified_on_v date,
                          active_v smallint);
PROCEDURE delete_form (id_v number);
PROCEDURE delete_sql (id_v number);
END ADAM_TRIP;
/
SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY ADAM_TRIP AS
PROCEDURE home IS BEGIN ADAM_TRIP.list(0); END home; 
PROCEDURE list(page number) IS BEGIN
    ADAM_GUI.header('ADAM_TRIP');
    ADAM_GUI.button('ADAM_TRIP.create_form', 'Dodaj wycieczkę');
    htp.print('<table>');
    FOR dane IN (SELECT * FROM trip) LOOP
        htp.print('<tr>');
        htp.print('<td>' || dane.name || '</td>');
        htp.print('<td><a href="' || ADAM_GUI.url('ADAM_TRIP.detail?id_v=' || dane.id ) ||  '">Details</a></td>');
        htp.print('</tr>');
    END LOOP;
    htp.print('</table>');
    ADAM_GUI.footer;
END list; 
PROCEDURE detail(id_v number) IS 
    trip_v trip%ROWTYPE;
    location_v location%ROWTYPE;
    country_v country%ROWTYPE;
    order_count NUMBER;
    BEGIN 
    ADAM_GUI.header('ADAM_TRIP');
    BEGIN
    SELECT * INTO trip_v FROM trip WHERE id=id_v;
    SELECT * INTO location_v FROM location WHERE id=trip_v.location_id;
    SELECT * INTO country_v FROM country WHERE id=location_v.country_id;
    SELECT COUNT(id) INTO order_count FROM "order" WHERE trip_id=id_v;
    htp.tableOpen('class="table"');
    ADAM_GUI.two_column('Nazwa', trip_v.name);
    ADAM_GUI.two_column('Cena podstawowa', trip_v.base_price);
    ADAM_GUI.two_column('Miejsca', trip_v.space);
    ADAM_GUI.two_column('Opis', trip_v.description);
    ADAM_GUI.two_column('Obraz', '<img src="' || trip_v.main_image || '" width="100px"></img>');
    ADAM_GUI.two_column('Lokalizacja', location_v.name);
    ADAM_GUI.two_column('Kraj', country_v.name);
    ADAM_GUI.two_column('Liczba zamówień', order_count);
    htp.tableClose;
    END;
    ADAM_GUI.footer;
END detail; 
PROCEDURE create_form IS BEGIN 
    ADAM_GUI.header('ADAM_TRIP');
    htp.print('<form action="' || ADAM_GUI.url('ADAM_TRIP.create_sql') || '" method="GET">');
    ADAM_GUI.form_input_clean('name_v', 'text', 'Nazwa', 'name_v');
    ADAM_GUI.form_input_clean('base_price_v', 'text', 'Cena podstawowa', 'base_price_v');
    ADAM_GUI.form_input_clean('space_v','number', 'Liczba miejsc', 'space_v');
    ADAM_GUI.form_textarea_clean('description', 'Opis', 'description_v');
    ADAM_GUI.form_input_clean('main_image_v','url', 'Obraz (URL)', 'main_image_v');
    ADAM_LOCATION.form_select('location_id', 'Lokalizacja', 'location_id_v');
    ADAM_GUI.form_submit('Dodaj wycieczke');
    htp.print('</form>');
    ADAM_GUI.footer;
END create_form; 

PROCEDURE create_sql(base_price_v integer,
                        description_v varchar2,
                        main_image_v varchar2,
                        name_v varchar2,
                        space_v integer,
                        location_id_v integer) IS BEGIN 
    ADAM_GUI.header('ADAM_TRIP');
    BEGIN
        INSERT INTO trip VALUES (0, base_price_v, description_v, main_image_v, name_v, space_v, location_id_v, sysdate, sysdate, 1);
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
PROCEDURE update_form(id_v varchar2) IS BEGIN NULL; END update_form; 
PROCEDURE update_sql (id_v number,
                            base_price_v number,
                            description_v varchar2,
                            main_image_v varchar2,
                            name_v varchar2,
                            space_v number,
                            location_id_v number,
                            created_on_v date,
                            modified_on_v date,
                            active_v smallint) IS BEGIN NULL; END update_sql; 
PROCEDURE delete_form (id_v number) IS BEGIN NULL; END delete_form; 
PROCEDURE delete_sql (id_v number) IS BEGIN NULL; END delete_sql; 


END ADAM_TRIP;
/

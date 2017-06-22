SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE ADAM_TRIP AS
PROCEDURE home;
PROCEDURE list(page number);
PROCEDURE detail(id_v number);
PROCEDURE search(keyword varchar2);
PROCEDURE create_form;
PROCEDURE create_sql(base_price_v integer,
                        description_v varchar2,
                        main_image_v varchar2,
                        name_v varchar2,
                        space_v integer,
                        location_id_v integer);
PROCEDURE update_form(id_v number);
PROCEDURE update_sql (id_v number,
                    base_price_v number,
                    description_v varchar2,
                    main_image_v varchar2,
                    name_v varchar2,
                    space_v number,
                    location_id_v number,
                    active_v in number default 0);
PROCEDURE delete_form (id_v number);
PROCEDURE delete_sql (id_v number);

END ADAM_TRIP;
/
SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY ADAM_TRIP AS
PROCEDURE home IS BEGIN ADAM_TRIP.list(0); END home;

PROCEDURE search_form(keyword varchar2) IS BEGIN
    htp.print('<form class="form-inline float-right" action="' || ADAM_GUI.url('ADAM_TRIP.search') || '">
      <input class="form-control mr-sm-2" 
             type="text"
             name="keyword"
             value="' || keyword ||  '"
             placeholder="Search">
      <button class="btn btn-outline-success my-2 my-sm-0" type="submit">Search</button>
    </form>');
END search_form; 
PROCEDURE list(page number) IS BEGIN
    ADAM_GUI.header('ADAM_TRIP');
    htp.print('<div class="clearfix">');
    ADAM_TRIP.search_form('');
    ADAM_GUI.button('ADAM_TRIP.create_form', 'Dodaj wycieczkę');
    htp.print('</div>');
    htp.print('<div class="card-columns">');
    FOR dane IN (SELECT trip.main_image,trip.active, trip.name,trip.base_price,trip.description,trip.id,COUNT("order".id) AS order_count, COUNT(guest.id) AS guest_count, (trip.space - COUNT(guest.id)) AS free_space FROM trip LEFT JOIN "order" ON trip.id = "order".trip_id LEFT JOIN guest ON guest.order_id = "order".id GROUP BY trip.id,trip.name,trip.main_image,trip.base_price,trip.description,trip.space,trip.active) LOOP
        htp.print('<div class="card">
      <h3 class="card-header">'|| dane.name || '</h3>
        <img class="card-img-top" src="' || dane.main_image || '">
        <div class="card-block">
            <p class="card-text">'|| dane.description || '</p>');
        IF dane.active > 0 THEN 
            htp.print('<a href="ADAM_ORDER.create_form?trip_id='|| dane.id || '" class="btn btn-primary">Kup za '|| dane.base_price || ' / osoba</a>');
        END IF;
        htp.print('<a href="ADAM_TRIP.detail?id_v=' || dane.id || '" class="btn btn-secondary">Szczegóły</a>
        </div>
        <div class="card-footer text-muted">Wolne miejsca: ' || dane.free_space || ' • Zamówienia: '|| dane.order_count || ' • Zarezerwowanych: '|| dane.guest_count || '</div>
    </div>');
    END LOOP;
    htp.print('</div>');
    ADAM_GUI.footer;
END list;

PROCEDURE search(keyword varchar2) IS BEGIN
    ADAM_GUI.header('ADAM_TRIP');
    htp.print('<div class="clearfix">');
    ADAM_TRIP.search_form(keyword);
    ADAM_GUI.button('ADAM_TRIP.create_form', 'Dodaj wycieczkę');
    htp.print('</div>');
    htp.print('<div class="card-columns">');
    FOR dane IN (SELECT trip.main_image,trip.active, trip.name,trip.base_price,trip.description,trip.id,COUNT("order".id) AS order_count, COUNT(guest.id) AS guest_count, (trip.space - COUNT(guest.id)) AS free_space FROM trip
        LEFT JOIN "order" ON trip.id = "order".trip_id
        LEFT JOIN guest ON guest.order_id = "order".id
        WHERE ( trip.name LIKE '%' || keyword || '%' OR trip.description LIKE '%' || keyword || '%' ) 
        GROUP BY trip.id,trip.name,trip.main_image,trip.base_price,trip.description,trip.space,trip.active) LOOP
        htp.print('<div class="card">
      <h3 class="card-header">'|| dane.name || '</h3>
        <img class="card-img-top" src="' || dane.main_image || '">
        <div class="card-block">
            <p class="card-text">'|| dane.description || '</p>');
        IF dane.active > 0 THEN 
            htp.print('<a href="' || ADAM_GUI.url('ADAM_ORDER.create_form?trip_id=' || dane.id) || '" class="btn btn-primary">Kup za '|| dane.base_price || ' / osoba</a>');
        END IF;
        htp.print('<a href="' || ADAM_GUI.url('ADAM_TRIP.detail?id_v=' || dane.id ) || '" class="btn btn-secondary">Szczegóły</a>
        </div>
        <div class="card-footer text-muted">Wolne miejsca: ' || dane.free_space || ' • Zamówienia: '|| dane.order_count || ' • Zarezerwowanych: '|| dane.guest_count || '</div>
    </div>');
    END LOOP;
    htp.print('</div>');
    ADAM_GUI.footer;
END search;

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
    ADAM_GUI.button_group('ADAM_TRIP.update_form?id_v=' || id_v, 'Aktualizuj',
                          'ADAM_TRIp.delete_form?id_v=' || id_v, 'Usuń');
    htp.print('<a href="ADAM_ORDER.create_form?trip_id=' || trip_v.id || '" class="btn btn-secondary">Zamów</a>');
    htp.tableOpen('class="table"');
    ADAM_GUI.two_column('Nazwa', trip_v.name);
    ADAM_GUI.two_column('Cena podstawowa', trip_v.base_price);
    ADAM_GUI.two_column('Miejsca', trip_v.space);
    ADAM_GUI.two_column('Opis', trip_v.description);
    ADAM_GUI.two_column('Obraz', '<img src="' || trip_v.main_image || '" height="100px"></img>');
    ADAM_GUI.two_column('Lokalizacja', location_v.name);
    ADAM_GUI.two_column('Kraj', country_v.name);
    ADAM_GUI.two_column('Liczba zamówień', order_count);
    IF trip_v.active > 0 THEN
        ADAM_GUI.two_column('Aktywne?', 'Aktywne', 'table-succes');
    ELSE
        ADAM_GUI.two_column('Aktywne?', 'Nieaktywne' ,'table-danger');
    END IF;
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
    ADAM_LOCATION.form_select('location_id', 'Lokalizacja', 'location_id_v', NULL);
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

PROCEDURE update_form(id_v number) IS 
    trip_v trip%ROWTYPE;
    BEGIN 
    NULL;
    ADAM_GUI.header('ADAM_TRIP');
    BEGIN
    SELECT * INTO trip_v FROM trip WHERE id=id_v;
    htp.print('<form action="' || ADAM_GUI.url('ADAM_TRIP.update_sql') || '">');
    htp.formHidden('id_v', id_v, '');
    ADAM_GUI.form_input('name_v', 'text', 'Nazwa', 'name_v',trip_v.name);
    ADAM_GUI.form_input('base_price_v', 'text', 'Cena podstawowa', 'base_price_v', trip_v.base_price);
    ADAM_GUI.form_input('space_v','number', 'Liczba miejsc', 'space_v', trip_v.space);
    ADAM_GUI.form_textarea('description', 'Opis', 'description_v', trip_v.description);
    ADAM_GUI.form_input('main_image_v','url', 'Obraz (URL)', 'main_image_v', trip_v.main_image);
    ADAM_LOCATION.form_select('location_id', 'Lokalizacja', 'location_id_v', trip_v.location_id);
    ADAM_GUI.form_checkbox('active_v', 'Aktywne?', 'active_v', 1, trip_v.active);
    -- ADAM_COUNTRY.form_select('country_id_v', 'Kraj', 'country_id_v', trip_v.location_id);
    ADAM_GUI.form_submit('Aktualizuj');
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

PROCEDURE update_sql (id_v number,
                    base_price_v number,
                    description_v varchar2,
                    main_image_v varchar2,
                    name_v varchar2,
                    space_v number,
                    location_id_v number,
                    active_v in number default 0) IS BEGIN
    NULL; 
    ADAM_GUI.header('ADAM_TRIP');
    BEGIN
        NULL;
        UPDATE trip SET base_price=base_price_v,description=description_v,main_image=main_image_v,name=name_v,space=space_v, location_id=location_id_v, modified_on=sysdate, active=active_v WHERE id=id_v;
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

PROCEDURE delete_form(id_v number) IS 
BEGIN 
    ADAM_GUI.delete_form(id_v, 'ADAM_TRIP', 'name', 'trip');
END delete_form;

PROCEDURE delete_sql(id_v number) IS 
    my_integration_error EXCEPTION;
    PRAGMA EXCEPTION_INIT (my_integration_error, -20101);
    count_order number;
    label trip.name%TYPE;
BEGIN
    ADAM_GUI.header('ADAM_TRIP');
    BEGIN
        SELECT COUNT(id) INTO count_order FROM "order" WHERE trip_id = id_v;
        IF count_order > 0 THEN
            raise_application_error(-20101, 'Naruszenie integralności');
        END IF;
        SELECT name INTO label FROM trip WHERE id = id_v;
        DELETE FROM trip WHERE id = id_v;
        ADAM_GUI.success('Well done!', 'Pomyslnie usunieto "' || label || '".');
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


END ADAM_TRIP;
/


SET SERVEROUTPUT ON;
SHOW ERRORS;


CREATE OR REPLACE PACKAGE ADAM_ORDER AS
PROCEDURE home;
PROCEDURE list(page number);
PROCEDURE detail(id_v number);
PROCEDURE search(keyword varchar2);
PROCEDURE create_form;
PROCEDURE create_sql(note_v varchar2,
                    unit_price_v integer,
                    trip_id_v integer,
                    city_v varchar2,
                    name_v varchar2,
                    postcode_v varchar2,
                    street_v varchar2,
                    street_number_v varchar2,
                    taxpayer_id_v varchar2);
PROCEDURE update_form(id_v number);
PROCEDURE update_sql (id_v number,
                      note_v varchar2,
                    unit_price_v integer,
                    trip_id_v integer,);
PROCEDURE delete_form (id_v number);
PROCEDURE delete_sql (id_v number);

END ADAM_ORDER;
/
SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY ADAM_ORDER AS
PROCEDURE home IS BEGIN ADAM_ORDER.list(0); END home;

PROCEDURE search_form(keyword varchar2) IS BEGIN
    htp.print('<form class="form-inline float-right" action="' || ADAM_GUI.url('ADAM_ORDER.search') || '">
      <input class="form-control mr-sm-2" 
             type="text"
             name="keyword"
             value="' || keyword ||  '"
             placeholder="Search">
      <button class="btn btn-outline-success my-2 my-sm-0" type="submit">Search</button>
    </form>');
END search_form; 
PROCEDURE list(page number) IS BEGIN
    ADAM_GUI.header('ADAM_ORDER');
    htp.print('<div class="clearfix">');
    ADAM_ORDER.search_form('');
    ADAM_GUI.button('ADAM_ORDER.create_form', 'Dodaj wycieczkę');
    htp.print('</div>');
    htp.print('<div class="card-columns">');
    FOR dane IN (SELECT order.main_image,order.active, order.name,order.base_price,order.description,order.id,COUNT(guest.id) AS guest_count, COUNT(guest.id) AS guest_count, (order.space - COUNT(guest.id)) AS free_space FROM order LEFT JOIN guest ON order.id = guest.order_id LEFT JOIN guest ON guest.guest_id = guest.id GROUP BY order.id,order.name,order.main_image,order.base_price,order.description,order.space,order.active) LOOP
        htp.print('<div class="card">
      <h3 class="card-header">'|| dane.name || '</h3>
        <img class="card-img-top" src="' || dane.main_image || '">
        <div class="card-block">
            <p class="card-text">'|| dane.description || '</p>');
        IF dane.active > 0 THEN 
            htp.print('<a href="ADAM_ORDER.create_form?order_id='|| dane.id || '" class="btn btn-primary">Kup za '|| dane.base_price || ' / osoba</a>');
        END IF;
        htp.print('<a href="ADAM_ORDER.detail?id_v=' || dane.id || '" class="btn btn-secondary">Szczegóły</a>
        </div>
        <div class="card-footer text-muted">Wolne miejsca: ' || dane.free_space || ' • Zamówienia: '|| dane.guest_count || ' • Zarezerwowanych: '|| dane.guest_count || '</div>
    </div>');
    END LOOP;
    htp.print('</div>');
    ADAM_GUI.footer;
END list;

PROCEDURE search(keyword varchar2) IS BEGIN
    ADAM_GUI.header('ADAM_ORDER');
    htp.print('<div class="clearfix">');
    ADAM_ORDER.search_form(keyword);
    ADAM_GUI.button('ADAM_ORDER.create_form', 'Dodaj wycieczkę');
    htp.print('</div>');
    htp.print('<div class="card-columns">');
    FOR dane IN (SELECT order.main_image,order.active, order.name,order.base_price,order.description,order.id,COUNT(guest.id) AS guest_count, COUNT(guest.id) AS guest_count, (order.space - COUNT(guest.id)) AS free_space FROM order
        LEFT JOIN guest ON order.id = guest.order_id
        LEFT JOIN guest ON guest.guest_id = guest.id
        WHERE ( order.name LIKE '%' || keyword || '%' OR order.description LIKE '%' || keyword || '%' ) 
        GROUP BY order.id,order.name,order.main_image,order.base_price,order.description,order.space,order.active) LOOP
        htp.print('<div class="card">
      <h3 class="card-header">'|| dane.name || '</h3>
        <img class="card-img-top" src="' || dane.main_image || '">
        <div class="card-block">
            <p class="card-text">'|| dane.description || '</p>');
        IF dane.active > 0 THEN 
            htp.print('<a href="' || ADAM_GUI.url('ADAM_ORDER.create_form?order_id=' || dane.id) || '" class="btn btn-primary">Kup za '|| dane.base_price || ' / osoba</a>');
        END IF;
        htp.print('<a href="' || ADAM_GUI.url('ADAM_ORDER.detail?id_v=' || dane.id ) || '" class="btn btn-secondary">Szczegóły</a>
        </div>
        <div class="card-footer text-muted">Wolne miejsca: ' || dane.free_space || ' • Zamówienia: '|| dane.guest_count || ' • Zarezerwowanych: '|| dane.guest_count || '</div>
    </div>');
    END LOOP;
    htp.print('</div>');
    ADAM_GUI.footer;
END search;

PROCEDURE detail(id_v number) IS 
    order_v order%ROWTYPE;
    location_v location%ROWTYPE;
    country_v country%ROWTYPE;
    guest_count NUMBER;
    BEGIN 
    ADAM_GUI.header('ADAM_ORDER');
    BEGIN
    SELECT * INTO order_v FROM order WHERE id=id_v;
    SELECT * INTO location_v FROM location WHERE id=order_v.location_id;
    SELECT * INTO country_v FROM country WHERE id=location_v.country_id;
    SELECT COUNT(id) INTO guest_count FROM guest WHERE order_id=id_v;
    ADAM_GUI.button_group('ADAM_ORDER.update_form?id_v=' || id_v, 'Aktualizuj',
                          'ADAM_TRIp.delete_form?id_v=' || id_v, 'Usuń');
    htp.tableOpen('class="table"');
    ADAM_GUI.two_column('Nazwa', order_v.name);
    ADAM_GUI.two_column('Cena podstawowa', order_v.base_price);
    ADAM_GUI.two_column('Miejsca', order_v.space);
    ADAM_GUI.two_column('Opis', order_v.description);
    ADAM_GUI.two_column('Obraz', '<img src="' || order_v.main_image || '" height="100px"></img>');
    ADAM_GUI.two_column('Lokalizacja', location_v.name);
    ADAM_GUI.two_column('Kraj', country_v.name);
    ADAM_GUI.two_column('Liczba zamówień', guest_count);
    IF order_v.active > 0 THEN
        ADAM_GUI.two_column('Aktywne?', 'Aktywne', 'table-succes');
    ELSE
        ADAM_GUI.two_column('Aktywne?', 'Nieaktywne' ,'table-danger');
    END IF;
    htp.tableClose;
    END;
    ADAM_GUI.footer;
END detail; 

PROCEDURE create_form IS BEGIN 
    ADAM_GUI.header('ADAM_ORDER');
    htp.print('<form action="' || ADAM_GUI.url('ADAM_ORDER.create_sql') || '" method="GET">');
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
    ADAM_GUI.header('ADAM_ORDER');
    BEGIN
        INSERT INTO order VALUES (0, base_price_v, description_v, main_image_v, name_v, space_v, location_id_v, sysdate, sysdate, 1);
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
    order_v order%ROWTYPE;
    BEGIN 
    NULL;
    ADAM_GUI.header('ADAM_ORDER');
    BEGIN
    SELECT * INTO order_v FROM order WHERE id=id_v;
    htp.print('<form action="' || ADAM_GUI.url('ADAM_ORDER.update_sql') || '">');
    htp.formHidden('id_v', id_v, '');
    -- ADAM_GUI.form_input('name_v', 'text', 'Nazwa', 'name_v',order_v.name);
    -- ADAM_GUI.form_input('base_price_v', 'text', 'Cena podstawowa', 'base_price_v', order_v.base_price);
    -- ADAM_GUI.form_input('space_v','number', 'Liczba miejsc', 'space_v', order_v.space);
    -- ADAM_GUI.form_textarea('description', 'Opis', 'description_v', order_v.description);
    -- ADAM_GUI.form_input('main_image_v','url', 'Obraz (URL)', 'main_image_v', order_v.main_image);
    -- ADAM_LOCATION.form_select('location_id', 'Lokalizacja', 'location_id_v', order_v.location_id);
    -- ADAM_GUI.form_checkbox('active_v', 'Aktywne?', 'active_v', 1, order_v.active);
    -- ADAM_COUNTRY.form_select('country_id_v', 'Kraj', 'country_id_v', order_v.location_id);
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
    ADAM_GUI.header('ADAM_ORDER');
    BEGIN
        NULL;
        UPDATE order SET base_price=base_price_v,description=description_v,main_image=main_image_v,name=name_v,space=space_v, location_id=location_id_v, modified_on=sysdate, active=active_v WHERE id=id_v;
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
    ADAM_GUI.delete_form(id_v, 'ADAM_ORDER', 'name', 'order');
END delete_form;

PROCEDURE delete_sql(id_v number) IS 
    my_integration_error EXCEPTION;
    PRAGMA EXCEPTION_INIT (my_integration_error, -20101);
    count_guest number;
    label order.name%TYPE;
BEGIN
    ADAM_GUI.header('ADAM_ORDER');
    BEGIN
        SELECT COUNT(id) INTO count_guest FROM guest WHERE order_id = id_v;
        IF count_guest > 0 THEN
            raise_application_error(-20101, 'Naruszenie integralności');
        END IF;
        SELECT name INTO label FROM order WHERE id = id_v;
        DELETE FROM order WHERE id = id_v;
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


END ADAM_ORDER;
/

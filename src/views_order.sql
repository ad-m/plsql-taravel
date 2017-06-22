
SET SERVEROUTPUT ON;
SHOW ERRORS;


CREATE OR REPLACE PACKAGE ADAM_ORDER AS
PROCEDURE home;
PROCEDURE list(page number);
PROCEDURE detail(id_v number);
PROCEDURE create_form(trip_id_v integer);
PROCEDURE create_sql(note_v varchar2 default null,
                     trip_id_v integer,
                     address_id_v integer);
PROCEDURE update_form(id_v number);
PROCEDURE update_sql (id_v number,
                      note_v varchar2 default null,
                      unit_price_v integer default -1,
                      trip_id integer);
PROCEDURE delete_form (id_v number);
PROCEDURE delete_sql (id_v number);
PROCEDURE form_select(id varchar2, label varchar2, name varchar2, selected number default NULL);
END ADAM_ORDER;
/
SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY ADAM_ORDER AS
PROCEDURE home IS BEGIN ADAM_ORDER.list(0); END home;

PROCEDURE list(page number) IS BEGIN
    ADAM_GUI.header('ADAM_ORDER');
    htp.tableOpen('class="table stripped"');
    htp.print('<thead>');
        htp.tableHeader('Wycieczka');
        htp.tableHeader('Data utworzenia');
        htp.tableHeader('Notatka');
        htp.tableHeader('Cena sumaryczna / Liczba osób');
        htp.tableHeader('Cena jednostkowa');
        htp.tableHeader('Adres');
        htp.tableHeader(' ');
    htp.print('</thead>');
    FOR dane IN (SELECT "order".id, "order".created, "order".note, "order".unit_price, "order".trip_id, trip.name AS trip_name, trip.location_id, location.name AS location_name, 
COUNT(guest.id) AS guest_count, unit_price*COUNT(guest.id) AS total_price,
address.id AS address_id, address.name AS address_name
FROM "order"
LEFT JOIN guest ON guest.order_id = "order".id
INNER JOIN trip ON trip.id = "order".trip_id
INNER JOIN location ON location.id = trip.location_id
INNER JOIN address ON address.id = "order".address_id
GROUP BY 
"order".id, "order".created, "order".note, "order".unit_price, "order".trip_id, 
trip.name, trip.location_id, 
location.id, location.name,
address.id, address.name) LOOP
        htp.print('<tr>');
        htp.tableData('<a href="ADAM_TRIP.detail?id_v=' || dane.trip_id || '">' || dane.trip_name || '</a>');
        htp.tableData('<a href="ADAM_ORDER.detail?id_v=' || dane.id || '">' || dane.created || '</a>');
        htp.tableData(dane.note);
        htp.tableData(dane.total_price || '/' || dane.guest_count);
        htp.tableData(dane.unit_price);
        htp.tableData('<a href="ADAM_ADDRESS.detail?id_v=' || dane.address_id || '">' || dane.address_id || '# ' || dane.address_name || '</a>');
        htp.tableData();
        htp.print('</tr>');
    END LOOP;
    htp.print('</table>');
    ADAM_GUI.footer;
END list;

PROCEDURE detail(id_v number) IS 
    CURSOR dane_c IS (SELECT "order".id, "order".created, "order".note, "order".unit_price, "order".trip_id, trip.name AS trip_name, trip.location_id, location.name AS location_name, 
COUNT(guest.id) AS guest_count, unit_price*COUNT(guest.id) AS total_price,
address.id AS address_id, address.name AS address_name
FROM "order"
LEFT JOIN guest ON guest.order_id = "order".id
INNER JOIN trip ON trip.id = "order".trip_id
INNER JOIN location ON location.id = trip.location_id
INNER JOIN address ON address.id = "order".address_id
WHERE "order".id=id_v
GROUP BY 
"order".id, "order".created, "order".note, "order".unit_price, "order".trip_id, 
trip.name, trip.location_id, 
location.id, location.name,
address.id, address.name);
    my_found_error EXCEPTION;
    PRAGMA EXCEPTION_INIT (my_found_error, -20111);
    dane dane_c%ROWTYPE;
    BEGIN 
    ADAM_GUI.header('ADAM_ORDER');
    BEGIN
    OPEN dane_c;
    FETCH dane_c INTO dane;
    if dane_c%notfound then
        raise_application_error(-20111, 'Nie znaleziono danych');
    end if;
    CLOSE dane_c;
    ADAM_GUI.button_group('ADAM_ORDER.update_form?id_v=' || id_v, 'Aktualizuj',
                          'ADAM_ORDER.delete_form?id_v=' || id_v, 'Usuń');
        ADAM_GUI.button('ADAM_PAYMENT.create_form?order_id_v=' || id_v, 'Zarejestruj platnosc');
    htp.tableOpen('class="table"');
    ADAM_GUI.two_column('Wycieczka', '<a href="ADAM_TRIP.detail?id_v=' || dane.trip_id || '">' || dane.trip_name || '</a>');
    ADAM_GUI.two_column('Data utworzenia',dane.created);
    ADAM_GUI.two_column('Notatka', dane.note);
    ADAM_GUI.two_column('Cena', dane.total_price || '/' || dane.guest_count);
    ADAM_GUI.two_column('Cena jednostkowa', dane.unit_price);
    ADAM_GUI.two_column('Adres', '<a href="ADAM_ADDRESS.detail?id_v=' || dane.address_id || '">' || dane.address_id || '# ' || dane.address_name || '</a>');
    htp.tableClose;
    htp.print('<h2>Wykaz uczestników</h2>');
    htp.tableOpen('class="table table-stripepd"');
    htp.print('<tr>');
    htp.tableHeader('Imię i nazwisko');
    htp.tableHeader('Cena');
    htp.print('</tr>');
    FOR uczestnik IN (SELECT * FROM guest WHERE order_id=dane.id) LOOP
    ADAM_GUI.two_column(ADAM_GUI.url_link_t('ADAM_GUEST.detail?id_v=' || uczestnik.id, uczestnik.first_name || ' ' || uczestnik.second_name), dane.unit_price);
    END LOOP;
    htp.print('<tr>');
    htp.print('<td>'); ADAM_GUI.button('ADAM_GUEST.create_form?order_id_v=' || dane.id, 'Dodaj goscia'); htp.print('</td>');
    htp.print('<td>' || dane.total_price ||'</td>');
    htp.print('</tr>');
    htp.tableClose;
    htp.print('<h2>Wykaz płatności</h2>');
    htp.print('<ul  class="nav flex-column">');
    FOR dane IN (SELECT * FROM payment) LOOP
        htp.print('<li  class="nav-item"><a  class="nav-link" href="' || ADAM_GUI.url('ADAM_PAYMENT.detail?id_v=' || dane.id ) || '"> # ' || dane.order_id || '</a></li>');
    END LOOP;
    htp.print('</ul>');
    EXCEPTION when my_found_error then
        ADAM_GUI.danger(SQLCODE, 'Nie znaleziono!');
        when others then
        ADAM_GUI.danger(SQLCODE, sqlerrm);
    END;
    ADAM_GUI.footer;
END detail; 

PROCEDURE create_form (trip_id_v integer) IS 
    address_count integer;

    BEGIN 
    ADAM_GUI.header('ADAM_ORDER');
    SELECT COUNT(id) INTO address_count FROM address WHERE user_id = ADAM_USER.get_user_id();
    IF address_count = 0 THEN
        ADAM_GUI.warning('Jest problem!', ADAM_USER.get_user_name || ' nie masz dodanych adresów. Przejdź do <a href="' || ADAM_GUI.url('ADAM_ADDRESS.create_form') || '">formularza dodawania adresu</a>');
    END IF;
    htp.print('<form action="' || ADAM_GUI.url('ADAM_ORDER.create_sql') || '" method="GET">');
    ADAM_GUI.form_input_hidden('trip_id_v', trip_id_v);
    ADAM_GUI.form_textarea_clean('note_v', 'Notatka', 'note_v');
    ADAM_ADDRESS.form_select('address_id_v', 'Adres', 'address_id_v', NULL);
    ADAM_GUI.form_submit('Sporządź zamówienie');
    htp.print('</form>');
    ADAM_GUI.footer;
END create_form; 

PROCEDURE create_sql(note_v varchar2 default null,
                     trip_id_v integer,
                     address_id_v integer) IS
    trip_v trip%ROWTYPE;
    my_integration_error EXCEPTION;
    PRAGMA EXCEPTION_INIT (my_integration_error, -02291);

    BEGIN 
    ADAM_GUI.header('ADAM_ORDER');
    BEGIN
        SELECT * INTO trip_v FROM trip WHERE id=trip_id_v;
        INSERT INTO "order" VALUES (0, sysdate, note_v, trip_v.base_price, trip_id_v, address_id_v);
        ADAM_GUI.success('Well done!', 'Dane zostały pomyślnie zapisane!');
        EXCEPTION
            when my_integration_error then
                ADAM_GUI.danger('Oh no!', 'Naruszono integralnosc kluczy obcych');
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
                ADAM_GUI.danger('Oh no!', 'Wystapil blad' || sqlerrm);
    END;
    ADAM_GUI.footer;
END create_sql;

PROCEDURE update_form(id_v number) IS 
    order_v "order"%ROWTYPE;
    BEGIN 
    NULL;
    ADAM_GUI.header('ADAM_ORDER');
    BEGIN
    SELECT * INTO order_v FROM "order" WHERE id=id_v;
    htp.print('<form action="' || ADAM_GUI.url('ADAM_ORDER.update_sql') || '">');
    htp.formHidden('id_v', id_v, '');
    ADAM_ADDRESS.form_select('address_id_v', 'Adres', 'address_id_v', NULL);
    ADAM_GUI.form_textarea_clean('note_v', 'Notatka', 'note_v');
    ADAM_ADDRESS.form_select('address_id_v', 'Adres', 'address_id_v', NULL);
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
            when others then
                ADAM_GUI.danger('Oh no!', 'Wystapil blad');
    END;
    ADAM_GUI.footer;
END update_form; 

PROCEDURE update_sql (id_v number,
                      note_v varchar2 default null,
                      unit_price_v integer default -1,
                      trip_id integer) IS BEGIN
    NULL; 
    ADAM_GUI.header('ADAM_ORDER');
    BEGIN
        NULL;
        -- UPDATE "order" SET base_price=base_price_v,description=description_v,main_image=main_image_v,name=name_v,space=space_v, location_id=location_id_v, modified_on=sysdate, active=active_v WHERE id=id_v;
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
                ADAM_GUI.danger('Oh no!', 'Wystapil blad');
    END;
    ADAM_GUI.footer;
END update_sql;

PROCEDURE delete_form(id_v number) IS 
BEGIN 
    ADAM_GUI.delete_form(id_v, 'ADAM_ORDER', 'id', '"order"');
    EXCEPTION when others then
        ADAM_GUI.danger(SQLCODE, sqlerrm);

END delete_form;

PROCEDURE delete_sql(id_v number) IS 
    my_integration_error EXCEPTION;
    PRAGMA EXCEPTION_INIT (my_integration_error, -20101);
    count_guest number;
    label "order".id%TYPE;
BEGIN
    ADAM_GUI.header('ADAM_ORDER');
    BEGIN
        NULL;
        SELECT COUNT(id) INTO count_guest FROM guest WHERE order_id = id_v;
        IF count_guest > 0 THEN
            raise_application_error(-20101, 'Naruszenie integralności');
        END IF;
        SELECT id INTO label FROM "order" WHERE id = id_v;
        DELETE FROM "order" WHERE id = id_v;
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

PROCEDURE form_select(id varchar2, label varchar2, name varchar2, selected number default NULL) IS
  BEGIN
  htp.print('<div class="form-group">
    <label for="' || id || '">' || label || '</label>
    <select name="' || name || '" class="form-control" id="' || id || '">');
  FOR dane IN (SELECT "order".id, trip.name FROM "order" INNER JOIN trip ON trip.id = "order".trip_id) LOOP
      ADAM_GUI.form_option(dane.id, '#' || dane.id ||' (' || dane.name || ')',  selected);
  END LOOP;
  htp.print('</select>
  </div>');
  NULL;
END form_select;


END ADAM_ORDER;
/

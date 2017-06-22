SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE ADAM_ADDRESS AS
PROCEDURE home;
PROCEDURE list(page number);
PROCEDURE detail(id_v varchar2);
PROCEDURE create_form;
PROCEDURE create_sql (city_v varchar2,
                      name_v varchar2,
                      postcode_v varchar2,
                      street_v varchar2,
                      street_number_v varchar2,
                      taxpayer_id_v varchar2,
                      user_id_v integer default -1);
PROCEDURE update_form (id_v varchar2);
PROCEDURE update_sql (id_v varchar2, 
                      city_v varchar2,
                      name_v varchar2,
                      postcode_v varchar2,
                      street_v varchar2,
                      street_number_v varchar2,
                      taxpayer_id_v varchar2,
                      user_id_v integer default -1);
PROCEDURE delete_form(id_v number);
PROCEDURE delete_sql(id_v number);
PROCEDURE form_select(id varchar2, label varchar2, name varchar2, selected number);

END ADAM_ADDRESS;
/
SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY ADAM_ADDRESS AS
PROCEDURE home IS BEGIN ADAM_ADDRESS.list(0); END home; 
PROCEDURE list(page number) IS BEGIN
    ADAM_GUI.header('ADAM_ADDRESS');
    BEGIN
        ADAM_GUI.button('ADAM_ADDRESS.create_form', 'Dodaj adres');
        htp.tableOpen('class="table"');
            htp.tableHeader('Miejscowosc');
            htp.tableHeader('Nazwa');
            htp.tableHeader('Kod pocztowy');
            htp.tableHeader('Ulica');
            htp.tableHeader('Numer mieszkania');
            htp.tableHeader('Identyfikator podatkowy');
            htp.tableHeader('Nazwa użytkownika');
        FOR dane IN (SELECT address.*, "user".username FROM address INNER JOIN "user" ON address.user_id = "user".id) LOOP
            htp.print('<tr>');
            htp.tableData(dane.city);
            htp.tableData(dane.name);
            htp.tableData(dane.postcode);
            htp.tableData(dane.street);
            htp.tableData(dane.street_number);
            htp.tableData(dane.taxpayer_id);
            htp.tableData(dane.username);
            htp.tableData('<a  class="nav-link" href="' || ADAM_GUI.url('ADAM_ADDRESS.detail?id_v=' || dane.id ) || '">Szczegóły</a>');
            htp.print('</tr>');
        END LOOP;
        htp.print('</table>');
        exception when others then
            ADAM_GUI.danger(SQLCODE, sqlerrm);
    END;
    ADAM_GUI.footer;
END list; 
PROCEDURE detail(id_v varchar2) IS 
    address_v address%ROWTYPE;
    user_v "user"%ROWTYPE;
    order_count NUMBER;
    BEGIN 
    ADAM_GUI.header('ADAM_ADDRESS');
    BEGIN
        SELECT * INTO address_v FROM address WHERE id=id_v;
        SELECT * INTO user_v FROM "user" WHERE id=address_v.user_id;
        SELECT COUNT(id) INTO order_count FROM "order" WHERE address_id=id_v;
        ADAM_GUI.button_group('ADAM_ADDRESS.update_form?id_v=' || id_v, 'Aktualizuj',
                              'ADAM_ADDRESS.delete_form?id_v=' || id_v, 'Usuń');
        htp.print('<h1>Adres dla ' || user_v.username || '</h2>');
        htp.tableOpen('class="table"');
        ADAM_GUI.two_column('Miasto', address_v.city);
        ADAM_GUI.two_column('Nazwa', address_v.name);
        ADAM_GUI.two_column('Kod pocztowy', address_v.postcode);
        ADAM_GUI.two_column('Ulica', address_v.street);
        ADAM_GUI.two_column('Numer mieszkania', address_v.street_number);
        ADAM_GUI.two_column('Numer podatkowy', address_v.taxpayer_id);
        ADAM_GUI.two_column('Liczba użyć w zamówieniach', order_count);
        ADAM_GUI.two_column('Użytkownik', user_v.username);
        htp.tableClose;
        IF order_count > 0 THEN
            htp.print('<h2>Adres wykorzystany w następujących zamówieniach</h2>');
            htp.print('<ul  class="nav flex-column">');
            FOR dane IN (SELECT * FROM "order" WHERE address_id = id_v) LOOP
                htp.print('<li  class="nav-item"><a  class="nav-link" href="' || ADAM_GUI.url('ADAM_ORDER.detail?id_v=' || dane.id ) || '">' || dane.created || '</a></li>');
            END LOOP;
            htp.print('</ul>');
        END IF;
        EXCEPTION
            when NO_DATA_FOUND then
                ADAM_GUI.danger('Oh no!', 'Nie znaleziono danych');
            when INVALID_NUMBER then
                ADAM_GUI.danger('Oh no!', 'Wprowadzono niepoprawna wartosc'); 
            when VALUE_ERROR then
                ADAM_GUI.danger('Oh no!', 'Blad konwersji typów danych'); 
            when others then
                ADAM_GUI.danger(SQLCODE, sqlerrm);
    END;
    ADAM_GUI.footer;
END detail; 
PROCEDURE create_form IS BEGIN 
    ADAM_GUI.header('ADAM_ADDRESS');
    htp.print('<form action="' || ADAM_GUI.url('ADAM_ADDRESS.create_sql') || '">');
    ADAM_GUI.form_input('city_v', 'text', 'Miasto', 'city_v', '');
    ADAM_GUI.form_input('name_v', 'text', 'Nazwa', 'name_v', '');
    ADAM_GUI.form_input('postcode', 'text', 'Kod pocztowy', 'postcode_v', '');
    ADAM_GUI.form_input('street_v', 'text', 'Ulica', 'street_v', '');
    ADAM_GUI.form_input('street_number_v', 'text', 'Numer mieszkania', 'street_number_v','');
    ADAM_GUI.form_input('taxpayer_id_v', 'text', 'Numer podatkowy', 'taxpayer_id_v','');
    ADAM_USER.form_select('user_id_v', 'Użytkownik', 'user_id_v', ADAM_USER.get_user_id());
    ADAM_GUI.form_submit('Dodaj adres');
    htp.print('</form>');
    ADAM_GUI.footer;
END create_form; 

PROCEDURE create_sql (city_v varchar2,
                      name_v varchar2,
                      postcode_v varchar2,
                      street_v varchar2,
                      street_number_v varchar2,
                      taxpayer_id_v varchar2,
                      user_id_v integer default -1) IS
    my_null_error EXCEPTION;
    PRAGMA EXCEPTION_INIT (my_null_error, -1400);
    my_integration_error EXCEPTION;
    PRAGMA EXCEPTION_INIT (my_integration_error, -02291);
    BEGIN 
    ADAM_GUI.header('ADAM_ADDRESS');
    BEGIN
        INSERT INTO address VALUES (0, city_v, name_v, postcode_v, street_v, street_number_v, taxpayer_id_v, user_id_v);
        ADAM_GUI.success('Well done!', 'Dane zostały pomyślnie zapisane!');
        EXCEPTION
            when my_integration_error then
                ADAM_GUI.danger('Oh no!', 'Naruszono integralnosc kluczy obcych');
            when my_null_error then
                ADAM_GUI.danger('Oh no!', 'Wypelnij wszystkie niezbedne pola');
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
END create_sql;

PROCEDURE update_form(id_v varchar2) IS 
    address_v address%ROWTYPE;
    BEGIN
    NULL;
    ADAM_GUI.header('ADAM_ADDRESS');
    BEGIN
    SELECT * INTO address_v FROM address WHERE id=id_v;
    htp.print('<form action="' || ADAM_GUI.url('ADAM_ADDRESS.update_sql') || '">');
    htp.formHidden('id_v', id_v, '');
    ADAM_GUI.form_input('city_v', 'text', 'Miasto', 'city_v', address_v.city);
    ADAM_GUI.form_input('name_v', 'text', 'Nazwa', 'name_v', address_v.name);
    ADAM_GUI.form_input('postcode', 'text', 'Kod pocztowy', 'postcode_v', address_v.postcode);
    ADAM_GUI.form_input('street_v', 'text', 'Ulica', 'street_v', address_v.street);
    ADAM_GUI.form_input('street_number_v', 'text', 'Numer mieszkania', 'street_number_v',address_v.street_number);
    ADAM_GUI.form_input('taxpayer_id_v', 'text', 'Numer podatkowy', 'taxpayer_id_v',address_v.taxpayer_id);
    IF ADAM_USER.is_admin() = TRUE THEN
        ADAM_USER.form_select('user_id_v', 'Użytkownik', 'user_id_v', address_v.user_id);
    END IF;
    ADAM_GUI.form_submit('Zaktualizuj adres');
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

PROCEDURE  update_sql (id_v varchar2, 
                      city_v varchar2,
                      name_v varchar2,
                      postcode_v varchar2,
                      street_v varchar2,
                      street_number_v varchar2,
                      taxpayer_id_v varchar2,
                      user_id_v integer default -1) IS
    user_id_v_v integer;
    my_null_error EXCEPTION;
    PRAGMA EXCEPTION_INIT (my_null_error, -1400);
    my_integration_error EXCEPTION;
    PRAGMA EXCEPTION_INIT (my_integration_error, -02291);
    BEGIN 
    NULL;
    ADAM_GUI.header('ADAM_ADDRESS');
    BEGIN
        IF ADAM_USER.is_admin() = FALSE THEN
            user_id_v_v := ADAM_USER.get_user_id();
            htp.print('x' || user_id_v_v);
            UPDATE address SET city=city_v, name=name_v, postcode=postcode_v, street=street_v, street_number=street_number_v, taxpayer_id=taxpayer_id_v, user_id=user_id_v_v WHERE id=id_v;
            ADAM_GUI.success('Well done!', 'Twoje dane zostały pomyślnie zaktualizowane!');
        ELSE
            UPDATE address SET city=city_v, name=name_v, postcode=postcode_v, street=street_v, street_number=street_number_v, taxpayer_id=taxpayer_id_v, user_id=user_id_v WHERE id=id_v;
            ADAM_GUI.success('Well done!', 'Dane zostały pomyślnie zaktualizowane!');
            
        END IF;
        EXCEPTION
            when my_integration_error then
                ADAM_GUI.danger('Oh no!', 'Naruszono integralnosc kluczy obcych');
            when my_null_error then
                ADAM_GUI.danger('Oh no!', 'Wypelnij wszystkie niezbedne pola');
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

PROCEDURE form_select(id varchar2, label varchar2, name varchar2, selected number) IS
  BEGIN
    NULL;
  htp.print('<div class="form-group">
    <label for="' || id || '">' || label || '</label>
    <select name="' || name || '" class="form-control" id="' || id || '">');
  FOR dane IN (SELECT address.* FROM address) LOOP
      ADAM_GUI.form_option(dane.id, dane.name ||' (' || dane.city || ')',  selected);
  END LOOP;
  htp.print('</select>
  </div>');
  NULL;
END form_select;

PROCEDURE delete_form(id_v number) IS 
BEGIN 
    ADAM_GUI.delete_form(id_v, 'ADAM_ADDRESS', 'name', 'address');
END delete_form;

PROCEDURE delete_sql(id_v number) IS 
    my_integration_error EXCEPTION;
    PRAGMA EXCEPTION_INIT (my_integration_error, -20101);
    count_order number;
    address_name address.name%TYPE;
BEGIN
    NULL;
    ADAM_GUI.header('ADAM_ADDRESS');
    BEGIN
        SELECT COUNT(id) INTO count_order FROM "order" WHERE address_id = id_v;
        IF count_order > 0 THEN
            raise_application_error(-20101, 'Naruszenie integralności');
        END IF;
        SELECT name INTO address_name FROM address WHERE id = id_v;
        DELETE FROM address WHERE id = id_v;
        ADAM_GUI.success('Well done!', 'Pomyslnie usunieto "' || address_name || '".');
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

END ADAM_ADDRESS;
/

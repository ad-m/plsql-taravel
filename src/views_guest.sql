
SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE ADAM_GUEST AS
PROCEDURE home;
PROCEDURE list(page number);
PROCEDURE detail(id_v number);
PROCEDURE create_form(order_id_v number default -1);
PROCEDURE create_sql(first_name_v varchar2, second_name_v varchar2, order_id_v number);
PROCEDURE update_form(id_v number);
PROCEDURE update_sql (id_v number, first_name_v varchar2, second_name_v varchar2, order_id_v number);
PROCEDURE delete_form(id_v number);
PROCEDURE delete_sql(id_v number);
PROCEDURE form_select(id varchar2, label varchar2, name varchar2, selected varchar2 default -1);
END ADAM_GUEST;
/
SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY ADAM_GUEST AS
PROCEDURE home IS BEGIN ADAM_GUEST.list(0); END home; 
PROCEDURE list(page number) IS BEGIN
    ADAM_GUI.header('ADAM_GUEST');
    IF ADAM_USER.is_admin = TRUE THEN
        ADAM_GUI.button('ADAM_GUEST.create_form', 'Dodaj gościa');
    END IF;
    htp.print('<ul  class="nav flex-column">');
    FOR dane IN (SELECT * FROM guest) LOOP
        htp.print('<li  class="nav-item"><a  class="nav-link" href="' || ADAM_GUI.url('ADAM_GUEST.detail?id_v=' || dane.id ) || '">' || dane.first_name || ' ' || dane.second_name || '</a></li>');
    END LOOP;
    htp.print('</ul>');
    ADAM_GUI.footer;
END list; 
PROCEDURE detail(id_v number) IS 
    guest_v guest%ROWTYPE;
    BEGIN 
    ADAM_GUI.header('ADAM_GUEST');
    BEGIN
        SELECT * INTO guest_v FROM guest WHERE id=id_v;
        ADAM_GUI.button_group('ADAM_GUEST.update_form?id_v=' || id_v, 'Aktualizuj',
                              'ADAM_GUEST.delete_form?id_v=' || id_v, 'Usuń');
        htp.print('<h1>' || guest_v.first_name || ' ' || guest_v.second_name || '</h1>');
        htp.tableOpen('class="table"');
        ADAM_GUI.two_column('Imię', guest_v.first_name);
        ADAM_GUI.two_column('Nazwisko', guest_v.second_name);
        ADAM_GUI.two_column('Wycieczka', ADAM_GUI.url_link_t('ADAM_ORDER.detail?id_v=' || guest_v.order_id, '#' || guest_v.order_id));
        htp.tableClose;
    END;
    ADAM_GUI.footer;
END detail; 
PROCEDURE create_form(order_id_v number default -1) IS BEGIN 
    ADAM_GUI.header('ADAM_GUEST');
    htp.print('<form action="' || ADAM_GUI.url('ADAM_GUEST.create_sql') || '">');
    ADAM_GUI.form_input('first_name', 'text', 'Imię', 'first_name_v');
    ADAM_GUI.form_input('second_name', 'text', 'Nazwisko', 'second_name_v');
    IF order_id_v = -1 THEN
        ADAM_ORDER.form_select('order_id_v', 'Zamówienie', 'order_id_v', NULL);
    ELSE
        ADAM_GUI.form_input_hidden('order_id_v', order_id_v);
    END IF;
    ADAM_GUI.form_submit('Dodaj gościa');
    htp.print('</form>');
    ADAM_GUI.footer;
END create_form; 

PROCEDURE create_sql(first_name_v varchar2, second_name_v varchar2, order_id_v number) IS BEGIN 
    ADAM_GUI.header('ADAM_GUEST');
    BEGIN
        INSERT INTO guest VALUES (0, first_name_v, second_name_v, order_id_v);
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

PROCEDURE form_select(id varchar2, label varchar2, name varchar2, selected varchar2 default -1) IS
  BEGIN
  htp.print('<div class="form-group">
    <label for="' || id || '">' || label || '</label>
    <select name="' || name || '" class="form-control" id="' || id || '">');
  FOR dane IN (SELECT * FROM guest) LOOP
    ADAM_GUI.form_option(dane.id, dane.first_name || ' ' || dane.second_name, selected);
  END LOOP;
  htp.print('</select>
  </div>');
  NULL;
END form_select;

PROCEDURE update_form(id_v number) IS 
    guest_v guest%ROWTYPE;
    BEGIN 
    ADAM_GUI.header('ADAM_GUEST');
    BEGIN
    NULL;
    SELECT * INTO guest_v FROM guest WHERE id=id_v;
    htp.print('<form action="' || ADAM_GUI.url('ADAM_GUEST.update_sql') || '">');
    htp.formHidden('id_v', id_v, '');
    ADAM_GUI.form_input('first_name', 'text', 'Imię', 'first_name_v', guest_v.first_name);
    ADAM_GUI.form_input('second_name', 'text', 'Nazwisko', 'second_name_v', guest_v.second_name);
    ADAM_ORDER.form_select('order_id_v', 'Zamówienie', 'order_id_v', guest_v.order_id);
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
                ADAM_GUI.danger(SQLCODE, sqlerrm);
    END;
    ADAM_GUI.footer;
END update_form; 

PROCEDURE update_sql (id_v number, first_name_v varchar2, second_name_v varchar2, order_id_v number) IS BEGIN 
    ADAM_GUI.header('ADAM_GUEST');
    BEGIN
        UPDATE guest SET first_name=first_name_v, second_name=second_name_v, order_id=order_id_v WHERE id=id_v;
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
                ADAM_GUI.danger(SQLCODE, sqlerrm);
    END;
    ADAM_GUI.footer;
END update_sql;

PROCEDURE delete_form(id_v number) IS 
BEGIN 
    ADAM_GUI.delete_form(id_v, 'ADAM_GUEST', 'name', 'guest');
END delete_form;

PROCEDURE delete_sql(id_v number) IS 
    -- my_integration_error EXCEPTION;
    -- PRAGMA EXCEPTION_INIT (my_integration_error, -20101);
    guest_v guest%ROWTYPE;

BEGIN
    ADAM_GUI.header('ADAM_GUEST');
    BEGIN
        -- SELECT COUNT(id) INTO count_location FROM location WHERE guest_id = id_v;
        -- IF count_location > 0 THEN
            -- raise_application_error(-20101, 'Naruszenie integralności');
        -- END IF;
        SELECT * INTO guest_v FROM guest WHERE id = id_v;
        DELETE FROM guest WHERE id = id_v;
        ADAM_GUI.success('Well done!', 'Pomyslnie usunieto "' || guest_v.first_name || ' ' || guest_v.second_name || '".');
        EXCEPTION
            -- when my_integration_error then
                -- ADAM_GUI.danger('Oh no!', 'Naruszenie integralności');
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

END ADAM_GUEST;
/

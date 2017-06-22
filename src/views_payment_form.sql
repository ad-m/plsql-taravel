SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE ADAM_PAYMENT_FORM AS
PROCEDURE home;
PROCEDURE list(page number);
PROCEDURE detail(id_v number);
PROCEDURE create_form;
PROCEDURE create_sql (name_v varchar2);
PROCEDURE update_form (id_v number);
PROCEDURE update_sql (id_v number, name_v varchar2, active number default 0);
PROCEDURE delete_form (id_v number);
PROCEDURE delete_sql (id_v number);
PROCEDURE form_select (id varchar2, label varchar2, name varchar2, selected varchar2 default -1);
END ADAM_PAYMENT_FORM;
/
SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY ADAM_PAYMENT_FORM AS
PROCEDURE home IS BEGIN ADAM_PAYMENT_FORM.list(0); END home; 
PROCEDURE list(page number) IS BEGIN
    ADAM_GUI.header('ADAM_PAYMENT_FORM');
    BEGIN
        IF ADAM_USER.is_admin = TRUE THEN
            ADAM_GUI.button('ADAM_PAYMENT_FORM.create_form', 'Dodaj formę płatności');
        END IF;
        htp.print('<ul  class="nav flex-column">');
        FOR dane IN (SELECT payment_form.id, payment_form.name, SUM(order_stat.total_price) AS value FROM payment_form LEFT JOIN payment ON payment_form.id = payment.payment_form_id LEFT JOIN order_stat ON order_stat.id = payment.order_id GROUP BY payment_form.id, payment_form.name) LOOP
            htp.print('<li  class="nav-item"><a  class="nav-link" href="' || ADAM_GUI.url('ADAM_PAYMENT_FORM.detail?id_v=' || dane.id ) || '">' || dane.name || ' (' || NVL(dane.value,0) || ' zarobiono)</a></li>');
        END LOOP;
        htp.print('</ul>');
        exception when others then
                    ADAM_GUI.danger(SQLCODE, sqlerrm);
    END;
    ADAM_GUI.footer;
END list; 
PROCEDURE detail(id_v number) IS 
    payment_form_v payment_form%ROWTYPE;
    payment_count NUMBER;
    BEGIN 
    ADAM_GUI.header('ADAM_PAYMENT_FORM');
    BEGIN
        SELECT * INTO payment_form_v FROM payment_form WHERE id=id_v;
        SELECT COUNT(id) INTO payment_count FROM payment WHERE payment_form_id=id_v;
        IF ADAM_USER.is_admin = TRUE THEN
            ADAM_GUI.button_group('ADAM_PAYMENT_FORM.update_form?id_v=' || id_v, 'Aktualizuj',
                                  'ADAM_PAYMENT_FORM.delete_form?id_v=' || id_v, 'Usuń');
        END IF;
        htp.print('<h1>' || payment_form_v.name || '</h1>');
        htp.tableOpen('class="table"');
        ADAM_GUI.two_column('Liczba platnosc', payment_count);
        IF payment_form_v.active > 0 THEN
            ADAM_GUI.two_column('Aktywne?', 'Aktywne', 'table-succes');
        ELSE
            ADAM_GUI.two_column('Aktywne?', 'Nieaktywne' ,'table-danger');
        END IF;
        htp.tableClose;
        IF payment_count > 0 THEN
            htp.print('<h2>Platnosci dla danej formy platnosci</h2>');
            htp.print('<ul class="nav flex-column">');
            FOR dane IN (SELECT * FROM payment WHERE payment_form_id = id_v) LOOP
                htp.print('<li  class="nav-item"><a  class="nav-link" href="' || ADAM_GUI.url('ADAM_payment.detail?id_v=' || dane.id ) || '">#' || dane.id || '</a></li>');
            END LOOP;
            htp.print('</ul>');
        END IF; 
    END;
    ADAM_GUI.footer;
END detail; 
PROCEDURE create_form IS BEGIN 
    ADAM_GUI.header('ADAM_PAYMENT_FORM');
    htp.print('<form action="' || ADAM_GUI.url('ADAM_PAYMENT_FORM.create_sql') || '">');
    ADAM_GUI.form_input('name_v', 'text', 'Nazwa', 'name_v');
    ADAM_GUI.form_submit('Dodaj formę płatności');
    htp.print('</form>');
    ADAM_GUI.footer;
END create_form; 

PROCEDURE create_sql (name_v varchar2) IS BEGIN 
    ADAM_GUI.header('ADAM_PAYMENT_FORM');
    BEGIN
        INSERT INTO payment_form VALUES (0, name_v, 1);
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

PROCEDURE form_select(id varchar2, label varchar2, name varchar2, selected varchar2 default -1) IS
  BEGIN
  htp.print('<div class="form-group">
    <label for="' || id || '">' || label || '</label>
    <select name="' || name || '" class="form-control" id="' || id || '">');
  FOR dane IN (SELECT * FROM payment_form WHERE active = 1) LOOP
    ADAM_GUI.form_option(dane.id, dane.name, selected);
  END LOOP;
  htp.print('</select>
  </div>');
  NULL;
END form_select;

PROCEDURE update_form(id_v number) IS 
    payment_form_v payment_form%ROWTYPE;
    BEGIN 
    ADAM_GUI.header('ADAM_PAYMENT_FORM');
    BEGIN
    NULL;
    SELECT * INTO payment_form_v FROM payment_form WHERE id=id_v;
    htp.print('<form action="' || ADAM_GUI.url('ADAM_PAYMENT_FORM.update_sql') || '">');
    htp.formHidden('id_v', id_v, '');
    ADAM_GUI.form_input('name_v', 'text', 'Nazwa', 'name_v', payment_form_v.name);
    ADAM_GUI.form_checkbox('active_v', 'Aktywne?', 'active_v', 1, payment_form_v.active);
    ADAM_GUI.form_submit('Zaktualizuj formę płatności');
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

PROCEDURE update_sql (id_v number, name_v varchar2, active number default 0) IS BEGIN 
    ADAM_GUI.header('ADAM_PAYMENT_FORM');
    BEGIN
        UPDATE payment_form SET name=name_v, active=active WHERE id=id_v;
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
    ADAM_GUI.delete_form(id_v, 'ADAM_PAYMENT_FORM', 'name', 'payment_form');
END delete_form;

PROCEDURE delete_sql(id_v number) IS 
    my_integration_error EXCEPTION;
    PRAGMA EXCEPTION_INIT (my_integration_error, -20101);
    count_payment number;
    payment_form_name payment_form.name%TYPE;
BEGIN
    ADAM_GUI.header('ADAM_PAYMENT_FORM');
    BEGIN
        SELECT COUNT(id) INTO count_payment FROM payment WHERE payment_form_id = id_v;
        IF count_payment > 0 THEN
            raise_application_error(-20101, 'Naruszenie integralności');
        END IF;
        SELECT name INTO payment_form_name FROM payment_form WHERE id = id_v;
        DELETE FROM payment_form WHERE id = id_v;
        ADAM_GUI.success('Well done!', 'Pomyslnie usunieto "' || payment_form_name || '".');
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

END ADAM_PAYMENT_FORM;
/

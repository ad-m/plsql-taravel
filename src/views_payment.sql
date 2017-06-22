SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE ADAM_PAYMENT AS
PROCEDURE home;
PROCEDURE list(page number);
PROCEDURE detail(id_v number);
PROCEDURE create_form(order_id_v number);
PROCEDURE create_sql (order_id_v varchar2, payment_form_id_v number);
PROCEDURE update_form(id_v number);
PROCEDURE update_sql (id_v number, order_id_v varchar2, payment_form_id_v number);
PROCEDURE delete_form(id_v number);
PROCEDURE delete_sql(id_v number);
PROCEDURE form_select(id varchar2, label varchar2, name varchar2, selected varchar2 default -1);
END ADAM_PAYMENT;
/
SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY ADAM_PAYMENT AS
PROCEDURE home IS BEGIN ADAM_PAYMENT.list(0); END home; 
PROCEDURE list(page number) IS BEGIN
    ADAM_GUI.header('ADAM_PAYMENT');
    ADAM_GUI.button('ADAM_PAYMENT_FORM.home', 'Pokaż formy płatności');
    htp.print('<ul  class="nav flex-column">');
    FOR dane IN (SELECT * FROM payment) LOOP
        htp.print('<li  class="nav-item"><a  class="nav-link" href="' || ADAM_GUI.url('ADAM_PAYMENT.detail?id_v=' || dane.id ) || '"> # ' || dane.order_id || '</a></li>');
    END LOOP;
    htp.print('</ul>');
    ADAM_GUI.footer;
END list; 
PROCEDURE detail(id_v number) IS 
    payment_v payment%ROWTYPE;
    order_v "order"%ROWTYPE;
    trip_v trip%ROWTYPE;
    payment_form_id_v payment_form%ROWTYPE;

    BEGIN 
    ADAM_GUI.header('ADAM_PAYMENT');
    BEGIN
        SELECT * INTO payment_v FROM payment WHERE id=id_v;
        SELECT * INTO order_v FROM "order" WHERE id=payment_v.order_id;
        SELECT * INTO trip_v FROM trip WHERE id=order_v.trip_id;
        SELECT * INTO payment_form_id_v FROM payment_form WHERE id=payment_v.payment_form_id;
        IF ADAM_USER.is_admin = TRUE THEN
            ADAM_GUI.button_group('ADAM_PAYMENT.update_form?id_v=' || id_v, 'Aktualizuj',
                                  'ADAM_PAYMENT.delete_form?id_v=' || id_v, 'Usuń');
        END IF;
        htp.print('<h1>#' || payment_v.order_id || '</h1>');
        htp.tableOpen('class="table"');
        ADAM_GUI.two_column('Zamówienie', ADAM_GUI.url_link_t('ADAM_ORDER.detail?id_v=' || order_v.id, '#' || order_v.id));
        ADAM_GUI.two_column('Wycieczka', ADAM_GUI.url_link_t('ADAM_TRIP.detail?id_v=' || trip_v.id, trip_v.name));
        ADAM_GUI.two_column('Forma płatności', ADAM_GUI.url_link_t('ADAM_PAYMENT_FORM.detail?id_v=' || payment_form_id_v.id, payment_form_id_v.name));
        htp.tableClose;
        exception when others then
                    ADAM_GUI.danger(SQLCODE, sqlerrm);

    END;
    ADAM_GUI.footer;
END detail; 
PROCEDURE create_form(order_id_v number) IS BEGIN 
    ADAM_GUI.header('ADAM_PAYMENT');
    htp.print('<form action="' || ADAM_GUI.url('ADAM_PAYMENT.create_sql') || '">');
    ADAM_GUI.form_input_hidden('order_id_v', order_id_v);
    ADAM_PAYMENT_FORM.form_select('payment_form_id_v', 'Forma płatności', 'payment_form_id_v');
    ADAM_GUI.form_submit('Zarejestruj płatność');
    htp.print('</form>');
            exception when others then
                    ADAM_GUI.danger(SQLCODE, sqlerrm);

    ADAM_GUI.footer;
END create_form; 

PROCEDURE create_sql (order_id_v varchar2, payment_form_id_v number) IS BEGIN 
    ADAM_GUI.header('ADAM_PAYMENT');
    BEGIN
        INSERT INTO payment VALUES (0, payment_form_id_v, order_id_v);
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
  FOR dane IN (SELECT * FROM payment) LOOP
    ADAM_GUI.form_option(dane.id, 'Platnosc dla zamowienia' || dane.order_id, selected);
  END LOOP;
  htp.print('</select>
  </div>');
  NULL;
END form_select;

PROCEDURE update_form(id_v number) IS 
    payment_v payment%ROWTYPE;
    BEGIN 
    ADAM_GUI.header('ADAM_PAYMENT');
    BEGIN
    NULL;
    SELECT * INTO payment_v FROM payment WHERE id=id_v;
    htp.print('<form action="' || ADAM_GUI.url('ADAM_PAYMENT.update_sql') || '">');
    htp.formHidden('id_v', id_v, '');
    ADAM_PAYMENT_FORM.form_select('payment_form_id_v', 'Platnosc', 'payment_form_id_v', payment_v.payment_form_id);
    ADAM_ORDER.form_select('order_id_v', 'Zamowienie', 'order_id_v', payment_v.order_id);
    ADAM_GUI.form_submit('Zaktualizuj platnosc');
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

PROCEDURE update_sql (id_v number, order_id_v varchar2, payment_form_id_v number) IS BEGIN 
    ADAM_GUI.header('ADAM_PAYMENT');
    BEGIN
        UPDATE payment SET order_id=order_id_v, payment_form_id=payment_form_id_v WHERE id=id_v;
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
    ADAM_GUI.delete_form(id_v, 'ADAM_PAYMENT', 'id', 'payment');
END delete_form;

PROCEDURE delete_sql(id_v number) IS 
    payment_v payment%ROWTYPE;
BEGIN
    ADAM_GUI.header('ADAM_PAYMENT');
    -- BEGIN
    --     SELECT * INTO payment_v FROM payment WHERE id = id_v;
    --     DELETE FROM payment WHERE id = id_v;
    --     ADAM_GUI.success('Well done!', 'Pomyslnie usunieto "' || payment_v.id || '".');
    --     EXCEPTION
    --         when NO_DATA_FOUND then
    --             ADAM_GUI.danger('Oh no!', 'Nie znaleziono danych');
    --         WHEN STORAGE_ERROR THEN
    --             ADAM_GUI.danger('Oh no!', 'Blad pamieci');
    --         when INVALID_NUMBER then
    --             ADAM_GUI.danger('Oh no!', 'Wprowadzono niepoprawna wartosc'); 
    --         when VALUE_ERROR then
    --             ADAM_GUI.danger('Oh no!', 'Blad konwersji typów danych');
    --         when others then
    --             ADAM_GUI.danger(SQLCODE, sqlerrm);
    -- END;
    ADAM_GUI.footer;
END delete_sql;

END ADAM_PAYMENT;
/

SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE ADAM_USER AS
FUNCTION get_user_name RETURN varchar2;
FUNCTION get_user_id RETURN number;
PROCEDURE login_form;
PROCEDURE login_sql(username_v varchar2, password_v varchar2);
PROCEDURE logout;
PROCEDURE register_form;
PROCEDURE register_sql(username_v varchar2, password_v varchar2);
FUNCTION random_str(v_length number) return varchar2;
END ADAM_USER;
/
SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY ADAM_USER AS

    FUNCTION get_user_name RETURN varchar2 IS
        user_name_v varchar(100);
        user_id_v number;
    BEGIN
        user_id_v:=ADAM_USER.get_user_id();
        IF user_id_v < 1 THEN
            RETURN '';
        END IF;
        SELECT "user".username INTO user_name_v FROM "user" WHERE "user".id = user_id_v;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN '';
    END;

    FUNCTION get_user_id RETURN number IS 
            SESSION_IDS OWA_COOKIE.COOKIE;
            SESSION_ID VARCHAR2(100);
            user_id_v number;
    BEGIN 
        SESSION_IDS := OWA_COOKIE.GET('SESSION_ID');

        IF SESSION_IDS.num_vals <> 0 then
            SESSION_ID := SESSION_IDS.VALS(1);
            BEGIN
                htp.print(SESSION_ID);
                SELECT "user".id INTO user_id_v FROM "user" INNER JOIN sessions ON sessions.user_id = "user".id WHERE key = SESSION_ID;
                RETURN user_id_v;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                    RETURN -2;
            END;
        ELSE
            RETURN -1;
        END IF;
        RETURN -1;
    END;

    function random_str(v_length number) return varchar2 is
        my_str varchar2(4000);
    begin
        -- Source: https://stackoverflow.com/a/5550361/4017156
        for i in 1..v_length loop
            my_str := my_str || dbms_random.string(
                case when dbms_random.value(0, 1) < 0.5 then 'l' else 'x' end, 1);
        end loop;
        return my_str;
    end;

    PROCEDURE form IS BEGIN
        htp.print('<form action="' || ADAM_GUI.url('ADAM_USER.login_sql') || '">');
        ADAM_GUI.form_input_clean('username_v', 'text', 'Nazwa użytkownika', 'username_v');
        ADAM_GUI.form_input_clean('password_v', 'password', 'Nazwa użytkownika', 'password_v');
        ADAM_GUI.form_submit('Zaloguj');
        htp.print('</form>');
    END;

    PROCEDURE login_form IS BEGIN 
        ADAM_GUI.header('ADAM_USER');
        ADAM_USER.form();
        ADAM_GUI.footer;
    END;

    FUNCTION authenticate(username_v varchar2, password_v varchar2) RETURN varchar2 IS
        user_count number;
        user_v "user"%rowtype;
        session_key varchar2(100);
    BEGIN
            SELECT COUNT(id) INTO user_count FROM "user" WHERE username=username_v AND password=password_v AND admin=1;
            IF user_count <> 0 THEN
                SELECT * INTO user_v FROM "user" WHERE username=username_v;
                SELECT RANDOM_STR(90) INTO session_key FROM dual;
                INSERT INTO sessions VALUES (0, session_key, user_v.id, sysdate);
                -- OWA_COOKIE.SEND('session_key', session_key);
                RETURN session_key;
            ELSE
                RETURN '';
            END IF;
                EXCEPTION
        when others then
            ADAM_GUI.danger(SQLCODE, sqlerrm);
            RETURN '';
    END;
    PROCEDURE login_sql(username_v varchar2, password_v varchar2) IS 
        session_key varchar2(100);
    BEGIN 
        session_key:=ADAM_USER.authenticate(username_v, password_v);
        IF NVL(session_key,'X') != 'X' THEN
            OWA_UTIL.MIME_HEADER('TEXT/HTML',FALSE);
            OWA_COOKIE.SEND('SESSION_ID', session_key);
            OWA_UTIL.HTTP_HEADER_CLOSE;
            ADAM_GUI.header('ADAM_USER');
            ADAM_GUI.success('Nice!', 'Authorized success full');
            ADAM_GUI.footer;
        ELSE
            ADAM_GUI.header('ADAM_USER');
            ADAM_GUI.danger('Oh sorry!', 'Authentication failed!');
            ADAM_USER.form();
            ADAM_GUI.footer;
        END IF;
        EXCEPTION
        when others then
            ADAM_GUI.danger(SQLCODE, sqlerrm);
    END;
    PROCEDURE logout IS BEGIN NULL; END;
    PROCEDURE register_form IS BEGIN NULL; END;
    PROCEDURE register_sql(username_v varchar2, password_v varchar2) IS BEGIN NULL; END;

END ADAM_USER;
/

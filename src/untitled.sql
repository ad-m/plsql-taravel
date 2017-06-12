SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE PAKIET AS
PROCEDURE pokaz_trips();
PROCEDURE dodaj_trip_formularz ();
PROCEDURE dodaj_trip (base_price_v integer,
                      description_v varchar2(1000),
                      main_image_v varchar2(100),
                      name_v varchar2(100),
                      space_v integer,
                      location_id_v integer,
                      created_on_v date,
                      modified_on_v date,
                      active_v smallint);
PROCEDURE aktualizuj_oferte_form(id_v varchar2);
PROCEDURE aktualizuj_oferte(id_v varchar2,
                            base_price_v integer,
                            description_v varchar2(1000),
                            main_image_v varchar2(100),
                            name_v varchar2(100),
                            space_v integer,
                            location_id_v integer,
                            created_on_v date,
                            modified_on_v date,
                            active_v smallint);
PROCEDURE usun_oferte (nr_rej_v varchar2);
END PAKIET;
/

CREATE OR REPLACE PACKAGE BODY PAKIET AS
  PROCEDURE pokaz_oferte (marka varchar2) AS
  BEGIN
    IF check_v > 0 THEN
      DBMS_OUTPUT.PUT_LINE('Pozostalo ' || check_v || ' wywolan.');
      FOR dane IN (SELECT * FROM komis WHERE marka_pojazdu = marka)
      LOOP
        DBMS_OUTPUT.PUT_LINE(dane.nr_rej || '=' || dane.opis || ' -> ' || dane.cena);
      END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Limit wywolan wyczerpany');
    END IF;
    check_v := check_v -1;
  END;

  PROCEDURE aktualizuj_oferte (nr_rej_v varchar2, cena_v NUMBER, opis_v VARCHAR2) AS
  BEGIN
    IF check_v > 0 THEN
      DBMS_OUTPUT.PUT_LINE('Pozostalo ' || check_v || ' wywolan.');
      UPDATE komis SET cena = cena_v,opis=opis_v WHERE nr_rej = nr_rej_v;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Limit wywolan wyczerpany');
    END IF;
    check_v := check_v -1;
  END;

  PROCEDURE usun_oferte (nr_rej_v varchar2) AS
  BEGIN
    IF check_v > 0 THEN
      DBMS_OUTPUT.PUT_LINE('Pozostalo ' || check_v || ' wywolan.');
      ds := 'DELETE FROM komis WHERE nr_rej = :name';
      EXECUTE IMMEDIATE ds USING nr_rej_v;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Limit wywolan wyczerpany');
    END IF;
    check_v := check_v -1;
  END;

  FUNCTION Najdrozszy_model
  RETURN VARCHAR2
  IS fv_output varchar2(30);
  BEGIN 
    IF check_v > 0 THEN
      DBMS_OUTPUT.PUT_LINE('Pozostalo ' || check_v || ' wywolan.');
      SELECT nr_rej 
      INTO fv_output
      FROM komis
      WHERE ROWNUM = 1
      ORDER BY cena;
      RETURN(fv_output); 
    ELSE
        DBMS_OUTPUT.PUT_LINE('Limit wywolan wyczerpany');
    END IF;
    check_v := check_v -1;
  END;

  FUNCTION Najnowszy_model
  RETURN VARCHAR2
  IS fv_output varchar2(30);
  BEGIN 
    IF check_v > 0 THEN
      DBMS_OUTPUT.PUT_LINE('Pozostalo ' || check_v || ' wywolan.');
      SELECT nr_rej 
      INTO fv_output
      FROM komis
      WHERE ROWNUM = 1
      ORDER BY rok_produkcji;
      RETURN(fv_output); 
    ELSE
        DBMS_OUTPUT.PUT_LINE('Limit wywolan wyczerpany');
    END IF;
    check_v := check_v -1;
  END;
END PAKIET;

/
SET SERVEROUTPUT ON;
BEGIN
PAKIET.pokaz_oferte('XX');
PAKIET.ustaw_check();
PAKIET.pokaz_oferte('XX');
END;

SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PROCEDURE home IS
BEGIN
ADAM_GUI.header('home');
htp.print('      <div class="jumbotron">
        <h1 class="display-3">Biuro podróży</h1>
        <p class="lead">Odleć w zapomnienie</p>
        <p>Praca zaliczeniowa Karola Breguły pisana w Instytucie Informatyki pod kierunkiem mgr Zbigniewa Młynarskiego</p>
      </div>');
ADAM_GUI.footer;
END;
/

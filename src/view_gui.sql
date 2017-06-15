SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE ADAM_GUI AS
PROCEDURE header(active varchar2);
PROCEDURE footer;
FUNCTION url(postfix varchar2) RETURN VARCHAR2;
PROCEDURE top_menu(active varchar2);
PROCEDURE button(prefix varchar2, txt varchar2);
PROCEDURE form_input(id varchar2, type varchar2, label varchar2, name varchar2, value varchar2);
PROCEDURE form_input_clean(id varchar2, type varchar2, label varchar2, name varchar2);
PROCEDURE form_textarea(id varchar2, label varchar2, name varchar2, content varchar2);
PROCEDURE form_textarea_clean(id varchar2, label varchar2, name varchar2);
PROCEDURE form_submit(label varchar2);
PROCEDURE success(strong varchar2, msg varchar2);
PROCEDURE danger(strong varchar2, msg varchar2);
PROCEDURE warning(strong varchar2, msg varchar2);
PROCEDURE two_column(col1 varchar2, col2 varchar2);
PROCEDURE form_option(value varchar2, label varchar2, selected varchar2);
PROCEDURE button_group (postfix1 varchar2, label1 varchar2, postfix2 varchar2, label2 varchar2);
END ADAM_GUI;
/
SET SERVEROUTPUT ON;
SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY ADAM_GUI AS
PROCEDURE header(active varchar2) IS BEGIN 
    htp.htmlOpen;
    htp.headOpen;
    htp.title('Biuro podróży');
    htp.print('<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.6/css/bootstrap.min.css" integrity="sha384-rwoIResjU2yc3z8GV/NPeZWAv56rSmLldC3R/AZzGRnGxQQKnKkoFVhFQhNUwEyJ" crossorigin="anonymous">');
    htp.print('<link rel="stylesheet" href="http://v4-alpha.getbootstrap.com/examples/narrow-jumbotron/narrow-jumbotron.css">');
    htp.print('<style>.container { max-width: 80rem; } </style>');
    htp.headClose;
    htp.bodyOpen;
    ADAM_GUI.top_menu(active);
END header; 

FUNCTION url(postfix varchar2) RETURN VARCHAR2 IS BEGIN
    return owa_util.get_owa_service_path || postfix;
END url;

PROCEDURE nav_link(section varchar2, function varchar2, label varchar2, active varchar2) IS BEGIN
htp.print('<li class="nav-item">');
htp.print('<a class="nav-link');
IF section = active THEN
   htp.print(' active');
END IF;
htp.print('" href="');
htp.print(ADAM_GUI.url(section || '.' || function));
htp.print('">'); 
htp.print(label);
htp.print('</a>');
htp.print('</li>');
END nav_link;
PROCEDURE top_menu(active varchar2) IS BEGIN
    htp.print('<div class="container">');
    htp.print('<div class="header clearfix">
        <nav>
          <ul class="nav nav-pills float-right">');
    ADAM_GUI.nav_link('ADAM_TRIP', 'home', 'Wycieczki', active);
    ADAM_GUI.nav_link('ADAM_LOCATION', 'home', 'Lokalizacje', active);
    ADAM_GUI.nav_link('ADAM_GUEST', 'home', 'Goście', active);
    ADAM_GUI.nav_link('ADAM_ORDER', 'home', 'Zamówienia', active);
    ADAM_GUI.nav_link('ADAM_PAYMENT_FORM', 'home', 'Formy płatności', active);
    ADAM_GUI.nav_link('ADAM_PAYMENT', 'home', 'Płatności', active);
    ADAM_GUI.nav_link('ADAM_COUNTRY', 'home', 'Kraje', active);
    htp.print('</ul>
        </nav>
        <h3 class="text-muted">Biuro podróży</h3>
      </div>');
END top_menu;

PROCEDURE footer IS BEGIN
    htp.print('<footer class="footer"><p>Żadne prawa nie zastrzeżone. Karol Breguła 2017</p></footer>');
    htp.print('</div>'); -- /div.container
    htp.print('<script src="https://code.jquery.com/jquery-3.1.1.slim.min.js" integrity="sha384-A7FZj7v+d/sdmMqp/nOQwliLvUsJfDHW+k9Omg/a/EheAdgtzNs3hpfag6Ed950n" crossorigin="anonymous"></script>');
    htp.print('<script src="https://cdnjs.cloudflare.com/ajax/libs/tether/1.4.0/js/tether.min.js" integrity="sha384-DztdAPBWPRXSA/3eYEEUWrWCy7G5KFbe8fFjk5JAIxUYHKkDx6Qin1DkWx51bBrb" crossorigin="anonymous"></script>');
    htp.print('<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.6/js/bootstrap.min.js" integrity="sha384-vBWWzlZJ8ea9aCX4pEW3rVHjgjt7zpkNpZk+02D9phzyeVkE+jo0ieGizqPLForn" crossorigin="anonymous"></script>');
    htp.bodyClose;
    htp.htmlClose;
END footer;

PROCEDURE button(prefix varchar2, txt varchar2) IS BEGIN
    htp.print('<a class="btn btn-primary" href="' || ADAM_GUI.url(prefix) || '">' || txt || '</a>');
END button;

PROCEDURE form_input(id varchar2, type varchar2, label varchar2, name varchar2, value varchar2) IS BEGIN
    htp.print('<div class="form-group">
        <label for="' || id || '">' || label || '</label>
        <input type="' || type || '" name="' || name || '" class="form-control" id="' || id || '" value="' || value || '">
    </div>');
END form_input;

PROCEDURE form_input_clean(id varchar2, type varchar2, label varchar2, name varchar2) IS BEGIN
    ADAM_GUI.form_input(id, type, label, name, '');
END form_input_clean; 

PROCEDURE form_textarea(id varchar2, label varchar2, name varchar2, content varchar2) IS BEGIN
    htp.print('  <div class="form-group">
    <label for="' || id || '">' || label || '</label>
    <textarea name="' || name || '" class="form-control" id="' || id || '" rows="3">' || content || '</textarea>
  </div>');
END form_textarea;
PROCEDURE form_textarea_clean(id varchar2, label varchar2, name varchar2) IS BEGIN
    ADAM_GUI.form_textarea(id, label, name, '');
END form_textarea_clean;

PROCEDURE form_submit(label varchar2) IS BEGIN
    htp.print('  <button type="submit" class="btn btn-primary">' || label || '</button>');
END form_submit;

PROCEDURE success(strong varchar2, msg varchar2) IS BEGIN
    htp.print('<div class="alert alert-success" role="alert">
  <strong>' || strong || '</strong> ' || msg || '</div>');
END success;

PROCEDURE danger(strong varchar2, msg varchar2) IS BEGIN
    htp.print('<div class="alert alert-danger" role="alert">
  <strong>' || strong || '</strong> ' || msg || '</div>');
END danger;

PROCEDURE warning(strong varchar2, msg varchar2) IS BEGIN
    htp.print('<div class="alert alert-warning" role="alert">
  <strong>' || strong || '</strong> ' || msg || '</div>');
END warning;

PROCEDURE two_column(col1 varchar2, col2 varchar2) IS BEGIN
    htp.print('<tr><td>' || col1 || '</td><td>' || col2 || '</td></tr>');
END two_column;

PROCEDURE form_option(value varchar2, label varchar2, selected varchar2) IS BEGIN
    htp.print('<option value="' || value || '"');
    IF selected = value THEN
        htp.print(' selected="selected"');
    END IF;
    htp.print('>' || label || '</option>');
END form_option;

PROCEDURE button_group (postfix1 varchar2, label1 varchar2, postfix2 varchar2, label2 varchar2) IS BEGIN
    htp.print('<div class="btn-group" role="group">
  <a href="'|| ADAM_GUI.url(postfix1) || '" class="btn btn-primary">'   || label1 || '</a>
  <a href="'|| ADAM_GUI.url(postfix2) || '" class="btn btn-secondary">' || label2 || '</a>
</div>');
END button_group;

END ADAM_GUI;

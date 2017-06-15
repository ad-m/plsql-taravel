.PHONY: clean build

build/db.sql:
	@cat src/schema.sql src/initial.sql > build/db.sql;

build/web.sql:
	@cat src/view_*.sql > build/web.sql;

build/project.sql: build/db.sql build/web.sql
	cat build/db.sql build/web.sql > build/project.sql;

clean:
	@rm build/*.sql;

build: build/project.sql


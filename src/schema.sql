-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2017-06-22 06:26:57.327

-- tables
-- Table: address
CREATE TABLE address (
    id integer  NOT NULL,
    city varchar2(250)  NOT NULL,
    name varchar2(250)  NOT NULL,
    postcode varchar2(6)  NOT NULL,
    street varchar2(250)  NOT NULL,
    street_number varchar2(10)  NOT NULL,
    taxpayer_id varchar2(15)  NOT NULL,
    user_id integer  NOT NULL,
    CONSTRAINT address_pk PRIMARY KEY (id)
) ;

-- Table: country
CREATE TABLE country (
    id integer  NOT NULL,
    continent integer  NOT NULL,
    name varchar2(100)  NOT NULL,
    CONSTRAINT country_pk PRIMARY KEY (id)
) ;

CREATE INDEX country_idx_1 
on country 
(name ASC)
;

-- Table: guest
CREATE TABLE guest (
    id integer  NOT NULL,
    first_name varchar2(100)  NOT NULL,
    second_name varchar2(100)  NOT NULL,
    order_id integer  NOT NULL,
    CONSTRAINT guest_pk PRIMARY KEY (id)
) ;

-- Table: location
CREATE TABLE location (
    id integer  NOT NULL,
    name varchar2(100)  NOT NULL,
    country_id integer  NOT NULL,
    CONSTRAINT location_pk PRIMARY KEY (id)
) ;

CREATE INDEX location_idx_1 
on location 
(name ASC)
;

-- Table: order
CREATE TABLE "order" (
    id integer  NOT NULL,
    created date  NOT NULL,
    note varchar2(255)  NOT NULL,
    unit_price integer  NOT NULL,
    trip_id integer  NOT NULL,
    address_id integer  NOT NULL,
    CONSTRAINT order_pk PRIMARY KEY (id)
) ;

-- Table: payment
CREATE TABLE payment (
    id integer  NOT NULL,
    payment_form_id integer  NOT NULL,
    order_id integer  NOT NULL,
    CONSTRAINT payment_pk PRIMARY KEY (id)
) ;

-- Table: payment_form
CREATE TABLE payment_form (
    id integer  NOT NULL,
    name varchar2(100)  NOT NULL,
    active smallint  NOT NULL,
    CONSTRAINT payment_form_pk PRIMARY KEY (id)
) ;

-- Table: sessions
CREATE TABLE sessions (
    id integer  NOT NULL,
    key varchar2(100)  NOT NULL,
    user_id integer  NOT NULL,
    last_used date  NOT NULL,
    CONSTRAINT session_key_1 UNIQUE (key),
    CONSTRAINT sessions_pk PRIMARY KEY (id)
) ;

-- Table: trip
CREATE TABLE trip (
    id integer  NOT NULL,
    base_price integer  NOT NULL,
    description varchar2(1000)  NOT NULL,
    main_image varchar2(100)  NOT NULL,
    name varchar2(100)  NOT NULL,
    space integer  NOT NULL,
    location_id integer  NOT NULL,
    created_on date  NOT NULL,
    modified_on date  NOT NULL,
    active smallint  NOT NULL,
    departure_date date  NOT NULL,
    CONSTRAINT trip_pk PRIMARY KEY (id)
) ;

-- Table: user
CREATE TABLE "user" (
    id integer  NOT NULL,
    username varchar2(25)  NOT NULL,
    password varchar2(64)  NOT NULL,
    email varchar2(100)  NOT NULL,
    address_id integer  NULL,
    admin integer  NOT NULL,
    CONSTRAINT user_pk PRIMARY KEY (id)
) ;

-- foreign keys
-- Reference: address_user (table: address)
ALTER TABLE address ADD CONSTRAINT address_user
    FOREIGN KEY (user_id)
    REFERENCES "user" (id);

-- Reference: guest_order (table: guest)
ALTER TABLE guest ADD CONSTRAINT guest_order
    FOREIGN KEY (order_id)
    REFERENCES "order" (id);

-- Reference: location_country (table: location)
ALTER TABLE location ADD CONSTRAINT location_country
    FOREIGN KEY (country_id)
    REFERENCES country (id);

-- Reference: order_address (table: order)
ALTER TABLE "order" ADD CONSTRAINT order_address
    FOREIGN KEY (address_id)
    REFERENCES address (id);

-- Reference: order_trip (table: order)
ALTER TABLE "order" ADD CONSTRAINT order_trip
    FOREIGN KEY (trip_id)
    REFERENCES trip (id);

-- Reference: payment_order (table: payment)
ALTER TABLE payment ADD CONSTRAINT payment_order
    FOREIGN KEY (order_id)
    REFERENCES "order" (id);

-- Reference: payment_payment_form (table: payment)
ALTER TABLE payment ADD CONSTRAINT payment_payment_form
    FOREIGN KEY (payment_form_id)
    REFERENCES payment_form (id);

-- Reference: sessions_user (table: sessions)
ALTER TABLE sessions ADD CONSTRAINT sessions_user
    FOREIGN KEY (user_id)
    REFERENCES "user" (id);

-- Reference: trip_location (table: trip)
ALTER TABLE trip ADD CONSTRAINT trip_location
    FOREIGN KEY (location_id)
    REFERENCES location (id);

-- Reference: user_address (table: user)
ALTER TABLE "user" ADD CONSTRAINT user_address
    FOREIGN KEY (address_id)
    REFERENCES address (id);

-- End of file.


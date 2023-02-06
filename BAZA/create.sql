/*menu table*/
drop table pizza;
drop trigger BI_pizza_ID;
drop sequence pizza_id_seq;

CREATE TABLE pizza (
	ID NUMBER(6, 0) NOT NULL,
  typeId NUMBER(1, 0) REFERENCES typename(ID),
  naziv VARCHAR(30) NOT NULL,
  sastojci VARCHAR(255) NOT NULL,
  cijena DECIMAL(10,2) NOT NULL,
	constraint pizza_PK PRIMARY KEY (ID));

CREATE sequence pizza_ID_SEQ;

CREATE trigger BI_pizza_ID
  before insert on pizza
  for each row
begin
  select pizza_ID_SEQ.nextval into :NEW.ID from dual;
end;

/*typename table*/
drop table typename;

create table typename(
    ID NUMBER(1, 0),
    naziv VARCHAR(20) NOT NULL,
    constraint type_PK PRIMARY KEY (ID));

/*korisnik table*/
drop table korisnik;
drop sequence korisnik_id_seq;
drop trigger BI_korisnik_ID;

CREATE TABLE korisnik (
  ID NUMBER(6, 0) NOT NULL,
  ime VARCHAR2(30) NOT NULL,
  prezime VARCHAR2(30) NOT NULL,
  brmob NUMBER (10,0) NOT NULL,
  OIB NUMBER(11,0) NOT NULL,
  email VARCHAR2(40) NOT NULL,
  password VARCHAR2(20) NOT NULL,
  spol NUMBER (1,0) NOT NULL,
  uloga VARCHAR2(30) NOT NULL,
  constraint korisnik_PK PRIMARY KEY (ID));

CREATE sequence korisnik_ID_SEQ;

CREATE trigger BI_korisnik_ID
  before insert on korisnik
  for each row
begin
  select korisnik_ID_SEQ.nextval into :NEW.ID from dual;
end;

/*orders table*/
drop table orderstable;
drop sequence orderstable_ID_SEQ;
drop trigger BI_orderstable_ID;

CREATE TABLE orderstable (
    ID NUMBER(6, 0) NOT NULL,
    userId NUMBER(6, 0) NOT NULL,
    itemId NUMBER(6, 0) NOT NULL,
    constraint orders_PK PRIMARY KEY (ID),
    constraint orders_FK1 FOREIGN KEY (userId)
    REFERENCES korisnik(ID)
    ON DELETE CASCADE,
    constraint orders_FK2 FOREIGN KEY (itemId)
    REFERENCES pizza(ID)
    ON DELETE CASCADE);
    
CREATE sequence orderstable_ID_SEQ;

CREATE trigger BI_orderstable_ID
  before insert on orderstable
  for each row
begin
  select orderstable_ID_SEQ.nextval into :NEW.ID from dual;
end;
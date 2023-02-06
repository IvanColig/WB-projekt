--update1
--postavi ime korisnika s IDjem 5 u John
UPDATE korisnik
SET ime = 'John'
WHERE ID = 5;
--update2
--promjeni sastojke Greek pizze
UPDATE pizza
SET sastojci = 'Cheese, Tomato Sauce, Ham, Mushroom, Olives'
WHERE naziv = 'Greek';
--update3
--promjeni email korisnika s IDjem 4
UPDATE korisnik
SET email = 'john@gmail.com'
WHERE ID = 4;
--update4
--promjeni cijenu jela s IDjem 2 u 15
UPDATE pizza
SET cijena = 15
WHERE ID = 2;
--update5
--promjeni narudzbu za korisnika pod IDjem 7
UPDATE orderstable
SET itemId = 10
WHERE userId = 7;
--update6
--promjeni cijenu na 20 za sva jela koja u nazivu imaju pizza
UPDATE pizza
SET cijena = 20
WHERE naziv like '%pizza%';
--update7
--promijeni lozinku gdje je email korisnika ...
UPDATE korisnik 
SET password = 'pass123' 
WHERE email = 'marko.novak@gmail.com';
--update8
--promjeni kolicinu narudzbi za svakog korisnika gdje je itemId = 1
UPDATE orderstable 
SET quantity = 3 
WHERE itemId = 1;
--update9
--promjeni prezime u Ivic kod osoba koje imaju p u imenu
UPDATE korisnik
SET prezime = 'Ivic'
WHERE ime like '%p%'
--update10
--promjeni broj mobitela korisnika s IDjem 9
UPDATE korisnik
SET brmob = 1211367890
WHERE ID = 9;

--DELETE
DELETE FROM pizza;
DELETE FROM korisnik;
DELETE FROM orderstable;
DELETE FROM typename;
--delete1
--izbrisi korisnike s imenom john
DELETE FROM korisnik
WHERE ime = 'John';
--delete2
--izbrisi sve ordere gdje je kolicina manja od 5
DELETE FROM orderstable
WHERE quantity < 5;
--delete3
--izbrisi sva jela gdje je cijena veca od 15
DELETE FROM pizza
WHERE cijena > 15;
--delete4
--izbrisi korisnika ciji je OIB ...
DELETE FROM korisnik
WHERE OIB = 12345678901;
--delete5
--izbrisi ordere gdje je itemID 2
DELETE FROM orderstable
WHERE itemId = 2;
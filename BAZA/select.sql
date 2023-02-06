/*select1*/
--dohvati podatke iz tablice pizza i zamijeni typeid sa nazivom pod alijasom vrsta iz tablice typename
SELECT pizza.ID, typename.naziv vrsta, pizza.naziv, pizza.sastojci, pizza.cijena
FROM pizza
JOIN typename ON pizza.typeId = typename.ID;
/*select2*/
--dohvati naziv i cijenu jela te id korisnika koji je to narucio
SELECT pizza.naziv, pizza.cijena, orderstable.userId
FROM pizza
JOIN orderstable
ON pizza.ID = orderstable.itemId;
/*select3*/
--dohvati ime i prezime korisnika te naziv i cijenu jela iz tablice orderstable
SELECT korisnik.ime, korisnik.prezime, pizza.naziv, pizza.cijena
FROM korisnik
JOIN orderstable
ON korisnik.ID = orderstable.userId
JOIN pizza
ON orderstable.itemId = pizza.ID;
/*select4*/
--dohvati vrstu jela te naziv jela spojenih preko typeID
SELECT pizza.naziv, typename.naziv vrsta
FROM pizza
INNER JOIN typename
ON pizza.typeId = typename.ID;
/*selcet5*/
--dohvati jela iz menija koja su pizza
SELECT pizza.naziv, pizza.sastojci, pizza.cijena
FROM pizza
JOIN typename
ON pizza.typeId = typename.ID
WHERE typename.naziv = 'pizza';
/*select6*/
--dohvati jela iz menija koja su pasta
SELECT pizza.naziv, pizza.sastojci, pizza.cijena
FROM pizza
JOIN typename
ON pizza.typeId = typename.ID
WHERE typename.naziv = 'pasta';
/*select7*/
--dohvati jela poredavsi po cijeni od najjeftinije do najskuplje
SELECT pizza.naziv, pizza.cijena
FROM pizza
ORDER BY cijena;
/*select8*/
--dohvati ime, prezime, jelo, cijenu i kolicinu te poredaj po kolicini od vise prema manje
SELECT korisnik.ime, korisnik.prezime, pizza.naziv, pizza.cijena, orderstable.quantity
FROM korisnik
JOIN orderstable
ON korisnik.ID = orderstable.userId
JOIN pizza
ON orderstable.itemId = pizza.ID order by quantity desc;
/*select9*/
--dohvati naziv, sastojke i cijenu jela koje je pizza i sadrzi provolone cheese
SELECT pizza.naziv, pizza.sastojci, pizza.cijena
FROM pizza
WHERE pizza.sastojci LIKE '%provolone cheese%' and pizza.typeID = 0;
/*select10*/
--dohvati jelo koje sadrzi sastojak koji u sebi ima zare nakon tri slova
SELECT *
FROM pizza
WHERE sastojci LIKE '%___zare%';
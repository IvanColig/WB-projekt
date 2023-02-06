------------------------------------------------------------------------------------
--CREATE PACKAGE DOHVAT
create or replace NONEDITIONABLE PACKAGE DOHVAT AS 

  procedure p_login(in_json in json_object_t, out_json out json_object_t);
  procedure p_get_korisnik(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  procedure p_get_pizza(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  procedure p_get_orders(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  procedure p_get_order(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
  
END DOHVAT;

------------------------------------------------------------------------------------
--DOHVAT BODY
create or replace NONEDITIONABLE PACKAGE BODY DOHVAT AS
e_iznimka exception;
------------------------------------------------------------------------------------
--get_pizza
procedure p_get_pizza(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_pizza json_array_t :=JSON_ARRAY_T('[]');
  l_count number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
  l_page number; 
  l_perpage number;
 BEGIN
    l_obj := JSON_OBJECT_T(in_json);
    
    l_string := in_json.TO_STRING; 
    
    SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.search'),
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' )
    INTO
        l_id,
        l_search,
        l_page,
        l_perpage
    FROM 
       dual;
    
    FOR x IN (
            SELECT 
               json_object('ID' VALUE ID, 
                           'NAZIV' VALUE NAZIV,
                           'SASTOJCI' VALUE SASTOJCI,
                           'CIJENA' VALUE CIJENA) as izlaz
             FROM
                pizza
             where
                ID = nvl(l_id, ID) 
            )
        LOOP
            l_pizza.append(JSON_OBJECT_T(x.izlaz));
        END LOOP;
        
    SELECT
      count(1)
    INTO
       l_count
    FROM 
       pizza
    where
        ID = nvl(l_id, ID) ;
        
    l_obj.put('count',l_count);
    l_obj.put('data',l_pizza);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       common.p_errlog('p_get_pizza', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 99);
       ROLLBACK;    
    
  END p_get_pizza;
  ------------------------------------------------------------------------------------
--get_korisnik
  procedure p_get_korisnik(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_korisnik json_array_t :=JSON_ARRAY_T('[]');
  l_count number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100); 
 BEGIN
    l_obj := JSON_OBJECT_T(in_json);
    
    l_string := in_json.TO_STRING; 
    
    SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.search')
    INTO
        l_id,
        l_search
    FROM 
       dual;
    
    FOR x IN (
            SELECT 
               json_object('ID' VALUE ID, 
                           'IME' VALUE IME,
                           'PREZIME' VALUE PREZIME,
                           'BRMOB' VALUE BRMOB,
                           'OIB' VALUE OIB,
                           'EMAIL' VALUE EMAIL,
                           'SPOL' VALUE  decode(spol, 1, 'female', 0, 'male')) as izlaz
             FROM
                korisnik
             where
                ID = nvl(l_id, ID) 
            )
        LOOP
            l_korisnik.append(JSON_OBJECT_T(x.izlaz));
        END LOOP;
        
    SELECT
      count(1)
    INTO
       l_count
    FROM 
       korisnik
    where
        ID = nvl(l_id, ID) ;
        
    l_obj.put('count',l_count);
    l_obj.put('data',l_korisnik);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       common.p_errlog('p_get_korisnik', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 99);
       ROLLBACK;    
    
  END p_get_korisnik;
------------------------------------------------------------------------------------
--get_orders
procedure p_get_orders(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_orders json_array_t :=JSON_ARRAY_T('[]');
  l_count number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
 BEGIN
    l_obj := JSON_OBJECT_T(in_json);
    
    l_string := in_json.TO_STRING; 
    
    SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.search')
    INTO
        l_id,
        l_search
    FROM 
       dual;
    
    FOR x IN (
            SELECT
               json_object('ID' VALUE o.ID,
                           'USERID' VALUE o.USERID,
                           'NAZIV' VALUE p.NAZIV,
                           'CIJENA' VALUE p.CIJENA,
                           'QUANTITY' VALUE o.QUANTITY) as izlaz
             FROM
                orderstable o
                JOIN pizza p ON o.ITEMID = p.ID
             where
                o.USERID = nvl(l_id, o.USERID) 
            )
        LOOP
            l_orders.append(JSON_OBJECT_T(x.izlaz));
        END LOOP;

        
    SELECT
      count(1)
    INTO
       l_count
    FROM 
       orderstable
    where
        ID = nvl(l_id, ID) ;
        
    l_obj.put('count',l_count);
    l_obj.put('data',l_orders);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       common.p_errlog('p_get_orders', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 99);
       ROLLBACK;    
    
  END p_get_orders;
------------------------------------------------------------------------------------
--get_order
procedure p_get_order(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
  l_obj JSON_OBJECT_T;
  l_orders json_array_t :=JSON_ARRAY_T('[]');
  l_count number;
  l_id number;
  l_string varchar2(1000);
  l_search varchar2(100);
 BEGIN
    l_obj := JSON_OBJECT_T(in_json);
    
    l_string := in_json.TO_STRING; 
    
    SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.search')
    INTO
        l_id,
        l_search
    FROM 
       dual;
    
    FOR x IN (
            SELECT
               json_object('ID' VALUE o.ID,
                           'USERID' VALUE o.USERID,
                           'NAZIV' VALUE p.NAZIV,
                           'CIJENA' VALUE p.CIJENA,
                           'QUANTITY' VALUE o.QUANTITY) as izlaz
             FROM
                orderstable o
                JOIN pizza p ON o.ITEMID = p.ID
             where
                o.ID = nvl(l_id, o.ID) 
            )
        LOOP
            l_orders.append(JSON_OBJECT_T(x.izlaz));
        END LOOP;

        
    SELECT
      count(1)
    INTO
       l_count
    FROM 
       orderstable
    where
        ID = nvl(l_id, ID) ;
        
    l_obj.put('count',l_count);
    l_obj.put('data',l_orders);
    out_json := l_obj;
 EXCEPTION
   WHEN OTHERS THEN
       common.p_errlog('p_get_orders', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 99);
       ROLLBACK;    
    
  END p_get_order;
------------------------------------------------------------------------------------
--login
 PROCEDURE p_login(in_json in json_object_t, out_json out json_object_t )AS
    l_obj        json_object_t := json_object_t();
    l_input      VARCHAR2(4000);
    l_record     VARCHAR2(4000);
    l_username   korisnik.email%TYPE;
    l_password   korisnik.password%TYPE;
    l_id         korisnik.id%TYPE;
    l_out        json_array_t := json_array_t('[]');
 BEGIN
    l_obj.put('h_message', '');
    --l_obj.put('h_errcode', '');
    l_input := in_json.to_string;
    SELECT
        JSON_VALUE(l_input, '$.username' RETURNING VARCHAR2),
        JSON_VALUE(l_input, '$.password' RETURNING VARCHAR2)
    INTO
        l_username,
        l_password
    FROM
        dual;
            
    IF (l_username IS NULL OR l_password is NULL) THEN
       l_obj.put('h_message', 'Molimo unesite korisničko ime i zaporku');
       l_obj.put('h_errcod', 101);
       RAISE e_iznimka;
    ELSE
       BEGIN
          SELECT
             id
          INTO 
             l_id
          FROM
             korisnik
          WHERE
             email = l_username AND 
             password = l_password;
       EXCEPTION
             WHEN no_data_found THEN
                l_obj.put('h_message', 'Nepoznato korisničko ime ili zaporka');
                l_obj.put('h_errcod', 102);
                RAISE e_iznimka;
             WHEN OTHERS THEN
                RAISE;
       END;

       SELECT
          JSON_OBJECT( 
             'ID' VALUE kor.id, 
             'ime' VALUE kor.ime, 
             'prezime' VALUE kor.prezime,
             'brmob' VALUE kor.brmob,
             'OIB' VALUE kor.oib,
             'email' VALUE kor.email, 
             'spol' VALUE kor.spol)
       INTO 
          l_record
       FROM
          korisnik kor
       WHERE
          id = l_id;

    END IF;

    l_out.append(json_object_t(l_record));
    l_obj.put('data', l_out);
    out_json := l_obj;
 EXCEPTION
    WHEN e_iznimka THEN
       out_json := l_obj; 
    WHEN OTHERS THEN
       common.p_errlog('p_users_upd', dbms_utility.format_error_backtrace, sqlcode, sqlerrm, l_input);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 99);
       ROLLBACK;
 END p_login;

END DOHVAT;

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--CREATE PACKAGE PODACI
create or replace NONEDITIONABLE PACKAGE PODACI AS 

 procedure p_save_pizza(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_save_korisnik(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_save_orders(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
 procedure p_add_order(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T);
END PODACI;

create or replace NONEDITIONABLE PACKAGE BODY PODACI AS
e_iznimka exception;

------------------------------------------------------------------------------------
--PODACI BODY
--save_korisnik
-----------------------------------------------------------------------------------------
  procedure p_save_korisnik(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_korisnik korisnik%rowtype;
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
  begin
  
     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
  
     SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.IME'),
        JSON_VALUE(l_string, '$.PREZIME' ),
        JSON_VALUE(l_string, '$.BRMOB' ),
        JSON_VALUE(l_string, '$.EMAIL' ),
        JSON_VALUE(l_string, '$.OIB' ),
        JSON_VALUE(l_string, '$.SPOL' ),
        JSON_VALUE(l_string, '$.ZAPORKA' ),
        JSON_VALUE(l_string, '$.ACTION' )
    INTO
        l_korisnik.id,
        l_korisnik.IME,
        l_korisnik.PREZIME,
        l_korisnik.BRMOB,
        l_korisnik.EMAIL,
        l_korisnik.OIB,
        l_korisnik.SPOL,
        l_korisnik.PASSWORD,
        l_action
    FROM 
       dual; 
       
    --FE kontrole
    if (nvl(l_action, ' ') = ' ') then
        if (filter.f_check_korisnik(l_obj, out_json)) then
           raise e_iznimka; 
        end if;
    end if;
           
    if (l_korisnik.id is null) then
        begin
           insert into korisnik (ime, prezime, brmob, oib, email, password, spol) values
             (l_korisnik.IME, l_korisnik.PREZIME, l_korisnik.BRMOB,
              l_korisnik.OIB, l_korisnik.EMAIL,  l_korisnik.PASSWORD,
              l_korisnik.SPOL);
           commit;
           
           l_obj.put('h_message', 'Uspješno ste unijeli korisnika'); 
           l_obj.put('h_errcode', 0);
           out_json := l_obj;
           
        exception
           when others then 
               COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
               rollback;
               raise;
        end;
    else
       if (nvl(l_action, ' ') = 'delete') then
           begin
               delete korisnik where id = l_korisnik.id;
               commit;    
               
               l_obj.put('h_message', 'Uspješno ste obrisali korisnika'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;
       
       else
       
           begin
               update korisnik
                  set IME = l_korisnik.IME,
                      PREZIME = l_korisnik.PREZIME,
                      BRMOB = l_korisnik.BRMOB,
                      OIB = l_korisnik.OIB,
                      EMAIL = l_korisnik.EMAIL,
                      SPOL = l_korisnik.SPOL
               where
                  id = l_korisnik.id;
               commit;    
               
               l_obj.put('h_message', 'Uspješno ste promijenili korisnika'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;
       end if;     
    end if;
    
    
  exception
     when e_iznimka then
        out_json := l_obj; 
     when others then
        COMMON.p_errlog('p_save_korisnik',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 101);
        out_json := l_obj;
  END p_save_korisnik;
  --save_pizza
-----------------------------------------------------------------------------------------
  procedure p_save_pizza(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_pizza pizza%rowtype;
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
  begin
  
     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
  
     SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.NAZIV'),
        JSON_VALUE(l_string, '$.SASTOJCI' ),
        JSON_VALUE(l_string, '$.CIJENA' ),
        JSON_VALUE(l_string, '$.ACTION' )
    INTO
        l_pizza.id,
        l_pizza.NAZIV,
        l_pizza.SASTOJCI,
        l_pizza.CIJENA,
        l_action
    FROM 
       dual; 
       
    --FE kontrole
    if (nvl(l_action, ' ') = ' ') then
        if (filter.f_check_pizza(l_obj, out_json)) then
           raise e_iznimka; 
        end if;  
    end if;
           
    if (l_pizza.id is null) then
        begin
           insert into pizza (NAZIV, SASTOJCI, CIJENA) values
             (l_pizza.NAZIV, l_pizza.SASTOJCI, l_pizza.CIJENA);
           commit;
           
           l_obj.put('h_message', 'Uspješno ste unijeli jelo'); 
           l_obj.put('h_errcode', 0);
           out_json := l_obj;
           
        exception
           when others then 
               COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
               rollback;
               raise;
        end;
    else
       if (nvl(l_action, ' ') = 'delete') then
           begin
               delete pizza where id = l_pizza.id;
               commit;    
               
               l_obj.put('h_message', 'Uspješno ste obrisali jelo');
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;
       
       else
       
           begin
               update pizza
                  set NAZIV = l_pizza.NAZIV,
                      SASTOJCI = l_pizza.SASTOJCI,
                      CIJENA = l_pizza.CIJENA
               where
                  id = l_pizza.id;
               commit;    
               
               l_obj.put('h_message', 'Uspješno ste promijenili pizzu'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then
                   COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;
       end if;     
    end if;
    
    
  exception
     when e_iznimka then
        out_json := l_obj; 
     when others then
        COMMON.p_errlog('p_save_pizza',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 101);
        out_json := l_obj;
  END p_save_pizza;
--save_orders
-----------------------------------------------------------------------------------------
  procedure p_save_orders(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_orders orderstable%rowtype;
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
  begin
  
     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
  
     SELECT
        JSON_VALUE(l_string, '$.ID' ),
        JSON_VALUE(l_string, '$.QUANTITY'),
        JSON_VALUE(l_string, '$.ACTION' )
    INTO
        l_orders.id,
        l_orders.QUANTITY,
        l_action
    FROM
       dual;
       
    --FE kontrole
    if (nvl(l_action, ' ') = ' ') then
        if (filter.f_check_orders(l_obj, out_json)) then
           raise e_iznimka; 
        end if;  
    end if;
           
       if (nvl(l_action, ' ') = 'delete') then
           begin
               delete orderstable where id = l_orders.id;
               commit;    
               
               l_obj.put('h_message', 'Uspješno ste obrisali narudzbu');
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then 
                   COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;
       
       else
       
           begin
               update orderstable
                  set QUANTITY = l_orders.QUANTITY
               where
                  id = l_orders.id;
               commit;
               
               l_obj.put('h_message', 'Uspješno ste promijenili narudzbu'); 
               l_obj.put('h_errcode', 0);
               out_json := l_obj;
            exception
               when others then
                   COMMON.p_errlog('p_users',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
                   rollback;
                   raise;
            end;
       end if;
    
    
  exception
     when e_iznimka then
        out_json := l_obj; 
     when others then
        COMMON.p_errlog('p_save_orders',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 101);
        out_json := l_obj;
  END p_save_orders;
--add_order
-----------------------------------------------------------------------------------------
  procedure p_add_order(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) AS
      l_obj JSON_OBJECT_T;
      l_order orderstable%rowtype;
      l_count number;
      l_id number;
      l_string varchar2(1000);
      l_search varchar2(100);
      l_page number; 
      l_perpage number;
      l_action varchar2(10);
  begin
  
     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
  

    SELECT
        JSON_VALUE(l_string, '$.ID'),
        JSON_VALUE(l_string, '$.UID')
    INTO
        l_order.ITEMID,
        l_order.USERID
    FROM
        dual;
        

    SELECT COUNT(*) INTO l_count 
    FROM orderstable
    WHERE USERID = l_order.USERID AND ITEMID = l_order.ITEMID;
 
 if l_count > 0 then
   begin
           update orderstable
              set QUANTITY = QUANTITY + 1
           where
              USERID = l_order.USERID AND ITEMID = l_order.ITEMID;
           commit;
           
           l_obj.put('h_message', 'Uspješno ste dodali narudzbu'); 
           l_obj.put('h_errcode', 0);
           out_json := l_obj;
   end;
 else
   begin
       insert into orderstable (USERID, ITEMID, QUANTITY)
       values (l_order.USERID, l_order.ITEMID, 1);
       commit;
       
       l_obj.put('h_message', 'Uspješno ste dodali narudzbu'); 
       l_obj.put('h_errcode', 0);
       out_json := l_obj;
   end;
 end if;

    
    
  exception
     when e_iznimka then
        out_json := l_obj; 
     when others then
        COMMON.p_errlog('p_add_order',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 101);
        out_json := l_obj;
  END p_add_order;  
END PODACI;
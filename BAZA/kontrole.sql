--create package router
create or replace NONEDITIONABLE PACKAGE ROUTER AS 
 e_iznimka exception;

 procedure p_main(p_in in varchar2, p_out out varchar2);

END ROUTER;

--router body
create or replace NONEDITIONABLE PACKAGE BODY ROUTER AS

  procedure p_main(p_in in varchar2, p_out out varchar2) AS
    l_obj JSON_OBJECT_T;
    l_procedura varchar2(40);
  BEGIN
    l_obj := JSON_OBJECT_T(p_in);

    SELECT
        JSON_VALUE(p_in, '$.procedura' RETURNING VARCHAR2)
    INTO
        l_procedura
    FROM DUAL;

    CASE l_procedura
    WHEN 'p_login' THEN
        dohvat.p_login(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_pizza' THEN
        dohvat.p_get_pizza(JSON_OBJECT_T(p_in), l_obj); 
    WHEN 'p_get_orders' THEN
        dohvat.p_get_orders(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_order' THEN
        dohvat.p_get_order(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_korisnik' THEN
        dohvat.p_get_korisnik(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_add_order' THEN
        podaci.p_add_order(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_save_pizza' THEN
        podaci.p_save_pizza(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_save_orders' THEN
        podaci.p_save_orders(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_save_korisnik' THEN
        podaci.p_save_korisnik(JSON_OBJECT_T(p_in), l_obj);
        l_obj.put('h_message', ' Nepoznata metoda ' || l_procedura);
        l_obj.put('h_errcode', 997);
    END CASE;
    p_out := l_obj.TO_STRING;
  END p_main;
END ROUTER;

--create package filter
create or replace NONEDITIONABLE PACKAGE FILTER AS 

  function f_check_korisnik(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_check_pizza(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_check_orders(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;

END FILTER;

--filter body
create or replace NONEDITIONABLE PACKAGE BODY FILTER AS
e_iznimka exception;

--check korisnik
-------------------------------------------------------------------------------
  function f_check_korisnik(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_korisnik korisnik%rowtype;
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
        JSON_VALUE(l_string, '$.IME'),
        JSON_VALUE(l_string, '$.PREZIME' ),
        JSON_VALUE(l_string, '$.BRMOB' ),
        JSON_VALUE(l_string, '$.EMAIL' ),
        JSON_VALUE(l_string, '$.OIB' ),
        JSON_VALUE(l_string, '$.SPOL' ),
        JSON_VALUE(l_string, '$.ZAPORKA' )
    INTO
        l_korisnik.id,
        l_korisnik.IME,
        l_korisnik.PREZIME,
        l_korisnik.BRMOB,
        l_korisnik.EMAIL,
        l_korisnik.OIB,
        l_korisnik.SPOL,
        l_korisnik.PASSWORD
    FROM 
       dual;
    
    if (nvl(l_korisnik.IME, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite ime korisnika '); 
       l_obj.put('h_errcode', 110);
       raise e_iznimka;
    end if;
    
    if (nvl(l_korisnik.PREZIME, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite prezime korisnika '); 
       l_obj.put('h_errcode', 111);
       raise e_iznimka;
    end if;
    
    if (nvl(l_korisnik.BRMOB, 0) = 0) then
       l_obj.put('h_message', 'Molimo unesite broj mobitela ');
       l_obj.put('h_errcode', 112);
       raise e_iznimka;
     else
       if (length(l_korisnik.BRMOB) != 10) then
          l_obj.put('h_message', 'Pogrešno unesen broj mobitela '); 
          l_obj.put('h_errcode', 116);
          raise e_iznimka;
       end if;
    end if;
    
    if (nvl(l_korisnik.EMAIL, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite email korisnika '); 
       l_obj.put('h_errcode', 113);
       raise e_iznimka;
    end if;
    
    if (nvl(l_korisnik.OIB, 0) = 0) then   
       l_obj.put('h_message', 'Molimo unesite OIB korisnika '); 
       l_obj.put('h_errcode', 114);
       raise e_iznimka;
    end if;
        
    if (nvl(l_korisnik.SPOL, 99) = 99) then   
       l_obj.put('h_message', 'Molimo unesite spol korisnika '); 
       l_obj.put('h_errcode', 115);
       raise e_iznimka;
    else
       if (l_korisnik.SPOL not in (0,1)) then
          l_obj.put('h_message', 'Spol može biti ili 0 ili 1 '); 
          l_obj.put('h_errcode', 116);
          raise e_iznimka;
       end if;
    end if;
    
    if (nvl(l_korisnik.id,0) = 0 and nvl(l_korisnik.PASSWORD, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite zaporku korisnika '); 
       l_obj.put('h_errcode', 117);
       raise e_iznimka;
    end if;
    
    out_json := l_obj;
    return false;
    
  EXCEPTION
     WHEN E_IZNIMKA THEN
        return true;
     WHEN OTHERS THEN
        COMMON.p_errlog('p_check_korisnik',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 118);
        out_json := l_obj;
        return true;
  END f_check_korisnik;
  --check pizza
-------------------------------------------------------------------------------
  function f_check_pizza(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_pizza pizza%rowtype;
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
        JSON_VALUE(l_string, '$.NAZIV'),
        JSON_VALUE(l_string, '$.SASTOJCI' ),
        JSON_VALUE(l_string, '$.CIJENA' )
    INTO
        l_pizza.id,
        l_pizza.NAZIV,
        l_pizza.SASTOJCI,
        l_pizza.CIJENA
    FROM 
       dual; 
    
    if (nvl(l_pizza.NAZIV, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite naziv jela '); 
       l_obj.put('h_errcode', 119);
       raise e_iznimka;
    end if;
    
    if (nvl(l_pizza.SASTOJCI, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite sastojke jela '); 
       l_obj.put('h_errcode', 120);
       raise e_iznimka;
    end if;
    
    if (nvl(l_pizza.CIJENA, 0) = 0) then   
       l_obj.put('h_message', 'Molimo unesite cijenu jela '); 
       l_obj.put('h_errcode', 121);
       raise e_iznimka;
    end if;
    
    out_json := l_obj;
    return false;
    
  EXCEPTION
     WHEN E_IZNIMKA THEN
        return true;
     WHEN OTHERS THEN
        COMMON.p_errlog('p_check_pizza',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 122);
        out_json := l_obj;
        return true;
  END f_check_pizza;
--check orders
-------------------------------------------------------------------------------
function f_check_orders(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_orders orderstable%rowtype;
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
        JSON_VALUE(l_string, '$.QUANTITY')
    INTO
        l_orders.id,
        l_orders.QUANTITY
    FROM 
       dual;
    
    if (nvl(l_orders.QUANTITY, 0) = 0) then   
       l_obj.put('h_message', 'Molimo unesite kolicinu'); 
       l_obj.put('h_errcode', 123);
       raise e_iznimka;
    end if;
    
    if(l_orders.QUANTITY < 0) then
       l_obj.put('h_message', 'Kolicina ne moze biti manja od 0'); 
       l_obj.put('h_errcode', 123);
       raise e_iznimka;
    end if;
    
    out_json := l_obj;
    return false;
    
  EXCEPTION
     WHEN E_IZNIMKA THEN
        return true;
     WHEN OTHERS THEN
        COMMON.p_errlog('p_check_orders',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 124);
        out_json := l_obj;
        return true;
  END f_check_orders;
END FILTER;
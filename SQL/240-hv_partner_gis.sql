-- This file is part of the IATI, partnerdump AFFM/Compiere project.
-- Copyright (C) 2014 Barry de Graaff <info@barrydegraaff.tk>, (C) 2012 Arthur Baan, (C) 2012 Fred Stoopendaal
--
-- This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

-- 240-hv_partner_gis 
-- A PL/SQL script that uses Google Maps Geocoding API to convert city and country names to geograpical coordinates and
-- export them to a KML file for display in Google Maps.

-- This script is used to visualise a projects database on a corporate website.

-- The script caches all the geograpical coordinates in a database table, so it saves time in not asking the same
-- city+country lookup in Google API each time.

--Set some extra rights:
--sys as sysdba: grant execute on utl_http to public;
--sys as sysdba: GRANT EXECUTE ON DBMS_LOCK TO public; 
--SYSTEM:  GRANT ADVISOR TO REPORTING.


--  DDL for cache Table HV_GIS
/*
  CREATE TABLE "REPORTING.."HV_GIS" 
   (	"ADDRESS" VARCHAR2(120), 
	"UPDATED" DATE, 
	"COORDS" VARCHAR2(120)
   ) ;

  CREATE UNIQUE INDEX "REPORTING.."HV_GIS_PK" ON "REPORTING.."HV_GIS" ("ADDRESS") 
  ;

  ALTER TABLE "REPORTING.."HV_GIS" ADD CONSTRAINT "HV_GIS_PK" PRIMARY KEY ("ADDRESS") ENABLE;
  ALTER TABLE "REPORTING.."HV_GIS" MODIFY ("ADDRESS" NOT NULL ENABLE);

/*
begin 
dbms_network_acl_admin.create_acl (
  acl => 'acl_utl_http.xml',
  description  => 'ACL assigned to IP address',
  principal => 'REPORTING.,
  is_grant => TRUE,
  privilege => 'connect');
 
dbms_network_acl_admin.assign_acl (
  acl => 'acl_utl_http.xml',
  host => 'maps.googleapis.com',
  lower_port  => null,
  upper_port  => null);
 
commit;
 
end;
/
*/

set define off;


CREATE OR REPLACE PACKAGE REPORTING.HV_PARTNER_GIS
is 
   function http_read (url in varchar2) return clob;
   function geocode (i_address in varchar2) return varchar2;
   procedure prepare_locations;                          
   procedure generate_partner_kml;
end;
/

---------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY REPORTING.HV_PARTNER_GIS
IS
   FUNCTION http_read (url VARCHAR2)
      RETURN clob
   IS
      pcs    UTL_HTTP.html_pieces;
      retv   clob;
   BEGIN
      pcs := UTL_HTTP.request_pieces (url, 100);
      FOR i IN 1 .. pcs.COUNT
      LOOP
         retv := retv || pcs (i);
      END LOOP;   
      RETURN retv;
      --exception
      --when others then 
      --retv := 'error';       
      --RETURN retv;
   END http_read;   

---------------------------------------------------------------------------------------------------------------------------------------

   function geocode (
      i_address in varchar2 
   ) return varchar2
   is
   coords VARCHAR2(32000);
   cache_found number;
   PRAGMA AUTONOMOUS_TRANSACTION;
   begin
      coords :='error';      
      select count(*) into cache_found from reporting.hv_gis a where lower(a.address) = lower(i_address);    
      if cache_found >= 1 then
         select a.coords into coords from reporting.hv_gis a where lower(a.address) = lower(i_address); 
         return coords;            
      else        
        select coords into coords from (  
        WITH test AS ( SELECT xmltype(http_read('http://maps.googleapis.com/maps/api/geocode/xml?address='|| replace(replace(i_address,' ', '+'),',+united+republic+of','') ||'&sensor=false')) xml FROM dual)
        SELECT 
           extractValue( xml, '//GeocodeResponse/result[1]/geometry/location/lng' ) || ',' || extractValue( xml, '//GeocodeResponse/result[1]/geometry/location/lat' ) coords FROM test);
               IF LENGTH(coords) > 16 THEN
                  INSERT INTO hv_gis VALUES (i_address, sysdate, coords);
                  commit;
               ELSE
                  --This is a final try to do a geocode lookup, if we where looking for street, city, country this will drop the effort down to city,country
                  select coords into coords from (  
                  WITH test AS ( SELECT xmltype(http_read('http://maps.googleapis.com/maps/api/geocode/xml?address='|| replace(replace(substr(lower(i_address),INSTR(lower(i_address),',', -3, 2)),' ', '+'),',+united+republic+of','') ||'&sensor=false')) xml FROM dual)
                  SELECT 
                     extractValue( xml, '//GeocodeResponse/result[1]/geometry/location/lng' ) || ',' || extractValue( xml, '//GeocodeResponse/result[1]/geometry/location/lat' ) coords FROM test);
                         IF LENGTH(coords) > 16 THEN
                            INSERT INTO hv_gis VALUES (i_address, sysdate, coords);
                            commit;                           
                         END IF;   
               END IF;   
        return coords;            
      end if;
	    exception
      when others then
      coords :='error';
      return coords;    
   end geocode;

---------------------------------------------------------------------------------------------------------------------------------------

procedure prepare_locations
   is
   kmldata clob;
   begin  
      for t in (select distinct lower(b.address1 || ', ' || b.city || ', ' || b.country) as address  from reporting.hv_xml_commitment a, reporting.hv_xml_bpartner_locations b where a.c_bpartner_id = b.c_bpartner_id and lower((b.address1 || ', ' || b.city || ', ' || b.country)) NOT IN (select lower(address) from reporting.hv_gis) UNION select name from c_country where isactive='Y' and lower((c_country.name)) NOT IN (select lower(address) from reporting.hv_gis))                     
      loop
            kmldata:=geocode(t.address);
            DBMS_LOCK.SLEEP(1);
      end loop;     
      return;
   end prepare_locations;

---------------------------------------------------------------------------------------------------------------------------------------

procedure generate_partner_kml
   is
   kmldata clob;
   begin  
      kmldata:='<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://earth.google.com/kml/2.0"><Document>';
   
      for t in (select distinct a.identifier, regexp_replace(a.title, '[^[:alnum:]|^[:space:]]') as title, (b.address1 || ', ' || b.city || ', ' || b.country) as ADDRESS, reporting.hv_partner_gis.geocode(b.address1 || ', ' || b.city || ', ' || b.country) as coords from reporting.hv_xml_commitment a, reporting.hv_xml_bpartner_locations b where a.c_bpartner_id = b.c_bpartner_id order by identifier asc)                     
      loop
            kmldata:=kmldata || '<Placemark><description><![CDATA[<a href="http://hivos.org/activity/' || substr(lower(replace(convert(regexp_replace(t.title, '[^[:alnum:]|^[:space:]]'),'US7ASCII'),' ','-')),0,82)||'">' || t.IDENTIFIER || ' ' || t.address || ' ' || t.title ||  '</a>]]></description><Point><coordinates>' || t.coords || substr(t.identifier,9,4) || '</coordinates></Point></Placemark>'||chr(10);
      end loop;     
      
      kmldata:=kmldata || '</Document></kml>';
      dbms_advisor.create_file(kmldata,'HV_XMLDIR','partner.kml');
      return;
   end generate_partner_kml;
  
END HV_PARTNER_GIS;
/


/*
--Example on how to do a geocode lookup (and use the cache if possible)
select reporting.hv_partner_gis.geocode('patel building, 5th floor kisutu lane , dar es salaam, tanzania, united republic of') from dual
set define off;
SELECT reporting.hv_partner_gis.http_read('http://maps.googleapis.com/maps/api/geocode/xml?address=,+harare,+zimbabwe&sensor=false') xml FROM dual
select reporting.hv_partner_gis.geocode('Calle 10  Nº 351 e/ 15 y 17, Vedado, P. Revolucion , CIUDAD DE LA HABANA, Cuba') from dual;
select reporting.hv_partner_gis.http_read('http://maps.googleapis.com/maps/api/geocode/xml?address=jakarta+pusat,+indonesia&sensor=false') xml FROM dual

--Example on how to run this script (two steps):
--exec reporting.hv_partner_gis.prepare_locations;
--exec reporting.hv_partner_gis.generate_partner_kml;

select * from hivo_region

select * from hivo_regioncountry 

select name from c_country where isactive='Y'  order by c_country_id desc

select * from reporting.hv_gis where lower(address) like 'raamweg%';


select distinct b.address1 as address  from reporting.hv_xml_commitment a, reporting.hv_xml_bpartner_locations b where a.c_bpartner_id = b.c_bpartner_id and lower((b.address1 || ', ' || b.city || ', ' || b.country)) NOT IN (select lower(address) from reporting.hv_gis) UNION select name from c_country where isactive='Y' and lower((c_country.name)) NOT IN (select lower(address) from reporting.hv_gis)

select * from c_location

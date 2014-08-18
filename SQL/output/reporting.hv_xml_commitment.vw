-- This file is part of the IATI, partnerdump AFFM/Compiere project.
-- Copyright (C) 2014 Barry de Graaff <info@barrydegraaff.tk>, (C) 2012 Arthur Baan, (C) 2012 Fred Stoopendaal
--
-- This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

-- BF modified: 
-- - and least( co.dateto, nvl( pe.dateto, co.dateto )) < sysdate - 180;
-- + and greatest( co.dateto, nvl( pe.dateto, co.dateto )) > sysdate - 180;
-- instead of 180, 360
-- instead of confidentialitystatus <> 'C', confidentialitystatus = 'P'
-- + 16-10-2012 added afgo_commitmentprocedure_id 

create or replace force view reporting.hv_xml_commitment( afgo_commitment_id
                                                     , confidentialitystatus
                                                     , c_bpartner_id
                                                     , identifier
                                                     , title
                                                     , description
                                                     , actualstart
                                                     , actualend
                                                     , personname
                                                     , telephone
                                                     , email
                                                     , currency
                                                     , countrycode
                                                     , countryname
                                                     , region
                                                     , documentno
                                                     , grandtotal
                                                     , updated
                                                     , dateacct
                                                     , program_name
                                                     , afgo_commitmentprocedure_id
                                                     )
as
   select co.afgo_commitment_id, co.confidentialitystatus, co.c_bpartner_id
        , 'NL-2-' || cast( co.documentno as varchar2( 80 )) identifier
        , cast( co.description as varchar2( 500 )) as title, description
        , co.datefrom actualstart
        , greatest( co.dateto, nvl( pe.dateto, co.dateto )) actualend
        , u.name personname, u.phone telephone, u.email email
        , cast( cu.iso_code as varchar2( 3 )) currency, rc.countrycode
        , rc.name countryname, hr.name region, co.documentno, co.grandtotal
        , co.updated, co.dateacct, o.name program_name
        , co.afgo_commitmentprocedure_id
     from afgo_commitment co inner join c_bpartner p
          on co.c_bpartner_id = p.c_bpartner_id
          left join afgo_program o on co.afgo_program_id = o.afgo_program_id
          left join ad_user u on co.ad_user_id = u.ad_user_id
          left join c_currency cu on co.c_currency_id = cu.c_currency_id
          left join c_country rc on co.c_country_id = rc.c_country_id
          inner join hivo_region hr on hr.hivo_region_id = co.hivo_region_id
          left join
          ( select  mastercommitment_id, min( datefrom ) datefrom
                  , max( dateto ) dateto
               from afgo_commitment co2
              where co2.confidentialitystatus = 'P'
                and co2.processed = 'Y'
           group by mastercommitment_id ) pe
          on pe.mastercommitment_id = co.afgo_commitment_id
    where co.mastercommitment_id is null
      and co.docstatus = 'CO'
      and co.confidentialitystatus = 'P'
      and u.name <> 'fbroek'
      and nvl( o.name, '-' ) <> 'HO PMF'
      and p.confidentialitystatus = 'P'
      and greatest( co.dateto, nvl( pe.dateto, co.dateto )) > sysdate - 360;

-- This file is part of the IATI, partnerdump AFFM/Compiere project.
-- Copyright (C) 2014 Barry de Graaff <info@barrydegraaff.tk>, (C) 2012 Arthur Baan, (C) 2012 Fred Stoopendaal
--
-- This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

-- BF modified: 
-- - and greatest( co.dateto, nvl( pe.dateto, co.dateto )) < sysdate - 180
-- + and greatest( co.dateto, nvl( pe.dateto, co.dateto )) > sysdate - 180
-- instead of 180, 360
-- instead of confidentialitystatus <> 'C', confidentialitystatus = 'P'


create or replace force view reporting.hv_iati_activities( afgo_commitment_id
                                                      , mastercommitment_id
                                                      , identifier
                                                      , title
                                                      , actualstart
                                                      , actualend
                                                      , organisation
                                                      , personname
                                                      , telephone
                                                      , email
                                                      , mailingaddress
                                                      , partner
                                                      , currency
                                                      , recipientcountrycode
                                                      , recipientcountry
                                                      , hierarchy
                                                      , documentno
                                                      , grandtotal
                                                      , updated
                                                      , dateacct
                                                      , program_name
                                                      )
as
   select co.afgo_commitment_id, co.mastercommitment_id
        , 'NL-2-' || cast( co.documentno as varchar2( 80 )) identifier
        , cast( co.description as varchar2( 500 )) as title
        , least( co.datefrom, nvl( pe.datefrom, co.datefrom )) as actualstart
        , greatest( co.dateto, nvl( pe.dateto, co.dateto )) as actualend
        , decode( p.confidentialitystatus
                , 'C', 'Confidential'
                , p.name
                ) as organisation
        , decode( p.confidentialitystatus, 'C', '', u.name ) as personname
        , decode( p.confidentialitystatus, 'C', '', u.phone ) as telephone
        , decode( p.confidentialitystatus, 'C', '', u.email ) as email
        , decode( p.confidentialitystatus
                , 'C', ''
                ,    l.address1
                  || ', '
                  || l.city
                  || ', '
                  || l.postal
                  || ', '
                  || c.description
                ) as mailingaddress
        , p.isvendor partner, cast( cu.iso_code as varchar2( 3 )) currency
        , rc.countrycode, rc.name, 1 as hierarchy, co.documentno
        , co.grandtotal, co.updated, co.dateacct, o.name program_name
     from afgo_commitment co inner join c_bpartner p
          on co.c_bpartner_id = p.c_bpartner_id
          left join afgo_program o on co.afgo_program_id = o.afgo_program_id
          left join c_bpartner_location bl
          on bl.c_bpartner_id = p.c_bpartner_id
        and bl.isshipto = 'Y'
          left join c_location l on bl.c_location_id = l.c_location_id
          left join ad_user u on co.ad_user_id = u.ad_user_id
          left join c_country c on l.c_country_id = c.c_country_id
          left join c_currency cu on co.c_currency_id = cu.c_currency_id
          left join c_country rc on co.c_country_id = rc.c_country_id
          left join
          ( select  mastercommitment_id, min( datefrom ) datefrom
                  , max( dateto ) dateto
               from afgo_commitment co2
              where co2.confidentialitystatus = 'P'
                and co2.processed = 'Y'
           group by mastercommitment_id ) pe
          on pe.mastercommitment_id = co.afgo_commitment_id
    where co.confidentialitystatus = 'P'
      and co.mastercommitment_id is null
      and co.docstatus = 'CO'
      and u.name <> 'fbroek'
      and nvl( o.name, '-' ) <> 'HO PMF'
      --ABA 25-07-2012 if the bp is confidential the contract is also excluded
      and p.confidentialitystatus = 'P'
      --ABA 25-07-2012 contract whit an enddate more than 360 days ago are excluded
      and greatest( co.dateto, nvl( pe.dateto, co.dateto )) > sysdate - 360
   union all
   select 0 afgo_commitment_id, null, 'Confidential' identifier
        , 'Confidential' as title
        , to_date( '01-01-2000', 'dd-mm-yyyy' ) as actualstart
        , cast( null as date ) as actualend, 'Confidential' as organisation
        , null as personname, null as telephone, null as email
        , null as mailingaddress, null as partner, null as currency
        , null as recipientcountrycode, null as recipientcountry
        , 1 as hierarchy, null as documentno, null grandtotal, null updated
        , null dateacct, null program_name
     from dual;



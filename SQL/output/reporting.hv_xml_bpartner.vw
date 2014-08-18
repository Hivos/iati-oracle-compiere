-- This file is part of the IATI, partnerdump AFFM/Compiere project.
-- Copyright (C) 2014 Barry de Graaff <info@barrydegraaff.tk>, (C) 2012 Arthur Baan, (C) 2012 Fred Stoopendaal
--
-- This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

--20120918 barry added http:// for url
--20120918 datefounded = null for legalentitytype 'Individual'
create or replace force view reporting.hv_xml_bpartner( organisation
                                                   , ad_client_id
                                                   , c_bpartner_id
                                                   , firstsale
                                                   , datefounded
                                                   , created
                                                   , searchkey
                                                   , confidentialitystatus
                                                   , url
                                                   , legalentitytype
                                                   )
as
   select p.name organisation, p.ad_client_id, p.c_bpartner_id, p.firstsale
        , case when l.name = 'Individual' then null else p.datefounded end, p.created, p.value searchkey
        , p.confidentialitystatus, case when p.url is not null then 'http://' || replace (p.url, 'http://') else null end, l.name legalentitytype
     from c_bpartner p left join hivo_legalentitytype l
          on p.hivo_legalentitytype_id = l.hivo_legalentitytype_id
    where exists( select null
                   from reporting.hv_xml_commitment c
                  where p.c_bpartner_id = c.c_bpartner_id );



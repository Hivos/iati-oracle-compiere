-- This file is part of the IATI, partnerdump AFFM/Compiere project.
-- Copyright (C) 2014 Barry de Graaff <info@barrydegraaff.tk>, (C) 2012 Arthur Baan, (C) 2012 Fred Stoopendaal
--
-- This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

create or replace force view reporting.hv_xml_bpartner_locations (
   c_bpartner_id
  ,c_location_id
  ,isshipto
  ,isremitto
  ,ispayfrom
  ,isbillto
  ,address
  ,address1
  ,postal
  ,city
  ,countrycode
  ,country
)
as
   select pl.c_bpartner_id
         ,l.c_location_id
         ,pl.isshipto
         ,pl.isremitto
         ,pl.ispayfrom
         ,pl.isbillto
         ,rtrim (l.address1 || chr (10) || l.address2 || chr (10) || l.address3 || chr (10) || l.address4, chr (10)) address
         ,l.address1
         ,l.postal
         ,l.city
         ,c.countrycode
         ,nvl (c.description, c.name) country
   from   c_bpartner_location pl
          inner join c_location l
             on pl.c_location_id = l.c_location_id
          left join c_country c
             on l.c_country_id = c.c_country_id
   where  pl.isactive = 'Y'
   and    l.isactive = 'Y'
   and    nvl (length (l.address1), 0) > 4;

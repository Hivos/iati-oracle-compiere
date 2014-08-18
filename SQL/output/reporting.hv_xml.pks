-- This file is part of the IATI, partnerdump AFFM/Compiere project.
-- Copyright (C) 2014 Barry de Graaff <info@barrydegraaff.tk>, (C) 2012 Arthur Baan, (C) 2012 Fred Stoopendaal
--
-- This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

CREATE OR REPLACE PACKAGE REPORTING.hv_xml
is
   procedure iati_activities_xml;

   procedure gen_xml_sql (
      pv_object_name  varchar2
     ,pv_owner        varchar2 := user
   );

   procedure exec_xml_sql (pv_query_name varchar2);
   
   procedure partner_deletions;
end;
/

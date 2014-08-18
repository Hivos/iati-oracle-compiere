-- This file is part of the IATI, partnerdump AFFM/Compiere project.
-- Copyright (C) 2014 Barry de Graaff <info@barrydegraaff.tk>, (C) 2012 Arthur Baan, (C) 2012 Fred Stoopendaal
--
-- This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

--To run iati issue:
exec reporting.hv_xml.iati_activities_xml;
--Dumps xml to /home/oracle/iati-activities.xml

--Running partner dump will use Google for geocoding partner location, this may take a long time, you don't need this for iati. To run partner dump issue:
exec reporting.hv_partner_gis.prepare_locations;
select distinct lower(b.address1 || ', ' || b.city || ', ' || b.country) as address  from reporting.hv_xml_commitment a, reporting.hv_xml_bpartner_locations b where a.c_bpartner_id = b.c_bpartner_id and lower((b.address1 || ', ' || b.city || ', ' || b.country)) NOT IN (select lower(address) from reporting.hv_gis) UNION select name from c_country where isactive='Y' and lower((c_country.name)) NOT IN (select lower(address) from reporting.hv_gis);
exec reporting.hv_xml.exec_xml_sql('PARTNER');
exec reporting.hv_xml.partner_deletions;



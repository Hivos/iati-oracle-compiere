-- This file is part of the IATI, partnerdump AFFM/Compiere project.
-- Copyright (C) 2014 Barry de Graaff <info@barrydegraaff.tk>, (C) 2012 Arthur Baan, (C) 2012 Fred Stoopendaal
--
-- This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

CREATE or replace VIEW reporting.HV_ORG_QVW AS 
select ad_client.ad_client_id,ad_client.name as ad_client_name,
       ad_org.ad_org_id,ad_org.NAME AS ad_org_name,
       afgo_program.afgo_program_id, afgo_program.afgo_projectcluster_id,afgo_program.description AS afgo_program_description,afgo_program.NAME AS afgo_program_name,
       a.name as program_manager_name, a.description as program_manager_description,
       CASE WHEN afgo_program.name like '%RO%' THEN 'Director Regional Office'
       WHEN afgo_program.name like  '%LO%' THEN 'Director Local Office'
       ELSE 'Head of Bureau'
       END AS title,       
       b.name as secretary_name, b.description as secretary_description, b.email as secretary_email
       FROM ad_client                                                       --Client
LEFT OUTER JOIN ad_org ON ad_client.ad_client_id = ad_org.ad_client_id      --Organisation
LEFT OUTER JOIN afgo_program ON ad_org.ad_org_id = afgo_program.ad_org_id   --Organisation unit
left outer join ad_user a on  afgo_program.programmanager_id = a.ad_user_id
left outer join ad_user b on  afgo_program.PROGRAMSECRETARY_ID = b.ad_user_id
where ad_client.ad_client_id = '1000000';

--grant select on reporting.HV_ORG_QVW to REPORTING.


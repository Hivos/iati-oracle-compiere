-- This file is part of the IATI, partnerdump AFFM/Compiere project.
-- Copyright (C) 2014 Barry de Graaff <info@barrydegraaff.tk>, (C) 2012 Arthur Baan, (C) 2012 Fred Stoopendaal
--
-- This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

create or replace force view reporting.hv_xml_commitment_line (
   afgo_commitment_id
  ,resultarea
  ,project
  ,projectcluster
  ,year
)
as
   select cl.afgo_commitment_id
         ,st.name resultarea
         ,p.name project
         ,pc.name projectcluster
         ,y.name "YEAR"
   from   afgo_commitmentline cl
          left outer join afgo_rv_servicetype st
             on cl.afgo_servicetype_id = st.afgo_servicetype_id
          left outer join afgo_project p
             on cl.afgo_project_id = p.afgo_project_id
          left outer join afgo_projectcluster pc
             on cl.afgo_projectcluster_id = pc.afgo_projectcluster_id
          left outer join afgo_year y
             on cl.afgo_year_id = y.afgo_year_id;

-- This file is part of the IATI, partnerdump AFFM/Compiere project.
-- Copyright (C) 2014 Barry de Graaff <info@barrydegraaff.tk>, (C) 2012 Arthur Baan, (C) 2012 Fred Stoopendaal
--
-- This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

-- BF 20120919 dacsectordescription read from osiris instead of motiv hardcode
-- 3 digit code instead of 5 digid code e.g. 111 121

create or replace force view reporting.hv_activities_sector (
   afgo_commitment_id
  ,sectorcode
  ,percentage
  ,dacsectordescription
)
as
   select si.afgo_commitment_id
         ,decode (
             ci.afgo_criterium_id
            ,1000219, 111
            ,1000220, 121
            ,1000221, 140
            ,1000222, 151
            ,1000223, 160
            ,1000224, 210
            ,1000225, 230
            ,1000226, 240
            ,1000227, 321
            ,1000228, 250
            ,1000229, 311
            ,1000230, 312
            ,1000231, 313
            ,1000232, 720
          )
             sectorcode
         ,al.integerscore percentage
         ,replace( ci.help, chr(10), '') dacsectordescription
   from   compiere.afgo_assessment a
          inner join compiere.afgo_scheduleitem si
             on a.afgo_scheduleitem_id = si.afgo_scheduleitem_id
          inner join compiere.afgo_assessmentline al
             on al.afgo_assessment_id = a.afgo_assessment_id
          inner join compiere.afgo_criterium ci
             on ci.afgo_criterium_id = al.afgo_criterium_id
   where  afgo_scheduleitemtype_id = 1000010
   and    ci.afgo_criterium_id between 1000219 and 1000232
   and    integerscore <> 0;

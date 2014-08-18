-- This file is part of the IATI, partnerdump AFFM/Compiere project.
-- Copyright (C) 2014 Barry de Graaff <info@barrydegraaff.tk>, (C) 2012 Arthur Baan, (C) 2012 Fred Stoopendaal
--
-- This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

  CREATE TABLE "REPORTING"."HV_GIS" 
   (	"ADDRESS" VARCHAR2(120 BYTE), 
	"UPDATED" DATE, 
	"COORDS" VARCHAR2(120 BYTE)
   );

  CREATE UNIQUE INDEX "REPORTING"."HV_GIS_PK" ON "REPORTING"."HV_GIS" ("ADDRESS");

  ALTER TABLE "REPORTING"."HV_GIS" ADD CONSTRAINT "HV_GIS_PK" PRIMARY KEY ("ADDRESS") ENABLE;
  ALTER TABLE "REPORTING"."HV_GIS" MODIFY ("ADDRESS" NOT NULL ENABLE);

-----------------------------------------------------------------------------

  CREATE TABLE "REPORTING"."HV_PARTNER_CACHE" 
   (	"IDENTIFIERORID" VARCHAR2(80 BYTE)
   );

  CREATE UNIQUE INDEX "REPORTING"."PARTNER_CACHE_PK" ON "REPORTING"."HV_PARTNER_CACHE" ("IDENTIFIERORID");

  ALTER TABLE "REPORTING"."HV_PARTNER_CACHE" ADD CONSTRAINT "PARTNER_CACHE_PK" PRIMARY KEY ("IDENTIFIERORID") ENABLE;
  ALTER TABLE "REPORTING"."HV_PARTNER_CACHE" MODIFY ("IDENTIFIERORID" NOT NULL ENABLE);

-----------------------------------------------------------------------------

  CREATE TABLE "REPORTING"."HV_PARTNER_DELETIONS" 
   (	"IDENTIFIERORID" VARCHAR2(80 BYTE), 
	"DELETEWHEN0" NUMBER
   );

  CREATE UNIQUE INDEX "REPORTING"."HV_PARTNER_DELETIONS_PK" ON "REPORTING"."HV_PARTNER_DELETIONS" ("IDENTIFIERORID");

  ALTER TABLE "REPORTING"."HV_PARTNER_DELETIONS" ADD CONSTRAINT "HV_PARTNER_DELETIONS_PK" PRIMARY KEY ("IDENTIFIERORID") ENABLE;
  ALTER TABLE "REPORTING"."HV_PARTNER_DELETIONS" MODIFY ("IDENTIFIERORID" NOT NULL ENABLE);

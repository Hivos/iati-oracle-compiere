-- This file is part of the IATI, partnerdump AFFM/Compiere project.
-- Copyright (C) 2014 Barry de Graaff <info@barrydegraaff.tk>, (C) 2012 Arthur Baan, (C) 2012 Fred Stoopendaal
--
-- This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

-- A simple procedure that saves a query result as a file.
-- Arguments : sql query, directory object, filename
-- Example   : EXEC reporting.hv_qry2xml('select * from afgo_assessment','HV_XMLDIR','test3.xml');

--/u01/app/oracle/product/11.2.0/xe/bin/sqlplus sys/PASSWD@reporting as sysdba
--grant execute on DBMS_XMLGEN to reporting.

CREATE OR REPLACE PROCEDURE reporting.hv_qry2xml 
   (qry IN VARCHAR2, dir IN VARCHAR2, filename IN VARCHAR2) 
IS
   hv_qry2xml_error exception; 
   pragma exception_init(hv_qry2xml_error, -20010);
   ctx    dbms_xmlgen.ctxHandle;
BEGIN
   ctx := dbms_xmlgen.newContext(qry);
   DBMS_XSLPROCESSOR.clob2file (DBMS_XMLGEN.getxml (ctx), dir,filename);
   dbms_xmlgen.closeContext(ctx);
   EXCEPTION
      WHEN OTHERS then
      raise_application_error(-20010, 'reporting.qry2xml exception: '||SQLERRM);  
END hv_qry2xml;
/

grant execute on reporting.hv_qry2xml to reporting;

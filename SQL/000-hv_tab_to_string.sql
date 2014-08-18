-- This file is part of the IATI, partnerdump AFFM/Compiere project.
-- Copyright (C) 2014 Barry de Graaff <info@barrydegraaff.tk>, (C) 2012 Arthur Baan, (C) 2012 Fred Stoopendaal
--
-- This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

-- This function converts the result of collect() to a string.
-- Convert a column in multiple rows to a single row single column string. 
-- Basically a pivot() function for Oracle 10

-- Example use:
-- SELECT documentno, '380' as line, hv_tab_to_string(CAST(COLLECT(to_char(afgo_criterium_description)) AS hv_varchar2_tab)) AS score_display FROM hv_query_partner_capacity 
-- WHERE line > 370 AND line < 530 AND score_display = 'N'
-- GROUP BY documentno

-- See: http://www.oracle-base.com/articles/misc/StringAggregationTechniques.php


CREATE OR REPLACE TYPE reporting.hv_varchar2_tab AS TABLE OF VARCHAR2(4000);
/
CREATE OR REPLACE FUNCTION reporting.hv_tab_to_string (p_varchar2_tab  IN  hv_varchar2_tab,
                                          p_delimiter     IN  VARCHAR2 DEFAULT ',') RETURN VARCHAR2 IS  l_string VARCHAR2(32767);
BEGIN
  FOR i IN p_varchar2_tab.FIRST .. p_varchar2_tab.LAST LOOP
    IF i != p_varchar2_tab.FIRST THEN
      l_string := l_string || p_delimiter;
    END IF;
    l_string := l_string || p_varchar2_tab(i);
  END LOOP;
  RETURN l_string;
   EXCEPTION
      WHEN OTHERS then      
      return null;   
END hv_tab_to_string;
/

GRANT EXECUTE ON reporting.hv_varchar2_tab TO reporting;
GRANT EXECUTE ON reporting.hv_tab_to_string TO reporting;



-- This file is part of the IATI, partnerdump AFFM/Compiere project.
-- Copyright (C) 2014 Barry de Graaff <info@barrydegraaff.tk>, (C) 2012 Arthur Baan, (C) 2012 Fred Stoopendaal
--
-- This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

-- 20120918 barry distinct keyword added to prevent dupes (astolp bug docno 1001568)

create or replace force view reporting.hv_xml_ass_criteria (
   afgo_commitment_id
  ,afgo_criterium_name
  ,score_display
  ,help
)
as
   select distinct afgo_commitment_id
         ,afgo_criterium_name
         ,score_display
         ,rtrim (help, chr (10)) help
   from   (select   afgo_commitment.afgo_commitment_id
                   ,afgo_criterium.name as afgo_criterium_name
                   ,nvl (
                       substr (
                             to_char (substr (afgo_assessmentline.textscore, 0, 2000))
                          || afgo_assessmentline.numericscore
                          || afgo_assessmentline.integerscore
                          || afgo_assessmentline.booleanscore
                          || ad_ref_list.name
                         ,0
                         ,2000
                       )
                      ,'none'
                    )
                       as score_display
                   ,afgo_criterium.help
           from     afgo_commitment
                    left outer join c_bpartner
                       on afgo_commitment.c_bpartner_id = c_bpartner.c_bpartner_id
                    left outer join afgo_scheduleitem
                       on afgo_commitment.afgo_commitment_id = afgo_scheduleitem.afgo_commitment_id
                    left outer join afgo_assessment
                       on afgo_scheduleitem.afgo_scheduleitem_id = afgo_assessment.afgo_scheduleitem_id
                    left outer join ad_user ad_user_b
                       on afgo_assessment.salesrep_id = ad_user_b.ad_user_id
                    left outer join afgo_assessmentline
                       on afgo_assessment.afgo_assessment_id = afgo_assessmentline.afgo_assessment_id
                    left outer join afgo_criterium
                       on afgo_assessmentline.afgo_criterium_id = afgo_criterium.afgo_criterium_id
                    left outer join ad_ref_list
                       on afgo_assessmentline.listscore_id = ad_ref_list.ad_ref_list_id
                    left outer join c_currency
                       on afgo_commitment.c_currency_id = c_currency.c_currency_id
                    left outer join reporting.hv_org_qvw
                       on hv_org_qvw.afgo_program_id = afgo_commitment.afgo_program_id
                    left outer join ad_user
                       on afgo_commitment.salesrep_id = ad_user.ad_user_id
                    left outer join afgo_fundallocation
                       on afgo_commitment.afgo_commitment_id = afgo_fundallocation.afgo_commitment_id
                    left outer join afgo_fund
                       on afgo_fundallocation.afgo_fund_id = afgo_fund.afgo_fund_id
                    left outer join c_doctype
                       on afgo_fund.c_doctype_id = c_doctype.c_doctype_id
           where    afgo_scheduleitem.afgo_scheduleitemtype_id = '1000010' -- alleencontract intake schedule item type
           and      afgo_commitment.c_doctype_id = '1000104' --Alleen master contract
           and      (afgo_criterium.name like 'GE keyword%'
           or         afgo_criterium.name like 'E' || '&' || 'E keyword%'
           or         afgo_criterium.name like 'E' || '&' || 'E specific groups%'
           or         afgo_criterium.name like 'R' || '&' || 'C specific groups%'
           or         afgo_criterium.name like 'R' || '&' || 'C keywords%')
           and      afgo_commitment.docstatus = 'CO'
           and      afgo_fundallocation.c_invoiceline_id is null
           order by afgo_commitment.documentno
                   ,afgo_fundallocation_id
                   ,afgo_assessmentline.line)
   where  score_display = 'Y';

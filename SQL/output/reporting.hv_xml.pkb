-- This file is part of the IATI, partnerdump AFFM/Compiere project.
-- Copyright (C) 2014 Barry de Graaff <info@barrydegraaff.tk>, (C) 2012 Arthur Baan, (C) 2012 Fred Stoopendaal
--
-- This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

-- BF modified: 
-- Barry, fixed dupes because of MAILINGADDRESS, rows are comma seperated, see in line comment
-- Barry 20120919  vocabulary="DAC-3" instead of DAC

CREATE OR REPLACE PACKAGE BODY REPORTING.hv_xml
is
   procedure clobtofile (
      p_filename in varchar2
     ,p_dir      in varchar2
     ,p_clob     in clob
   )
   is
      c_amount constant binary_integer := 8000;
      l_buffer          varchar2 (32767);
      l_chr10           pls_integer;
      l_cloblen         pls_integer;
      l_fhandler        utl_file.file_type;
      l_pos             pls_integer := 1;
   begin
      l_cloblen  := dbms_lob.getlength (p_clob);
      l_fhandler := utl_file.fopen (p_dir, p_filename, 'W', c_amount * 2);
      while l_pos < l_cloblen
      loop
         l_buffer := dbms_lob.substr (p_clob, c_amount, l_pos);
         exit when l_buffer is null;
         l_chr10  := instr (l_buffer, chr (10), -1);
         if l_chr10 = 0
         then
		    if length (l_buffer) = c_amount
			then
               l_chr10  := instr (l_buffer, '><', -1);
               if l_chr10 = 0
               then
			      raise_application_error(-20101,'geen mogenlijkheid gevonden om de regel te splitsen');
			   else
                  l_buffer := substr (l_buffer, 1, l_chr10);
			   end if;
			end if;
            l_pos    := l_pos + length (l_buffer);
		 else
            l_buffer := substr (l_buffer, 1, l_chr10 - 1);
            l_pos    := l_pos + length (l_buffer) + 1;
         end if;
         utl_file.put_line (l_fhandler, l_buffer, true);
      end loop;
      utl_file.fclose (l_fhandler);
   exception
      when others
      then
         if utl_file.is_open (l_fhandler)
         then
            utl_file.fclose (l_fhandler);
         end if;
         raise;
   end clobtofile;

   procedure gen_xml_sql (
      pv_object_name  varchar2
     ,pv_owner        varchar2 := user
   )
   is
      lv_sql varchar2 (32767);
   begin
      lv_sql := lv_sql || 'select xmlelement("root",xmlagg(xmlelement("' || lower (pv_object_name) || '"';
      for tr_rec in (select   *
                     from     all_tab_columns
                     where    owner = upper (pv_owner)
                     and      table_name = upper (pv_object_name)
                     order by column_id)
      loop
         lv_sql := lv_sql || ',xmlelement("' || lower (tr_rec.column_name) || '",' || tr_rec.column_name || ')';
      end loop;
      lv_sql := lv_sql || '))).extract(''/'').getclobval() xml from ' || case when pv_owner <> user then pv_owner || '.' end || pv_object_name;
      dbms_output.put_line (lv_sql);
   end gen_xml_sql;

   procedure exec_xml_sql (pv_query_name varchar2)
   is
      cursor lc_xml (bv_query_name varchar2)
      is
select 'PARTNER' as NAME, 'partner.xml' AS FILE_NAME, 'xml voor alle partners met een commitment' AS DESCRIPTION, 'select xmlelement("Hivos", xmlagg(xmlelement("hv_xml_commitment", xmlelement("afgo_commitment_id",AFGO_COMMITMENT_ID), xmlelement("confidentialitystatus",CONFIDENTIALITYSTATUS), xmlelement("c_bpartner_id",C_BPARTNER_ID), xmlelement("identifier",IDENTIFIER), xmlelement("title",TITLE) , xmlelement("actualstart",ACTUALSTART), xmlelement("actualend",ACTUALEND), xmlelement("telephone",TELEPHONE) , xmlelement("currency",CURRENCY), xmlelement("countrycode",COUNTRYCODE), xmlelement("countryname",COUNTRYNAME), xmlelement("coordinates",reporting.hv_partner_gis.geocode(COUNTRYNAME)), xmlelement("region",REGION), xmlelement("documentno",DOCUMENTNO), xmlelement("grandtotal",GRANDTOTAL), xmlelement("updated",UPDATED), xmlelement("dateacct",DATEACCT), 
(select xmlagg(
xmlelement("commitment_funding",
xmlelement("sum_fund_allocation",SUM_FUND_ALLOCATION),
xmlelement("iso_code",ISO_CODE),
xmlelement("fundprovidername",FUNDPROVIDERNAME),
xmlelement("afgo_fundprovider_id",afgo_fundprovider_id)
)) from reporting.hv_xml_commitment_funding where 
reporting.hv_xml_commitment_funding.afgo_commitment_id = c.afgo_commitment_id and
reporting.hv_xml_commitment_funding.sum_fund_allocation <> ''0''), 

(select xmlagg(xmlelement("hv_xml_transactions",xmlelement("receiver",RECEIVER),xmlelement("amount",AMOUNT),xmlelement("transactiondate",TRANSACTIONDATE),xmlelement("currency",CURRENCY),xmlelement("provider",PROVIDER),xmlelement("afgo_fundprovider_id",afgo_fundprovider_id)))from reporting.hv_iati_transactions t where t.afgo_commitment_id = c.afgo_commitment_id), 

(select xmlagg(xmlelement("hv_xml_bpartner",xmlelement("organisation",ORGANISATION),xmlelement("ad_client_id",AD_CLIENT_ID),xmlelement("c_bpartner_id",C_BPARTNER_ID),xmlelement("firstsale",FIRSTSALE),xmlelement("datefounded",to_char(DATEFOUNDED,''YYYY'')),xmlelement("Searchkey",Searchkey),xmlelement("confidentialitystatus",CONFIDENTIALITYSTATUS),xmlelement("url",URL),xmlelement("legalentitytype",LEGALENTITYTYPE),

(select  xmlagg(xmlelement("hv_xml_bpartner_location",xmlelement("address",ADDRESS),xmlelement("postal",POSTAL),xmlelement("city",CITY),xmlelement("countrycode",COUNTRYCODE),xmlelement("country",COUNTRY),xmlelement("coordinates",reporting.hv_partner_gis.geocode(ADDRESS1 || '', '' || CITY || '', '' || COUNTRY)))) from reporting.hv_xml_bpartner_locations bl where bl.c_bpartner_id = bp.c_bpartner_id )))  from reporting.hv_xml_bpartner bp where C.C_BPARTNER_ID = BP.C_BPARTNER_ID ), 

(select xmlagg ( xmlelement ( "hv_xml_ass_criteria" ,xmlelement ("afgo_criterium_name", afgo_criterium_name) ,xmlelement ("help", help) ) ) from reporting.hv_xml_ass_criteria a where a.afgo_commitment_id = c.afgo_commitment_id), 

(select xmlagg ( xmlelement ( "hv_xml_commitment_line" ,xmlelement ("resultarea", resultarea) ,xmlelement ("project", project) ,xmlelement ("projectcluster", projectcluster) ,xmlelement ("year", year) ) ) from reporting.hv_xml_commitment_line cl where cl.afgo_commitment_id = c.afgo_commitment_id) ,xmlelement("program_name",PROGRAM_NAME)))).extract(''/'').getclobval() xml from reporting.hv_xml_commitment c where
afgo_commitmentprocedure_id in (select afgo_commitmentprocedure_id from afgo_commitmentprocedure where isactive = ''Y'' and name not like ''KMP%''  and name not like ''HO BER s%''  and name not like ''Consul%'' and name not like ''MFI%'' and created < to_date(''2012/10/10'', ''yyyy/mm/dd''))
' AS XML_SELECT FROM DUAL;

      --
      lr_xml lc_xml%rowtype;
      ll_xml clob;
   begin
      dbms_lob.createtemporary (ll_xml, true, dbms_lob.session);
      --
      open lc_xml (pv_query_name);
      fetch lc_xml into lr_xml;
      close lc_xml;
      --
      execute immediate dbms_lob.substr (lr_xml.xml_select, 32767, 1) into ll_xml;
      --
      clobtofile (lr_xml.file_name, 'HV_XMLDIR', '<?xml version="1.0"?>' ||  chr(10) || ll_xml);
   end exec_xml_sql;

   procedure iati_activities_xml
   is
      ll_xml clob;

      -- lt_xml           xmltype;
      -- li_commitment_id integer := 1001400;
      -- li_commitment_id integer := 1001815;
      procedure pl (pl_text clob)
      is
      begin
         dbms_lob.append (ll_xml, dbms_xmlgen.convert (pl_text, dbms_xmlgen.entity_encode));
      exception
         when others then
            dbms_lob.writeappend (ll_xml, 9, '<![CDATA[');
            dbms_lob.append (ll_xml, pl_text);
            dbms_lob.writeappend (ll_xml, 4, ']]>' || chr (10));
      end;

      procedure p (lv_regel varchar2)
      is
      begin
         -- dbms_output.put_line (lv_regel);
         dbms_lob.writeappend (ll_xml, length (lv_regel) + 1, lv_regel || chr (10));
      end;

      function cd (lv_regel varchar2)
         return varchar2
      is
      begin
         return dbms_xmlgen.convert (lv_regel, dbms_xmlgen.entity_encode);
      exception
         when others then
            return '<![CDATA[' || lv_regel || ']]>';
      end;

      function cdata (lv_regel varchar2)
         return varchar2
      is
      begin
         return '<![CDATA[' || lv_regel || ']]>';
      end;
   begin
      dbms_lob.createtemporary (ll_xml, true, dbms_lob.session);
      p ('<?xml version="1.0" encoding="utf-8"?>');
      p (
            '<iati-activities' --|| ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
                               --|| ' xsi:noNamespaceSchemaLocation="http://iatistandard.org/downloads/iati-activities-schema.xsd"'
         || ' version="1.01" generated-datetime="'
         || replace (to_char (sysdate, 'yyyy-mm-dd hh24:mi:ss'), ' ', 'T')
         || '">'
      );
      --for tr_act in (select *
      --               from   hv_iati_activities
      --               where  mastercommitment_id is null -- and    afgo_commitment_id = li_commitment_id
      --                                                 )
      
      --Barry, fixed dupes because of MAILINGADDRESS, rows are comma seperated, order by added
      for tr_act in (select 
                    AFGO_COMMITMENT_ID,MASTERCOMMITMENT_ID,IDENTIFIER,TITLE,ACTUALSTART,ACTUALEND,ORGANISATION,PERSONNAME,TELEPHONE,EMAIL,
                    reporting.hv_tab_to_string(CAST(COLLECT(to_char(MAILINGADDRESS)) AS reporting.hv_varchar2_tab)) AS MAILINGADDRESS,PARTNER,CURRENCY,RECIPIENTCOUNTRYCODE,RECIPIENTCOUNTRY,HIERARCHY,DOCUMENTNO,GRANDTOTAL,UPDATED,DATEACCT,PROGRAM_NAME
                    from   reporting.hv_iati_activities
                    where  mastercommitment_id is null 
                    group by AFGO_COMMITMENT_ID,MASTERCOMMITMENT_ID,IDENTIFIER,TITLE,ACTUALSTART,ACTUALEND,ORGANISATION,PERSONNAME,TELEPHONE,EMAIL,PARTNER,CURRENCY,RECIPIENTCOUNTRYCODE,RECIPIENTCOUNTRY,HIERARCHY,DOCUMENTNO,GRANDTOTAL,UPDATED,DATEACCT,PROGRAM_NAME 
                    order by 1 desc     
      )
      
      loop
         p (
               '<iati-activity xml:lang="en" hierarchy="1" default-currency="'
            || nvl(tr_act.currency,'EUR')
            || '" last-updated-datetime="'
            || replace (to_char (nvl(tr_act.updated,sysdate), 'yyyy-mm-dd hh24:mi:ss'), ' ', 'T')
            || '">'
         );
         --
         p ('<reporting-org type="22" ref="NL-KVK-41198677">HIVOS</reporting-org>');
         p ('<iati-identifier>' || tr_act.identifier || '</iati-identifier>');
         -- p ('<other-identifier></other-identifier>');
         p ('<title>' || cd (tr_act.title) || '</title>');
         for tr_des in (select *
                        from   hv_iati_activity_description
                        where  afgo_commitment_id = tr_act.afgo_commitment_id)
         loop
            if tr_des.description is not null
            then
               p ('<description>');
               pl (tr_des.description);
               p ('</description>');
            end if;
         end loop;
         p ('<activity-status code="2">Implementation</activity-status>');
         p ('<activity-date type="start-actual" iso-date="' || to_char (nvl(tr_act.actualstart,sysdate), 'yyyy-mm-dd') || '"></activity-date>');
         p ('<activity-date type="end-actual" iso-date="' || to_char (nvl(tr_act.actualend,sysdate), 'yyyy-mm-dd') || '"></activity-date>');
         --
         p ('<contact-info>');
         --
         p ('<organisation>' || cd (tr_act.organisation) || '</organisation>');
         -- p ('<person-name>' || cd (tr_act.personname) || '</person-name>');
         p ('<telephone>' || cd (tr_act.telephone) || '</telephone>');
         --p ('<email>' || cd (tr_act.email) || '</email>');
         p ('<mailing-address>' || cd (tr_act.mailingaddress) || '</mailing-address>');
         --
         p ('</contact-info>');
         p (
               '<participating-org xml:lang="en" role="'
            || case when tr_act.partner = 'Y' then 'Implementing' else 'Funding' end
            || '">'
            || cd (tr_act.organisation)
            || '</participating-org>'
         );
         p ('<recipient-country code="' || tr_act.recipientcountrycode || '">' || cd (tr_act.recipientcountry) || '</recipient-country>');
         -- p ('<recipient-region></recipient-region>');
         -- p ('<location>');
         -- p ('<location_type></location_type>');
         -- p ('<name></name>');
         -- p ('<administrative></administrative>');
         -- p ('<coordinates></coordinates>');
         -- p ('<gazetteer-entry></gazetteer-entry>');
         -- p ('</location>');
         for tr_sec in (select *
                        from   hv_activities_sector
                        where  afgo_commitment_id = tr_act.afgo_commitment_id)
         loop
            p (
                  '<sector code="'
               || tr_sec.sectorcode
               || '" percentage="'
               || tr_sec.percentage
               || '" vocabulary="DAC-3">'
               || cd (tr_sec.dacsectordescription)
               || '</sector>'
            );
         end loop;
         p ('<policy-marker></policy-marker>'); -- NOG VULLEN
         -- p ('<collaboration-type></collaboration-type>');
         -- p ('<default-flow-type></default-flow-type>');
         -- p ('<default-finance-type></default-finance-type>');
         -- p ('<default-aid-type></default-aid-type>');
         -- p ('<default-tied-status></default-tied-status>');
         -- p ('<budget>');
         -- p ('<period-start></period-start>');
         -- p ('<period-end></period-end>');
         -- p ('</budget>');
         -- p ('<planned-disbursement>');
         -- p ('<period-start></period-start>');
         -- p ('<period-end></period-end>');
		 if tr_act.grandtotal is not null
		 then
            p (
                  '<budget><value value-date="'
               || to_char (tr_act.dateacct, 'yyyy-mm-dd')
               || '" currency="'
               || tr_act.currency
               || '">'
               || round (tr_act.grandtotal)
               || '</value></budget>'
            );
		 end if;
         -- p ('</planned-disbursement>');
         --
         for tr_tra in (select *
                        from   hv_iati_transactions
                        where  afgo_commitment_id = tr_act.afgo_commitment_id)
         loop
            p ('<transaction>');
            p ('<transaction-type code="D">Disbursement</transaction-type>');
            p ('<provider-org>' || cd (tr_tra.provider) || '</provider-org>');
            p ('<receiver-org>' || cd (tr_tra.receiver) || '</receiver-org>');
            p (
                  '<value value-date="'
               || to_char (tr_tra.transactiondate, 'yyyy-mm-dd')
               || '" currency="'
               || tr_tra.currency
               || '">'
               || round (tr_tra.amount)
               || '</value>'
            );
            -- p ('<description></description>');
            p ('<transaction-date iso-date="' || to_char (tr_tra.transactiondate, 'yyyy-mm-dd') || '"></transaction-date>');
            -- p ('<flow-type></flow-type>');
            -- p ('<finance-type></finance-type>');
            -- p ('<aid-type></aid-type>');
            -- p ('<disbursement-channel></disbursement-channel>');
            -- p ('<tied-status></tied-status>');
            p ('</transaction>');
         end loop;
         -- p ('<document-link>');
         -- p ('<language></language>');
         -- p ('<category></category>');
         -- p ('<title></title>');
         -- p ('</document-link>');
         -- p ('<activity-website></activity-website>');
         for tr_rel in (select *
                        from   hv_iati_activities
                        where  mastercommitment_id = tr_act.afgo_commitment_id)
         loop
            p ('<related-activity type="2" ref="' || tr_rel.identifier || '">' || cd (tr_rel.title) || '</related-activity>');
         end loop;
         -- p ('<conditions>');
         -- p ('<condition></condition>');
         -- p ('</conditions>');
         -- p ('<result>');
         -- p ('<title></title>');
         -- p ('<description></description>');
         -- p ('<indicator>');
         -- p ('<title></title>');
         -- p ('<description></description>');
         -- p ('<baseline>');
         -- p ('<comment></comment>');
         -- p ('</baseline>');
         -- p ('<period>');
         -- p ('<period-start></period-start>');
         -- p ('<period-end></period-end>');
         -- p ('<target>');
         -- p ('<comment></comment>');
         -- p ('</target>');
         -- p ('<actual>');
         -- p ('<comment></comment>');
         -- p ('</actual>');
         -- p ('</period>');
         -- p ('</indicator>');
         -- p ('</result>');
         p ('</iati-activity>');
      end loop;
      p ('</iati-activities>');
      clobtofile ('iati-activities.xml', 'HV_XMLDIR', ll_xml);
   end iati_activities_xml;

   procedure partner_deletions
   is
   begin

      --find all contracts and partners that must be deleted
      for n in (  select IDENTIFIERORID from REPORTING.HV_PARTNER_CACHE where IDENTIFIERORID NOT IN (
                     select distinct to_char(c_bpartner_id) AS IDENTIFIERORID from reporting.hv_xml_commitment
                     union 
                     select to_char(identifier) from reporting.hv_xml_commitment
                  )
               )                     
      loop
         begin
            INSERT INTO REPORTING.HV_PARTNER_DELETIONS VALUES (n.IDENTIFIERORID, 360); 
         exception
         when DUP_VAL_ON_INDEX then
            NULL;
         end;   
      end loop;     
      commit;
      
      reporting.hv_qry2xml('select IDENTIFIERORID from REPORTING.HV_PARTNER_DELETIONS union select '''' from dual ','HV_XMLDIR','hv_partner_deletions.xml');
      
      UPDATE REPORTING.HV_PARTNER_DELETIONS SET DELETEWHEN0 = DELETEWHEN0 -1;
      DELETE FROM REPORTING.HV_PARTNER_CACHE WHERE IDENTIFIERORID IN (SELECT IDENTIFIERORID FROM REPORTING.HV_PARTNER_DELETIONS WHERE DELETEWHEN0 = 0);
      DELETE FROM REPORTING.HV_PARTNER_DELETIONS WHERE DELETEWHEN0 = 0;
      commit;

      --put all the contracts and partner from runtime in a cache table for future use
      for t in (  select distinct to_char(c_bpartner_id) AS IDENTIFIERORID from reporting.hv_xml_commitment
                  union 
                  select to_char(identifier) from reporting.hv_xml_commitment
               )                     
      loop
         begin
            INSERT INTO REPORTING.HV_PARTNER_CACHE VALUES (t.IDENTIFIERORID); 
         exception
         when DUP_VAL_ON_INDEX then
            NULL;
         end;   
      end loop;     
      commit;
            
   end partner_deletions;

end hv_xml; 
/


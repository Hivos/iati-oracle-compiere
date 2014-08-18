-- This file is part of the IATI, partnerdump AFFM/Compiere project.
-- Copyright (C) 2013 ActFact Projects
--
-- This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.


-- The following script assumes you have an Oracle 11 (XE) database with a compiere schema (user) that holds a copy of your AFFM/Compiere production data.
-- DO NOT RUN THIS SCRIPT IN YOUR PRODUCTION DATABASE AS IT WILL ALTER YOUR DATA!!


SET SERVEROUTPUT ON SIZE 500000;

CREATE USER REPORTING IDENTIFIED BY your-password-here;

DECLARE
 CURSOR s_cur IS
 SELECT synonym_name FROM ALL_synonyms where owner = 'REPORTING';

 RetVal  NUMBER;
 sqlstr  VARCHAR2(200); 
BEGIN
  FOR s_rec IN s_cur LOOP
    sqlstr := 'DROP SYNONYM REPORTING.' || s_rec.synonym_name;

    EXECUTE IMMEDIATE sqlstr;
  END LOOP; 
END;
/

--(Re-)create all synonyms in REPORTING schema
SET SERVEROUTPUT ON SIZE 500000;
DECLARE
	query		VARCHAR2(2000);
	counter		NUMBER		:= 0;

	CURSOR CUR_TableNames IS
  SELECT table_name  AS TableName
  FROM    all_tables 
  WHERE   owner = 'COMPIERE';
  
BEGIN

	EXECUTE IMMEDIATE 'GRANT CONNECT TO REPORTING';
	EXECUTE IMMEDIATE 'GRANT RESOURCE TO REPORTING';


	FOR t IN CUR_TableNames LOOP
		query := 'GRANT SELECT ON ' || t.TableName || ' TO REPORTING';
		BEGIN
			EXECUTE IMMEDIATE query;
			EXCEPTION WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE('Could not grant ''select'' to table ' || t.TableName);
		END;	

		query := 'CREATE SYNONYM REPORTING.' || t.TableName || ' FOR ' || t.TableName;    
		BEGIN
			EXECUTE IMMEDIATE query;
			EXCEPTION WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE('Could not create synonym ' || t.TableName || ' CREATE SYNONYM REPORTING.' || t.TableName || ' FOR ' || t.TableName);
		END;
	END LOOP;
END;
/

COMMIT;


CREATE VIEW AFGO_RV_SERVICETYPE AS
SELECT ci.AD_Client_ID          AS AD_Client_ID,
  CASE
    WHEN st.AD_Client_ID=ci.AD_Client_ID
    THEN st.AD_Org_ID
    ELSE 0
  END                                           AS AD_Org_ID,
  st.AFGO_Program_ID                            AS AFGO_Program_ID,
  st.IsActive                                   AS IsActive,
  st.Created                                    AS Created,
  st.CreatedBy                                  AS CreatedBy,
  st.Updated                                    AS Updated,
  st.UpdatedBy                                  AS UpdatedBy,
  SUBSTR(SYS_CONNECT_BY_PATH(st.Name, '->'), 3) AS Name,
  st.Description                                AS Description,
  st.AFGO_ServiceType_ID                        AS AFGO_ServiceType_ID,
  st.IsSummary                                  AS IsSummary
FROM AD_TreeNode tn
INNER JOIN AD_Tree tr
ON (tr.AD_Tree_ID=tn.AD_Tree_ID)
INNER JOIN AD_ClientInfo ci
ON (ci.AD_Tree_ServiceType_ID=tr.AD_Tree_ID)
INNER JOIN AFGO_ServiceType st
ON (st.AFGO_ServiceType_ID=tn.Node_ID)
  START WITH
  (
    tn.Parent_ID IS NULL
  OR tn.Parent_ID =0
  )
  CONNECT BY PRIOR tn.Node_ID=tn.Parent_ID
AND PRIOR tn.AD_Tree_ID      =tn.AD_Tree_ID
ORDER SIBLINGS BY tn.SeqNo;


GRANT SELECT ON AFGO_RV_SERVICETYPE TO REPORTING;
CREATE SYNONYM REPORTING.AFGO_RV_SERVICETYPE FOR AFGO_RV_SERVICETYPE;


CREATE VIEW RV_FACT_ACCT          AS
SELECT f.AD_Client_ID             AS AD_Client_ID,
  f.AD_Org_ID                     AS AD_Org_ID,
  f.IsActive                      AS IsActive,
  f.Created                       AS Created,
  f.CreatedBy                     AS CreatedBy,
  f.Updated                       AS Updated,
  f.UpdatedBy                     AS UpdatedBy,
  f.Fact_Acct_ID                  AS Fact_Acct_ID,
  f.C_AcctSchema_ID               AS C_AcctSchema_ID,
  f.Account_ID                    AS Account_ID,
  f.DateTrx                       AS DateTrx,
  f.DateAcct                      AS DateAcct,
  f.C_Period_ID                   AS C_Period_ID,
  f.AD_Table_ID                   AS AD_Table_ID,
  f.Record_ID                     AS Record_ID,
  f.Line_ID                       AS Line_ID,
  f.GL_Category_ID                AS GL_Category_ID,
  f.GL_Budget_ID                  AS GL_Budget_ID,
  f.C_Tax_ID                      AS C_Tax_ID,
  f.M_Locator_ID                  AS M_Locator_ID,
  f.PostingType                   AS PostingType,
  f.C_Currency_ID                 AS C_Currency_ID,
  f.AmtSourceDr                   AS AmtSourceDr,
  f.AmtSourceCr                   AS AmtSourceCr,
  (f.AmtSourceDr - f.AmtSourceCr) AS AmtSource,
  f.AmtAcctDr                     AS AmtAcctDr,
  f.AmtAcctCr                     AS AmtAcctCr,
  (f.AmtAcctDr - f.AmtAcctCr)     AS AmtAcct,
  CASE
    WHEN (f.AmtSourceDr - f.AmtSourceCr) = 0
    THEN 0
    ELSE (f.AmtAcctDr - f.AmtAcctCr) / (f.AmtSourceDr - f.AmtSourceCr)
  END                     AS Rate,
  f.C_UOM_ID              AS C_UOM_ID,
  f.Qty                   AS Qty,
  f.M_Product_ID          AS M_Product_ID,
  f.C_BPartner_ID         AS C_BPartner_ID,
  f.AD_OrgTrx_ID          AS AD_OrgTrx_ID,
  f.C_LocFrom_ID          AS C_LocFrom_ID,
  f.C_LocTo_ID            AS C_LocTo_ID,
  f.C_SalesRegion_ID      AS C_SalesRegion_ID,
  f.C_Project_ID          AS C_Project_ID,
  f.C_Campaign_ID         AS C_Campaign_ID,
  f.C_Activity_ID         AS C_Activity_ID,
  f.User1_ID              AS User1_ID,
  f.User2_ID              AS User2_ID,
  f.A_Asset_ID            AS A_Asset_ID,
  f.Description           AS Description,
  o.Value                 AS OrgValue,
  o.Name                  AS OrgName,
  ev.Value                AS AccountValue,
  ev.Name                 AS Name,
  ev.AccountType          AS AccountType,
  bp.Value                AS BPartnerValue,
  bp.Name                 AS BPName,
  bp.C_BP_Group_ID        AS C_BP_Group_ID,
  p.Value                 AS ProductValue,
  p.Name                  AS ProductName,
  p.UPC                   AS UPC,
  p.M_Product_Category_ID AS M_Product_Category_ID
FROM Fact_Acct f
INNER JOIN AD_Org o
ON (f.AD_Org_ID=o.AD_Org_ID)
INNER JOIN C_ElementValue ev
ON (f.Account_ID=ev.C_ElementValue_ID)
LEFT OUTER JOIN C_BPartner bp
ON (f.C_BPartner_ID=bp.C_BPartner_ID)
LEFT OUTER JOIN M_Product p
ON (f.M_Product_ID=p.M_Product_ID);

GRANT SELECT ON RV_FACT_ACCT TO REPORTING;
CREATE SYNONYM REPORTING.RV_FACT_ACCT FOR RV_FACT_ACCT;


CREATE VIEW AFGO_RV_COMMITMENTTYPE AS
SELECT
  CASE
    WHEN mpct.IsCommitmentAccounting IS NOT NULL
    THEN mpct.IsCommitmentAccounting
    ELSE pct.IsCommitmentAccounting
  END                   AS IsCommitmentAccounting,
  pc.Created            AS Created,
  pc.CreatedBy          AS CreatedBy,
  pc.Updated            AS Updated,
  pc.UpdatedBy          AS UpdatedBy,
  pc.AFGO_Commitment_ID AS AFGO_Commitment_ID,
  CASE
    WHEN mpct.IsPurchaseDomain IS NOT NULL
    THEN mpct.IsPurchaseDomain
    ELSE pct.IsPurchaseDomain
  END                        AS IsPurchaseDomain,
  pct.IsAdditionalCommitment AS IsAdditionalCommitment,
  pct.IsCanHaveAdditional    AS IsCanHaveAdditional,
  pct.IsCanTransfer          AS IsCanTransfer,
  pct.IsMasterCommitment     AS IsMasterCommitment,
  pct.IsQuotationRequired    AS IsQuotationRequired,
  pct.IsSecondmentCommitment AS IsSecondmentCommitment,
  pct.IsTransferCommitment   AS IsTransferCommitment,
  CASE
    WHEN pc.MasterCommitment_ID IS NULL
    THEN pc.GrandTotal
    WHEN pc.MasterCommitment_ID IS NOT NULL
    AND pc.DocStatus            IN ('CO', 'CL')
    THEN mpc.GrandTotal
    ELSE mpc.GrandTotal + pc.GrandTotal
  END             AS TargetTotal,
  pc.AD_Client_ID AS AD_Client_ID,
  pc.AD_Org_ID    AS AD_Org_ID,
  pc.IsActive     AS IsActive,
  CASE
    WHEN mpct.IsInternalCommitment IS NOT NULL
    THEN mpct.IsInternalCommitment
    ELSE pct.IsInternalCommitment
  END                          AS IsInternalCommitment,
  pct.IsOverheadCommitment     AS IsOverheadCommitment,
  pct.IsUseCommitmentProcedure AS IsUseCommitmentProcedure
FROM AFGO_Commitment pc
INNER JOIN C_DocType dt
ON (dt.C_DocType_ID=pc.C_DocType_ID)
INNER JOIN AFGO_CommitmentType pct
ON (pct.AFGO_CommitmentType_ID=dt.AFGO_CommitmentType_ID)
LEFT OUTER JOIN AFGO_Commitment mpc
ON (mpc.AFGO_Commitment_ID=pc.MasterCommitment_ID)
LEFT OUTER JOIN C_DocType mdt
ON (mdt.C_DocType_ID=mpc.C_DocType_ID)
LEFT OUTER JOIN AFGO_CommitmentType mpct
ON (mpct.AFGO_CommitmentType_ID=mdt.AFGO_CommitmentType_ID);

GRANT SELECT ON AFGO_RV_COMMITMENTTYPE TO REPORTING;
CREATE SYNONYM REPORTING.AFGO_RV_COMMITMENTTYPE FOR AFGO_RV_COMMITMENTTYPE;


CREATE VIEW "HIVO_RV_BP_LOCATION" ("UPDATED", "C_BPARTNER_ID", "ADDRESS1", "CREATED", "ISACTIVE", "AD_CLIENT_ID", "CREATEDBY", "AD_ORG_ID", "UPDATEDBY", "CITY", "COUNTRYNAME", "ISSHIPTO") AS SELECT bpl.Updated AS Updated, bpl.C_BPartner_ID AS C_BPartner_ID, l.Address1 AS Address1, bpl.Created AS Created, bpl.IsActive AS IsActive, bpl.AD_Client_ID AS AD_Client_ID, bpl.CreatedBy AS CreatedBy, bpl.AD_Org_ID AS AD_Org_ID, bpl.UpdatedBy AS UpdatedBy, l.City AS City, c.Name AS CountryName, bpl.IsShipTo AS IsShipTo FROM C_BPartner_Location bpl
LEFT JOIN C_Location l ON (bpl.C_Location_ID = l.C_Location_ID)
LEFT JOIN C_Country c ON (l.C_Country_ID = c.C_Country_ID);

grant select on HIVO_RV_BP_LOCATION to REPORTING;
CREATE SYNONYM REPORTING.HIVO_RV_BP_LOCATION FOR HIVO_RV_BP_LOCATION;


CREATE VIEW "HIVO_RV_BP_LOCATIONSTRING" ("C_BPARTNER_ID", "ADDRESS1", "CITY", "COUNTRYNAME", "AD_CLIENT_ID", "AD_ORG_ID", "CREATED", "CREATEDBY", "UPDATED", "UPDATEDBY", "ISACTIVE") AS SELECT bp.C_BPartner_ID AS C_BPartner_ID, (SELECT (l1.Address1 || '-' || l2.Address1 || '-' || l3.Address1 || '-' || l4.Address1) AS Address1
FROM C_BPartner_Location l
LEFT OUTER JOIN HIVO_RV_BP_Location l1 ON (l.C_BPartner_ID = l1.C_BPartner_ID AND l1.IsShipTo='Y')
LEFT OUTER JOIN HIVO_RV_BP_Location l2 ON (l.C_BPartner_ID = l2.C_BPartner_ID AND l2.IsShipTo='Y' AND l1.Address1 != l2.Address1)
LEFT OUTER JOIN HIVO_RV_BP_Location l3 ON (l.C_BPartner_ID = l3.C_BPartner_ID AND l3.IsShipTo='Y' AND l3.Address1 NOT IN (l1.Address1, l2.Address1))
LEFT OUTER JOIN HIVO_RV_BP_Location l4 ON (l.C_BPartner_ID = l4.C_BPartner_ID AND l4.IsShipTo='Y' AND l4.Address1 NOT IN (l1.Address1, l2.Address1, l3.Address1))
WHERE ROWNUM=1
AND l.C_BPartner_ID=bp.C_BPartner_ID) AS Address1, (SELECT (l1.City || '-' || l2.City || '-' || l3.City || '-' || l4.City) AS City
FROM C_BPartner_Location l
LEFT OUTER JOIN HIVO_RV_BP_Location l1 ON (l.C_BPartner_ID = l1.C_BPartner_ID AND l1.IsShipTo='Y')
LEFT OUTER JOIN HIVO_RV_BP_Location l2 ON (l.C_BPartner_ID = l2.C_BPartner_ID AND l2.IsShipTo='Y' AND l1.City != l2.City)
LEFT OUTER JOIN HIVO_RV_BP_Location l3 ON (l.C_BPartner_ID = l3.C_BPartner_ID AND l3.IsShipTo='Y' AND l3.City NOT IN (l1.City, l2.City))
LEFT OUTER JOIN HIVO_RV_BP_Location l4 ON (l.C_BPartner_ID = l4.C_BPartner_ID AND l4.IsShipTo='Y' AND l4.City NOT IN (l1.City, l2.City, l3.City))
WHERE ROWNUM=1
AND l.C_BPartner_ID=bp.C_BPartner_ID) AS City, (SELECT (l1.CountryName || '-' || l2.CountryName || '-' || l3.CountryName || '-' || l4.CountryName) AS CountryName
FROM C_BPartner_Location l
LEFT OUTER JOIN HIVO_RV_BP_Location l1 ON (l.C_BPartner_ID = l1.C_BPartner_ID AND l1.IsShipTo='Y')
LEFT OUTER JOIN HIVO_RV_BP_Location l2 ON (l.C_BPartner_ID = l2.C_BPartner_ID AND l2.IsShipTo='Y' AND l1.CountryName != l2.CountryName)
LEFT OUTER JOIN HIVO_RV_BP_Location l3 ON (l.C_BPartner_ID = l3.C_BPartner_ID AND l3.IsShipTo='Y' AND l3.CountryName NOT IN (l1.CountryName, l2.CountryName))
LEFT OUTER JOIN HIVO_RV_BP_Location l4 ON (l.C_BPartner_ID = l4.C_BPartner_ID AND l4.IsShipTo='Y' AND l4.CountryName NOT IN (l1.CountryName, l2.CountryName, l3.CountryName))
WHERE ROWNUM=1
AND l.C_BPartner_ID=bp.C_BPartner_ID) AS CountryName, bp.AD_Client_ID AS AD_Client_ID, bp.AD_Org_ID AS AD_Org_ID, bp.Created AS Created, bp.CreatedBy AS CreatedBy, bp.Updated AS Updated, bp.UpdatedBy AS UpdatedBy, bp.IsActive AS IsActive FROM C_BPartner bp;

grant select on HIVO_RV_BP_LOCATIONSTRING to REPORTING;
CREATE SYNONYM REPORTING.HIVO_RV_BP_LOCATIONSTRING FOR HIVO_RV_BP_LOCATIONSTRING;


CREATE OR REPLACE FUNCTION currencyRate ( p_CurFrom_ID IN NUMBER,
 p_CurTo_ID IN NUMBER,
 p_ConvDate IN DATE,
 p_ConversionType_ID IN NUMBER,
 p_Client_ID IN NUMBER,
 p_Org_ID  IN NUMBER ) RETURN NUMBER AS  cf_IsEuro  CHAR(1) := NULL;
 cf_IsEMUMember CHAR(1);
 cf_EMUEntryDate DATE;
 cf_EMURate NUMBER;
  ct_IsEuro  CHAR(1) := NULL;
 ct_IsEMUMember CHAR(1);
 ct_EMUEntryDate DATE;
 ct_EMURate NUMBER;
  v_CurrencyFrom NUMBER;
 v_CurrencyTo NUMBER;
 v_CurrencyEuro NUMBER;
  v_ConvDate DATE := SysDate;
 v_ConversionType_ID NUMBER := 0;
 v_Rate  NUMBER;
 BEGIN  IF (p_CurFrom_ID = p_CurTo_ID) THEN  RETURN 1;
 END IF;
  IF (p_ConvDate IS NOT NULL) THEN  v_ConvDate := p_ConvDate;
    END IF;
  IF (p_ConversionType_ID IS NULL OR p_ConversionType_ID = 0) THEN     BEGIN     SELECT C_ConversionType_ID    INTO v_ConversionType_ID     FROM C_ConversionType      WHERE IsDefault='Y'   AND AD_Client_ID IN (0,
p_Client_ID)   AND ROWNUM=1     ORDER BY AD_Client_ID DESC;
     EXCEPTION WHEN OTHERS THEN     DBMS_OUTPUT.PUT_LINE('Conversion Type Not Found');
     END;
 ELSE     v_ConversionType_ID := p_ConversionType_ID;
 END IF;
  BEGIN SELECT IsEuro,
 IsEMUMember,
 EMUEntryDate,
 EMURate   INTO cf_IsEuro,
 cf_IsEMUMember,
 cf_EMUEntryDate,
 cf_EMURate FROM C_Currency WHERE C_Currency_ID = p_CurFrom_ID;
 EXCEPTION WHEN OTHERS THEN NULL;
   END;
  IF (cf_IsEuro IS NULL) THEN  DBMS_OUTPUT.PUT_LINE('From Currency Not Found: ' || p_CurFrom_ID);
  RETURN NULL;
 END IF;
 BEGIN SELECT IsEuro,
 IsEMUMember,
 EMUEntryDate,
 EMURate   INTO ct_IsEuro,
 ct_IsEMUMember,
 ct_EMUEntryDate,
 ct_EMURate FROM C_Currency WHERE C_Currency_ID = p_CurTo_ID;
 EXCEPTION WHEN OTHERS THEN NULL;
   END;
  IF (ct_IsEuro IS NULL) THEN  DBMS_OUTPUT.PUT_LINE('To Currency Not Found: ' || p_CurTo_ID);
  RETURN NULL;
 END IF;
  IF (cf_IsEuro = 'Y' AND ct_IsEMUMember ='Y' AND v_ConvDate >= ct_EMUEntryDate) THEN  RETURN ct_EMURate;
 END IF;
  IF (ct_IsEuro = 'Y' AND cf_IsEMUMember ='Y' AND v_ConvDate >= cf_EMUEntryDate) THEN  RETURN 1 / cf_EMURate;
 END IF;
  IF (cf_IsEMUMember = 'Y' AND cf_IsEMUMember ='Y'  AND v_ConvDate >= cf_EMUEntryDate AND v_ConvDate >= ct_EMUEntryDate) THEN  RETURN ct_EMURate / cf_EMURate;
 END IF;
  v_CurrencyFrom := p_CurFrom_ID;
 v_CurrencyTo := p_CurTo_ID;
  IF ((cf_isEMUMember = 'Y' AND v_ConvDate >= cf_EMUEntryDate)   OR (ct_isEMUMember = 'Y' AND v_ConvDate >= ct_EMUEntryDate)) THEN  SELECT MAX(C_Currency_ID)    INTO v_CurrencyEuro  FROM C_Currency  WHERE IsEuro = 'Y';
    IF (v_CurrencyEuro IS NULL) THEN  DBMS_OUTPUT.PUT_LINE('Euro Not Found');
  RETURN NULL;
  END IF;
  IF (cf_isEMUMember = 'Y' AND v_ConvDate >= cf_EMUEntryDate) THEN  v_CurrencyFrom := v_CurrencyEuro;
  ELSE  v_CurrencyTo := v_CurrencyEuro;
  END IF;
 END IF;
  DECLARE  CURSOR CUR_Rate IS  SELECT MultiplyRate  FROM C_Conversion_Rate  WHERE C_Currency_ID=v_CurrencyFrom AND C_Currency_To_ID=v_CurrencyTo    AND C_ConversionType_ID=v_ConversionType_ID    AND ((v_ConvDate BETWEEN ValidFrom AND ValidTo) OR (v_ConvDate >= ValidFrom AND ValidTo IS NULL))    AND   IsActive = 'Y'    AND AD_Client_ID IN (0,
p_Client_ID) AND AD_Org_ID IN (0,
p_Org_ID)  ORDER BY AD_Client_ID DESC,
 AD_Org_ID DESC,
 ValidFrom DESC;
 BEGIN  FOR c IN CUR_Rate LOOP  v_Rate := c.MultiplyRate;
  EXIT;
   END LOOP;
 END;
  IF (v_Rate IS NULL) THEN  DBMS_OUTPUT.PUT_LINE('Conversion Rate Not Found');
  RETURN NULL;
 END IF;
  IF (cf_isEMUMember = 'Y' AND v_ConvDate >= cf_EMUEntryDate) THEN  RETURN v_Rate / cf_EMURate;
 END IF;
  IF (ct_isEMUMember = 'Y' AND v_ConvDate >= ct_EMUEntryDate) THEN  RETURN v_Rate * ct_EMURate;
 END IF;
 RETURN v_Rate;
 EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
 RETURN NULL;
 
END currencyRate;
/
GRANT EXECUTE ON currencyRate TO REPORTING;
CREATE OR REPLACE SYNONYM REPORTING.currencyRate FOR currencyRate;


CREATE OR REPLACE FUNCTION currencyRound ( p_Amount IN NUMBER,
 p_CurTo_ID IN NUMBER,
 p_Costing IN VARCHAR2  ) RETURN NUMBER AS v_StdPrecision NUMBER;
 v_CostPrecision NUMBER;
 BEGIN  IF (p_Amount IS NULL OR p_CurTo_ID IS NULL) THEN  RETURN p_Amount;
 END IF;
  SELECT MAX(StdPrecision),
 MAX(CostingPrecision)   INTO v_StdPrecision,
 v_CostPrecision FROM C_Currency   WHERE C_Currency_ID = p_CurTo_ID;
  IF (v_StdPrecision IS NULL) THEN  RETURN p_Amount;
 END IF;
 IF (p_Costing = 'Y') THEN  RETURN ROUND (p_Amount,
 v_CostPrecision);
 END IF;
 RETURN ROUND (p_Amount,
 v_StdPrecision);
 
END currencyRound;
/
GRANT EXECUTE ON currencyRound TO REPORTING;
CREATE OR REPLACE SYNONYM REPORTING.currencyRound FOR currencyRound;


CREATE OR REPLACE FUNCTION currencyConvert ( p_Amount IN NUMBER,
 p_CurFrom_ID IN NUMBER,
 p_CurTo_ID IN NUMBER,
 p_ConvDate IN DATE,
 p_ConversionType_ID IN NUMBER,
 p_Client_ID IN NUMBER,
 p_Org_ID IN NUMBER ) RETURN NUMBER AS v_Rate NUMBER;
 BEGIN  IF (p_Amount = 0 OR p_CurFrom_ID = p_CurTo_ID) THEN RETURN p_Amount;
 END IF;
  IF (p_Amount IS NULL OR p_CurFrom_ID IS NULL OR p_CurTo_ID IS NULL) THEN RETURN NULL;
 END IF;
  v_Rate := currencyRate (p_CurFrom_ID,
 p_CurTo_ID,
 p_ConvDate,
 p_ConversionType_ID,
 p_Client_ID,
 p_Org_ID);
 IF (v_Rate IS NULL) THEN RETURN NULL;
 END IF;
  RETURN currencyRound(p_Amount * v_Rate,
 p_CurTo_ID,
 null);
  
END currencyConvert;
/
GRANT EXECUTE ON currencyConvert TO REPORTING;
CREATE OR REPLACE SYNONYM REPORTING.currencyConvert FOR currencyConvert;


--For Hivos QR Reports
alter table afgo_assessmentline ADD (TEXTSCOREB    varchar2(4000));
UPDATE afgo_assessmentline set TEXTSCOREB = dbms_lob.substr( TEXTSCORE, 2000, 1);
commit;
ALTER TABLE afgo_assessmentline ADD (LONGDESCRIPTIONB    varchar2(4000));
UPDATE afgo_assessmentline SET LONGDESCRIPTIONB = dbms_lob.substr( LONGDESCRIPTION, 2000, 1);
commit;


--For Partner dump
UPDATE c_bpartner SET c_bpartner.name = REPLACE(REPLACE(c_bpartner.name,CHR(13),''),CHR(10),' ');
commit;
UPDATE afgo_fundprovider SET afgo_fundprovider.name = REPLACE(REPLACE(afgo_fundprovider.name,CHR(13),''),CHR(10),' ');
commit;
UPDATE c_location SET address1 = REPLACE(address1, Chr(9), ' ');
commit;
UPDATE c_location SET address1 = REPLACE(address1, '&', '');
commit;

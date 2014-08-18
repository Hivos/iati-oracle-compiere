-- This file is part of the IATI, partnerdump AFFM/Compiere project.
-- Copyright (C) 2014 Barry de Graaff <info@barrydegraaff.tk>, (C) 2012 Arthur Baan, (C) 2012 Fred Stoopendaal
--
-- This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

-- 20131015 Adding confidential filter for fundprovider as implemented via afgo_fund
-- 20130916 Adding a filter for confidential fund providers, as this is not yet implemented in Osiris
-- 20120918 BF entire view rewritten

create or replace force view reporting.hv_iati_transactions( afgo_commitment_id
                                                        , c_invoice_id
                                                        , c_invoiceline_id
                                                        , c_payment_id
                                                        , receiver
                                                        , amount
                                                        , transactiondate
                                                        , currency
                                                        , provider
                                                        , afgo_fundprovider_id
                                                        )
as
select distinct 
afgo_commitment.afgo_commitment_id, c_invoice.c_invoice_id, c_invoiceline.c_invoiceline_id, 
c_payment.c_payment_id, cast(c_bpartner.name as varchar( 255 )) receiver,
afgo_fundallocation.allocatedamt amount, c_payment.datetrx as transactiondate,
cast( c_currency.iso_code as varchar2( 3 )) currency, 
--cast( afgo_fundprovider.name as varchar( 255 )) provider, 
CASE WHEN afgo_fund.CONFIDENTIALITYSTATUS = 'P' THEN  cast( afgo_fundprovider.name as varchar( 255 ))
     ELSE cast( 'Confidential' as varchar( 255 )) END AS provider,
to_char(afgo_fundprovider.afgo_fundprovider_id) afgo_fundprovider_id
from afgo_commitment
left outer join c_invoice on afgo_commitment.afgo_commitment_id = c_invoice.afgo_commitment_id
left outer join c_invoiceline on c_invoice.c_invoice_id = c_invoiceline.c_invoice_id
left outer join c_payment on c_payment.c_invoice_id = c_invoice.c_invoice_id 
left outer join c_bpartner on c_payment.C_BPARTNER_ID = C_BPARTNER.C_BPARTNER_ID
left outer join afgo_fundallocation on c_invoiceline.c_invoiceline_id = afgo_fundallocation.c_invoiceline_id
left outer join c_currency on afgo_fundallocation.c_currency_id = c_currency.c_currency_id
left outer join afgo_fund on afgo_fundallocation.afgo_fund_id = afgo_fund.afgo_fund_id
left outer join afgo_fundprovider on afgo_fund.afgo_fundprovider_id = afgo_fundprovider.afgo_fundprovider_id
where afgo_commitment.confidentialitystatus = 'P'
and c_bpartner.confidentialitystatus = 'P'
and c_invoice.ispaid = 'Y'
and (SELECT MAX(com.DateTo) FROM AFGO_Commitment com 
                           WHERE (com.afgo_Commitment_ID=AFGO_Commitment.AFGO_Commitment_ID OR (com.MasterCommitment_ID=AFGO_Commitment.AFGO_Commitment_ID AND com.Processed='Y'))
                        ) > sysdate - 360
union all
select  0, 0, 0, 0, 'Confidential' receiver,
sum(afgo_fundallocation.allocatedamt) amount, trunc(c_payment.datetrx, 'Y') as transactiondate,
cast( c_currency.iso_code as varchar2( 3 )) currency, 'Confidential' provider , ''
from afgo_commitment
left outer join c_invoice on afgo_commitment.afgo_commitment_id = c_invoice.afgo_commitment_id
left outer join c_invoiceline on c_invoice.c_invoice_id = c_invoiceline.c_invoice_id
left outer join c_payment on c_payment.c_invoice_id = c_invoice.c_invoice_id 
left outer join c_bpartner on c_payment.C_BPARTNER_ID = C_BPARTNER.C_BPARTNER_ID
left outer join afgo_fundallocation on c_invoiceline.c_invoiceline_id = afgo_fundallocation.c_invoiceline_id
left outer join c_currency on afgo_fundallocation.c_currency_id = c_currency.c_currency_id
left outer join afgo_fund on afgo_fundallocation.afgo_fund_id = afgo_fund.afgo_fund_id
left outer join afgo_fundprovider on afgo_fund.afgo_fundprovider_id = afgo_fundprovider.afgo_fundprovider_id
where afgo_commitment.confidentialitystatus <> 'P'
and c_bpartner.confidentialitystatus <> 'P'
and c_invoice.ispaid = 'Y'
and (SELECT MAX(com.DateTo) FROM AFGO_Commitment com 
                           WHERE (com.afgo_Commitment_ID=AFGO_Commitment.AFGO_Commitment_ID OR (com.MasterCommitment_ID=AFGO_Commitment.AFGO_Commitment_ID AND com.Processed='Y'))
                        ) > sysdate - 360
group by trunc(c_payment.datetrx, 'Y'), c_currency.iso_code, cast( afgo_fundprovider.name as varchar( 255 ));
                        

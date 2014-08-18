-- This file is part of the IATI, partnerdump AFFM/Compiere project.
-- Copyright (C) 2014 Barry de Graaff <info@barrydegraaff.tk>, (C) 2012 Arthur Baan, (C) 2012 Fred Stoopendaal
--
-- This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

--part of extension of partner dump by Barry de Graaff 16-10-2012

--20130916 Adding a filter for confidential fund providers, as this is not yet implemented in Osiris
--20121127 Barry fixed bug. In the Partner export extension contracts are not displayed, but this also means that increasement and decreasements are not linked
--         to the corresponding master contract. Therefore this view is modified to always return the mastercommitment_id (for extensions) or the afgo_commitment_id 
--         (for master contracts). to_char(nvl(afgo_commitment.MasterCommitment_ID, afgo_commitment.afgo_commitment_id)) afgo_commitment_id

create or replace force view reporting.hv_xml_commitment_funding
as
select 
to_char(nvl(afgo_commitment.MasterCommitment_ID, afgo_commitment.afgo_commitment_id)) afgo_commitment_id,
to_char(sum(afgo_fundallocation.allocatedamt)) sum_fund_allocation,
to_char(c_currency.iso_code) iso_code,
to_char(afgo_fundprovider.name) fundprovidername,
to_char(afgo_fundprovider.afgo_fundprovider_id) afgo_fundprovider_id
from afgo_commitment
left outer join afgo_commitmentline on afgo_commitment.afgo_commitment_id = afgo_commitmentline.afgo_commitment_id
left outer join afgo_fundallocation on afgo_commitmentline.afgo_commitmentline_id = afgo_fundallocation.afgo_commitmentline_id
left outer join afgo_fund on afgo_fundallocation.afgo_fund_id = afgo_fund.afgo_fund_id
left outer join afgo_fundprovider on afgo_fund.afgo_fundprovider_id = afgo_fundprovider.afgo_fundprovider_id
left outer join c_currency on afgo_fundallocation.c_currency_id = c_currency.c_currency_id
where afgo_fundallocation.C_INVOICELINE_ID is null
and afgo_fund.CONFIDENTIALITYSTATUS = 'P'
group by
nvl(afgo_commitment.MasterCommitment_ID, afgo_commitment.afgo_commitment_id), c_currency.iso_code, afgo_fundprovider.name, afgo_fundprovider.afgo_fundprovider_id
order by 1;


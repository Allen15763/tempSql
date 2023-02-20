DECLARE @d AS CHAR(8) 
SET @d = '2023-01%'
--select SUM(escrow_amount) from consignment_ac where grass_date like @d
--select SUM(total_sold_price) from vg where period_ like @d

select SUM(amt) FROM [PRD_SCM].[dbo].[112002_detail] where period_ like @d and type_ like 'con%'
select SUM(escrow_amount) from consignment_ac where grass_date like @d and checkout_payment_method not like '%jko%'


select SUM(amt) FROM [PRD_SCM].[dbo].[112002_detail] where period_ like @d and type_ like 'dir%'
select SUM(escrow_amount) from direct_ac where grass_date like @d and checkout_payment_method not like '%jko%'


select SUM(amt) FROM [PRD_SCM].[dbo].[112002_detail] where period_ like '2023-01%' and type_ like 'out%'
select SUM(escrow_amount) from out where grass_date like '2023-01%' and payment_method not like '%jko%'


select SUM(amt) FROM [PRD_SCM].[dbo].[112002_detail] where period_ like '2023-01%' and type_ like 'vg%'
select SUM(total_sold_price) from vg where period_ like '2023-01%' and pay_method not like '%jko%'


select SUM(amt) FROM [PRD_SCM].[dbo].[112002_detail] where period_ like '2023-01%' and type_ like 'wallet%'
select SUM(amount) from shopee_wallet_daily_trans where grass_date like '2023-01%' 


select SUM(amt) FROM [PRD_SCM].[dbo].[112501_detail] where period_ like '2023-01%' and type_ like 'wallet%'
select SUM(amount) from jko_wallet_daily_trans where grass_date like '2023-01%' 


select SUM(amt) FROM [PRD_SCM].[dbo].[112501_detail] where period_ like '2023-01%' and type_ like 'con%'
select SUM(escrow_amount) from consignment_ac where grass_date like '2023-01%' and checkout_payment_method like '%jko%'


select SUM(amt) FROM [PRD_SCM].[dbo].[112501_detail] where period_ like '2023-01%' and type_ like 'dir%'
select SUM(escrow_amount) from direct_ac where grass_date like '2023-01%' and checkout_payment_method like '%jko%'


select SUM(amt) FROM [PRD_SCM].[dbo].[112501_detail] where period_ like '2023-01%' and type_ like 'out%'
select SUM(escrow_amount) from out where grass_date like '2023-01%' and payment_method like '%jko%'


select SUM(amt) FROM [PRD_SCM].[dbo].[112501_detail] where period_ like '2022-03%' and type_ like 'vg%' --NULL
select SUM(total_sold_price) from vg where period_ like '2022-04%' and pay_method like '%jko%'  --NULL
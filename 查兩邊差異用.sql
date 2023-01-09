select *, -amt from [112002_detail] where ordersn like '_210418AY5VP93Y'
select type_, sum(amt) from [PRD_SCM].[dbo].[112002_detail] group by type_ having type_ like '%Wallet%'

select DISTINct cr_dr from [PRD_SCM].[dbo].[112002_detail]
select DISTINct [account] from [PRD_SCM].[dbo].[112002_detail]
select DISTINct [type_] from [PRD_SCM].[dbo].[112002_detail] WHERE cr_dr = 'cr' and type_ <> 'Wallet_Shopee'
select DISTINct [account] from [PRD_SCM].[dbo].account_200417_detail
select DISTINct [type_] from [PRD_SCM].[dbo].account_200417_detail
select * from [PRD_SCM].[dbo].[112002_detail] WHERE cr_dr = 'cr' and type_ <> 'Wallet_Shopee'

select cr_dr, sum(amt) from [PRD_SCM].[dbo].[112002_detail] group by cr_dr


select type_ ,count(*)  FROM [PRD_SCM].[dbo].[112002_detail] where account = 'UR-JKO' group by type_

--balance
SELECT * FROM [PRD_SCM].[dbo].[112002_detail] WHERE cr_dr = 'dr' GROUP BY ordersn, supplier_id, period_, type_

UPDATE consignment_ac
SET supplier_id = REPLACE(supplier_id, '.0', ''),
	itemid = REPLACE(itemid, '.0', ''),
	modelid = REPLACE(modelid, '.0', ''),
	shopid = REPLACE(shopid, '.0', '')
WHERE grass_date LIKE '2021%'

select COUNT(*) from [112002_detail] where  supplier_id like '%.0'

UPDATE [112002_detail]
SET supplier_id = REPLACE(supplier_id, '.0', '')
WHERE period_ LIKE '2021%'  (3368623 個資料列受到影響) (9175127 個資料列受到影響)

select count(*) from [112002_detail]






--全錢包查詢---------------------------------------------------------------------------------------------
SELECT ordersn, shopid, source, grass_date, SUM(amount) amount
	  , dbo.DistinctList(STRING_AGG(CONVERT(NVARCHAR(max), ISNULL(transaction_type ,'N/A')), ','), ',') AS  transaction_type
	  , CASE WHEN source LIKE '%jko%' OR source LIKE '%JKO%' THEN 'Wallet_JKO'
	         ELSE 'Wallet_Shopee'
		END type_
	  , CASE WHEN source LIKE '%jko%' OR source LIKE '%JKO%' THEN 'UR-JKO'
	         ELSE 'UR-IC_SPE'
		END account
	  , CASE WHEN SUM(amount) >= 0 THEN 'cr'
			 ELSE 'dr'
		END cr_dr
FROM (
	SELECT *, 'shopee' AS source FROM PRD_SCM.dbo.shopee_wallet_daily_trans
	UNION ALL
	SELECT ordersn, orderid, shopid, amount, CAST('1900/1/1' AS datetime) AS transaction_time, 'NA' AS transaction_type, grass_date, 'jko' AS source 
	FROM PRD_SCM.dbo.jko_wallet_daily_trans) a
  WHERE ordersn IN (
'_210818TUYEA9HQ'
  )
  GROUP BY ordersn, shopid, source, grass_date


--全估計查詢----------------------------------------------------------------------------------------------------
WITH accrued(ordersn, checkout_payment_method, escrow_amount, grass_date, source) AS (
SELECT ordersn, checkout_payment_method, escrow_amount, grass_date, 'con' AS 'source'
FROM PRD_SCM.dbo.consignment_ac
UNION ALL
SELECT ordersn, checkout_payment_method, escrow_amount, grass_date, 'direct' AS 'source'
FROM PRD_SCM.dbo.direct_ac
UNION ALL
SELECT ordersn, pay_method AS checkout_payment_method, total_sold_price AS escrow_amount, period_ AS grass_date, 'vg' AS 'source'
FROM PRD_SCM.dbo.vg
UNION ALL
SELECT order_sn AS ordersn, payment_method AS checkout_payment_method, escrow_amount, grass_date, 'out' AS 'source'
FROM PRD_SCM.dbo.out
UNION ALL
SELECT ordersn, checkout_payment_method, -buyer_paid_product_price+seller_voucher+seller_promotion_rebate AS escrow_amount, period_ AS grass_date, 'refund' AS 'source'
FROM PRD_SCM.dbo.sbs_refund
UNION ALL
SELECT ordersn, checkout_payment_method, escrow_amount, grass_date, 'cncb' AS 'source'
FROM PRD_SCM.dbo.cncb)

select * from accrued where ordersn IN (
'_210818TUYEA9HQ'
)


--調整查詢----------------------------------------------------------------------------------------------------------------
SELECT * FROM shopee_wallet_adjustment WHERE ordersn IN ('_210818TUYEA9HQ')
SELECT SUM(amount) FROM shopee_wallet_adjustment WHERE description like  '退貨運費'  '調整未扣除賣家負擔的運費即撥款給賣家'
SELECT * FROM shopee_wallet_adjustment WHERE description like '溢扣手續費返還'


-- DIFF 備註
select SUBSTRING(ordersn, 0, 5), count(ordersn), sum(amount) FROM (
	SELECT *, 'shopee' AS source FROM PRD_SCM.dbo.shopee_wallet_daily_trans
	UNION ALL
	SELECT ordersn, orderid, shopid, amount, CAST('1900/1/1' AS datetime) AS transaction_time, 'NA' AS transaction_type, grass_date, 'jko' AS source 
	FROM PRD_SCM.dbo.jko_wallet_daily_trans) a
  --WHERE grass_date like '2021-09%'
  group by SUBSTRING(ordersn, 0, 5)
  having grass_date like '2021-08%'


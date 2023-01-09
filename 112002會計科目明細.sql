/****** SSMS 中 SelectTopNRows 命令的指令碼  ******/
just a test
SELECT TOP (1000) [ordersn]
      ,[supplier_id]
      ,[period_]
      ,[account]
      ,[type_]
      ,[cr_dr]
      ,[amt]
  FROM [PRD_SCM].[dbo].[112002_detail] WHERE account LIKE '%JKO%' period_ LIKE '2021-08%' AND type_ LIKE 'Con%'
SELECT type_, SUM(amt) FROM [PRD_SCM].[dbo].[112002_detail] WHERE  type_ LIKE 'out%' group by type_

--移除112501的資料
DELETE FROM[PRD_SCM].[dbo].[112002_detail]　WHERE account LIKE 'UR-JKO' AND period_ LIKE '%2022%'

select distinct [type_]  from [112002_detail] -- VG A/ VG B/ VG outright
select  distinct [account] from [112002_detail] --UR-IC SPT
select  distinct [period_] from [112002_detail] order by period_  --JAN~OCT  2021
select  distinct cr_dr from [112002_detail]

select period_, CONVERT(VARCHAR,CAST(SUM(amt) AS MONEY),1) AMT from [112002_detail] group by CUBE (period_)




--------------------------------------------------------------------明細----------------------------------------------------------------------------------------------------------
INSERT INTO [dbo].[112002_detail]
SELECT * FROM (
-- vg  112002 科目明細表
SELECT ordersn
	  , supplier_id
	  , period_
	  , CASE WHEN pay_method = 'UR-IC SPE' THEN 'UR-IC_SPE'
		     ELSE pay_method
	    END account
	  , CASE WHEN contract_type = 'A' THEN 'VG_A'
			 WHEN contract_type = 'B' THEN 'VG_B'
			 ELSE 'VG_Outright' 
		END type_
	  , CASE WHEN SUM(total_sold_price) >= 0 THEN 'dr'
	    ELSE 'dr'--'cr'
		END cr_dr
	  , SUM(total_sold_price) amt
	  FROM vg
	  WHERE period_ LIKE '2022-10%'
	  GROUP BY ordersn, supplier_id, period_, pay_method, contract_type) a
  WHERE amt <> 0
  order by ordersn;
/*
--VG 一致化
UPDATE [PRD_SCM].[dbo].[112002_detail]
  SET account = 'UR-IC_SPE'
  WHERE account = 'UR-IC SPE'

--移除VG cancel order from Accrued and 112002
DELETE [PRD_SCM].[dbo].[112002_detail]--vg
 WHERE ordersn IN (
 '_2106258QF4Q3M5',
'_2107187TERUW3W',
'_211012NAKTK22C',
'_211025QFC62X6F',
'_211002RCJWEVEQ',
'_2110162HWWTF4T',
'_211021DEJU6F9V'
 )

 --移除2021四月VG，少計佣金收入重入DB，7691筆
 DELETE [PRD_SCM].[dbo].[112002_detail]
  WHERE period_ like '%2021-04%' and type_ like '%VG%'

--VG 2020年9月底稿調整
INSERT INTO vg (supplier_id, ordersn, itemid, modelid, return_status, total_cost, total_sold_price, seller_voucher_rebate, shopee_item_rebate, buyer_shipping_fee, commission_fee, seller_transaction_fee, be_status, contract_type, pay_method, period_)
	VALUES('745910', '_2008033W2FDD9U', '1841171438', '0','0', -1839.6, -1900, 0, 0,0,0,0,'ESCROW_PAID', 'A', 'UR-IC SPE', '2020-09-01')

INSERT INTO vg (supplier_id, ordersn, itemid, modelid, return_status, total_cost, total_sold_price, seller_voucher_rebate, shopee_item_rebate, buyer_shipping_fee, commission_fee, seller_transaction_fee, be_status, contract_type, pay_method, period_)
	VALUES('745910', '_200812TUP9A38P', '1841171441', '0','0', -2760.45, -2850, 0, 0,0,0,0,'ESCROW_PAID', 'A', 'UR-IC JKO', '2020-09-01'),
		  ('745910', '_200812TVG9UPD8', '1841171439', '0','0', -919.8, -950, 0, 0,0,0,0,'ESCROW_PAID', 'A', 'UR-IC JKO', '2020-09-01')

--VG 2020/10補入
INSERT INTO vg (supplier_id, ordersn, itemid, modelid, return_status, total_cost, total_sold_price, seller_voucher_rebate, shopee_item_rebate, buyer_shipping_fee, commission_fee, seller_transaction_fee, be_status, contract_type, pay_method, period_)
	VALUES('745910', '_200811QTK3BVWE', '5845252823', '30516326882','0', 30271.5, 31250, 0, 1650,0,0,0,'CANCEL_COMPLETED', 'A', 'UR-IC SPE', '2020-10-01'),
		  ('745910', '_2009087JDPFGRN', '5845252816', '50516308957','0', 5462.1, 5640, 0, 300,0,0,0,'CANCEL_COMPLETED', 'A', 'UR-IC SPE', '2020-10-01'),
		  ('745910', '_2009087KP3DBE8', '7445252207', '40516326870','0', 312.9, 322, 0, 18,0,0,0,'CANCEL_COMPLETED', 'A', 'UR-IC SPE', '2020-10-01'),
		  ('745910', '_2009087JVDHQM8', '7445252234', '50516326850','0', 303.45, 313, 0, 17,0,0,0,'CANCEL_COMPLETED', 'A', 'UR-IC SPE', '2020-10-01'),
		  ('745910', '_2009087JVDHQM8', '7445252207', '40516326870','0', 156.45, 161, 0, 9,0,0,0,'CANCEL_COMPLETED', 'A', 'UR-IC SPE', '2020-10-01')

-- consignment 前置檢視
SELECT diSTINCT [checkout_payment_method] from consignment_ac
SELECT diSTINCT contract_type from consignment_ac

-- consignment  112002 科目明細表
SELECT GROUPING(period_) NU, GROUPING(account), GROUPING_ID(period_,account), period_, account, CONVERT(VARCHAR,CAST(SUM(amt) AS MONEY),1) amt, count(ordersn) counts 
--SELECT type_, account, count(ordersn) counts
FROM (
SELECT ordersn
	  , supplier_id
	  , grass_date period_
	  , CASE WHEN checkout_payment_method LIKE '%JKO%' THEN 'UR-JKO'
	         ELSE 'UR-IC_SPE'
		END account
	  , CASE WHEN contract_type = 'A' THEN 'Consignment_A'
	         WHEN contract_type = 'A1' THEN 'Consignment_A1'
			 WHEN contract_type = 'B' THEN 'Consignment_B'
			 WHEN contract_type = 'C' THEN 'Consignment_C'
			 ELSE 'None'
		END type_
	  , CASE WHEN SUM(escrow_amount) >= 0 THEN 'dr'
	    ELSE 'dr'--'cr'
		END cr_dr
	  , SUM(escrow_amount) amt
	  FROM consignment_ac WHERE grass_date LIKE '2021-03%' GROUP bY ordersn, supplier_id, grass_date, checkout_payment_method, contract_type) a
  --WHERE 
  GROUP BY CUBE (period_, account)
  HAVING GROUPING(period_) <> 1  OR GROUPING(account) <> 1 AND SUM(amt) <> 0
  --GROUP BY CUBE (type_, account)
*/

-- COnsignment插入用
INSERT INTO [dbo].[112002_detail]
SELECT * FROM (
SELECT ordersn
	  , supplier_id
	  , grass_date period_
	  , CASE WHEN checkout_payment_method LIKE '%JKO%' THEN 'UR-JKO'
	         ELSE 'UR-IC_SPE'
		END account
	  , CASE WHEN contract_type = 'A' THEN 'Consignment_A'
	         WHEN contract_type = 'A1' THEN 'Consignment_A1'
			 WHEN contract_type = 'B' THEN 'Consignment_B'
			 WHEN contract_type = 'C' THEN 'Consignment_C'
			 ELSE 'None'
		END type_
	  , CASE WHEN SUM(escrow_amount) >= 0 THEN 'dr'
	    ELSE 'dr'--'cr'
		END cr_dr
	  , SUM(escrow_amount) amt
	  FROM consignment_ac WHERE grass_date LIKE '2022-10%' GROUP bY ordersn, supplier_id, grass_date, checkout_payment_method, contract_type) a
	  WHERE account NOT LIKE '%JKO%'

/*
-- missing SKU 補入
INSERT INTO consignment_ac ([supplier_id] ,[ordersn],[itemid],[modelid] ,[refund_amount] ,[seller_promotion_rebate] ,[actual_shipping_fee] ,[commission_fee]
      ,[transaction_fee] ,[service_fee] ,[checkout_payment_method] ,[seller_voucher] ,[buyer_paid_product_price]  ,[seller_coin_cashback_voucher]
      ,[escrow_amount] ,[actual_buyer_paid_shipping_fee] ,[item_quantity] ,[shopid] ,[type_] ,[cost_price] ,[gross_profit_rate] ,[contract_type] ,[true_contract_type]
      ,[actual_shipping_fee_rebate] ,[gross_cost] ,[grass_date])
	  VALUES ('1013221','_2102176DGGD41B','6754159461','80029608235','0','0','0','0','0','0','AirPay CC','0','740','0','740','0','1','37137599','fixed','584','0','B','Net','0','0','2021/3/31')
		   , ('1013221','_2102175JJMD8WH','6754159461','80029608235','0','0','0','0','0','0','Bank Transfer','0','740','0','740','0','1','37137599','fixed','584','0','B','Net','0','0','2021/3/31')
	  
	  
	  VALUES ('1384359', '_2110295138JK8Y', '10025894700', '101416652769', '0', '0', '0', '0', '0', '0', 'AirPay CC', '0', '193', '0', '193', '0',
	  '2', '37137599', 'fixed', '82', '0', 'A1', 'Gross', '0', '156.1904', '2021/10/31')
*/

-- Direct  112002 科目明細表
--SELECT GROUPING(period_) NU, GROUPING(account), GROUPING_ID(period_,account), period_, account, CONVERT(VARCHAR,CAST(SUM(amt) AS MONEY),1) amt, count(ordersn) counts 
--SELECT type_, account, count(ordersn) counts, SUM(amt)
INSERT INTO [dbo].[112002_detail]
SELECT *
FROM (
SELECT ordersn
	  , supplier_id
	  , grass_date period_
	  , CASE WHEN checkout_payment_method LIKE '%JKO%' THEN 'UR-JKO'
	         ELSE 'UR-IC_SPE'
		END account
	  , CASE WHEN contract_type = 'A' THEN 'Direct_A'
	         WHEN contract_type = 'A1' THEN 'Direct_A1'
			 WHEN contract_type = 'B' THEN 'Direct_B'
			 WHEN contract_type = 'C' THEN 'Direct_C'
			 ELSE 'None'
		END type_
	  , CASE WHEN SUM(escrow_amount) >= 0 THEN 'dr'
	    ELSE 'dr'--'cr'
		END cr_dr
	  , SUM(escrow_amount) amt
	  FROM direct_ac WHERE grass_date LIKE '2022-10%' GROUP bY ordersn, supplier_id, grass_date, checkout_payment_method, contract_type) a
  WHERE account NOT LIKE '%JKO%'
  --GROUP BY CUBE (type_, account)
  GROUP BY CUBE (period_, account)
  HAVING GROUPING(period_) <> 1  OR GROUPING(account) <> 1 AND SUM(amt) <> 0



-- Outright插入用
INSERT INTO [dbo].[112002_detail]
SELECT * FROM (
SELECT order_sn
	  , 'NA' AS supplier_id
	  , CAST(grass_date AS CHAR(7)) + '-01' period_
	  , CASE WHEN payment_method LIKE '%JKO%' THEN 'UR-JKO'
			 --WHEN payment_method LIKE '%底稿未留%' THEN '底稿未留' --for 2020
	         ELSE 'UR-IC_SPE'
		END account
	  , 'Outright' AS type_
	  , CASE WHEN SUM(escrow_amount) >= 0 THEN 'dr'
	    ELSE 'dr'--'cr'
		END cr_dr
	  , SUM(escrow_amount) amt
	  FROM out WHERE grass_date LIKE '2022-10%' GROUP bY order_sn, CAST(grass_date AS CHAR(7)), payment_method) a
	  WHERE account NOT LIKE '%JKO%' --and account not like '%底稿未留%'


--Refund 112002 明細 與插入紀錄
SELECT type_, account, cr_dr, count(ordersn) counts, SUM(amt)
INSERT INTO [dbo].[112002_detail]
SELECT *
FROM (
SELECT ordersn
	  , supplier_id
	  , period_
	  , CASE WHEN checkout_payment_method LIKE '%JKO%' THEN 'UR-JKO'
	         ELSE 'UR-IC_SPE'
		END account
	  , CASE WHEN contract_type = 'A' THEN 'Refund_A'
	         WHEN contract_type = 'A1' THEN 'Refund_A1'
			 WHEN contract_type = 'B' THEN 'Refund_B'
			 WHEN contract_type = 'Outright' THEN 'Refund_Outright'
			 ELSE 'None'
		END type_
	  , CASE WHEN SUM(buyer_paid_product_price+refund_amount+actual_buyer_paid_shipping_fee+actual_shipping_fee_rebate+actual_shipping_fee+seller_voucher+seller_promotion_rebate+transaction_fee+seller_coin_cashback_voucher) >= 0 THEN 'cr'
	    ELSE 'dr'
		END cr_dr
	  , SUM(buyer_paid_product_price+refund_amount+actual_buyer_paid_shipping_fee+actual_shipping_fee_rebate+actual_shipping_fee+seller_voucher+seller_promotion_rebate+transaction_fee+seller_coin_cashback_voucher) amt
	  FROM sbs_refund WHERE period_ LIKE '2022%' AND checkout_payment_method NOT LIKE '%JKO%' GROUP bY ordersn, supplier_id, period_, checkout_payment_method, contract_type) a
  --WHERE 
  GROUP BY CUBE (type_, account, cr_dr)
  GROUP BY CUBE (period_, account)
  HAVING GROUPING(period_) <> 1  OR GROUPING(account) <> 1 AND SUM(amt) <> 0

/*2020年退貨插入
INSERT INTO [dbo].[112002_detail]
SELECT *
FROM (
SELECT ordersn
	  , supplier_id
	  , period_
	  , CASE WHEN checkout_payment_method LIKE '%JKO%' THEN 'UR-JKO'
	         ELSE 'UR-IC_SPE'
		END account
	  , CASE WHEN contract_type = 'A' THEN 'Refund_A'
	         WHEN contract_type = 'A1' THEN 'Refund_A1'
			 WHEN contract_type = 'B' THEN 'Refund_B'
			 WHEN contract_type = 'Outright' THEN 'Refund_Outright'
			 ELSE 'None'
		END type_
	  , CASE WHEN SUM(buyer_paid_product_price+actual_buyer_paid_shipping_fee+actual_shipping_fee_rebate+actual_shipping_fee+seller_voucher-seller_coin_cashback_voucher+seller_promotion_rebate) >= 0 THEN 'cr'
	    ELSE 'cr' --一筆-18
		END cr_dr
	  , SUM(buyer_paid_product_price+actual_buyer_paid_shipping_fee+actual_shipping_fee_rebate+actual_shipping_fee+seller_voucher-seller_coin_cashback_voucher+seller_promotion_rebate) amt
	  FROM sbs_refund WHERE period_ LIKE '2020%' AND checkout_payment_method NOT LIKE '%JKO%' GROUP bY ordersn, supplier_id, period_, checkout_payment_method, contract_type) a
*/


--Wallet breakdown
USE PRD_SCM
GO
ALTER TABLE [112002_detail] ALTER COLUMN ordersn VARCHAR(20);
ALTER TABLE [112002_detail] ALTER COLUMN supplier_id VARCHAR(20);

-- 七月 2022-07-31	197809	380252173.0000

--SELECT grass_date, COUNT(amount), SUM(amount) FROM (
INSERT INTO [dbo].[112002_detail]
SELECT ordersn, shopid AS supplier_id, grass_date AS period_, account, type_, cr_dr, amount AS amt FROM (
--SELECT grass_date period_, CONVERT(VARCHAR,CAST(SUM(amount) AS MONEY),1) amt FROM (
SELECT ordersn, shopid, source, grass_date, SUM(amount) amount
	  , dbo.DistinctList(STRING_AGG(CONVERT(NVARCHAR(max), ISNULL(transaction_type ,'N/A')), ','), ',') AS  transaction_type
	  , CASE WHEN source LIKE '%jko%' OR source LIKE '%JKO%' THEN 'Wallet_JKO'
	         ELSE 'Wallet_Shopee'
		END type_
	  , CASE WHEN source LIKE '%jko%' OR source LIKE '%JKO%' THEN 'UR-JKO'
	         ELSE 'UR-IC_SPE'
		END account
	  , CASE WHEN SUM(amount) >= 0 THEN 'cr'
			 ELSE 'cr'--'dr'
		END cr_dr
FROM (
	SELECT *, 'shopee' AS source FROM PRD_SCM.dbo.shopee_wallet_daily_trans WHERE grass_date LIKE '2022-10%'
	UNION ALL
	SELECT ordersn, orderid, shopid, amount, CAST('1900/1/1' AS datetime) AS transaction_time, 'NA' AS transaction_type, grass_date, 'jko' AS source 
	FROM PRD_SCM.dbo.jko_wallet_daily_trans WHERE grass_date LIKE '2022-10%') a
  GROUP BY ordersn, shopid, source, grass_date) b
WHERE amount <> 0 AND source NOT LIKE '%jko%'
GROUP BY grass_date


--蝦皮錢包調整分錄，插入明細帳
INSERT INTO [dbo].[112002_detail]
SELECT ordersn, shopid AS supplier_id, grass_date AS period_
	   , 'UR-IC_SPE' AS account
	   , 'Wallet_Shopee_adj' AS type_
	   --, CASE WHEN SUM(amount) >= 0 THEN 'dr'
		--	 ELSE 'cr'
		-- END cr_dr
	   ,'cr' AS cr_dr
	   , SUM(amount) amt
  FROM shopee_wallet_adjustment
  --WHERE description NOT LIKE '代收貨款'
  GROUP BY ordersn, shopid, grass_date


--錢包三月補入兩筆進原始table；錢包九月扣掉兩筆調整的項目()
INSERT INTO shopee_wallet_daily_trans (ordersn, orderid, shopid, amount, transaction_time, transaction_type, grass_date) 
	VALUES ('_210225UNVMDETX',	'67951222451038',	'28273186',	'4750',	'2021/3/1  06:27:33 AM', 'escrow_verified_add',	'2021-03-01'),
		   ('_210225UR461W48',	'67953623311496',	'28273186',	'28500', '2021/3/1  06:30:08 AM', 'escrow_verified_add', '2021-03-01')

INSERT INTO [112002_detail]
SELECT ordersn, shopid AS supplier_id, grass_date AS period_, 'UR-IC_SPE' as account, 'Wallet_Shopee' as type_, 'cr' as cr_dr, amount AS amt FROM shopee_wallet_daily_trans
  WHERE (ordersn like '_210225UNVMDETX' or ordersn like '_210225UR461W48') AND grass_date like '2021-03%'

UPDATE shopee_wallet_daily_trans
  SET amount = amount * -1
  WHERE (ordersn = '_210225UNVMDETX' OR ordersn = '_210225UR461W48') AND grass_date LIKE '2021-09%'

UPDATE [112002_detail]
  SET amt = amt * -1
  WHERE (ordersn = '_210225UNVMDETX' OR ordersn = '_210225UR461W48') AND period_ LIKE '2021-09%'

--移除退貨運費等202109調整
DELETE [PRD_SCM].[dbo].[112002_detail]
 WHERE period_ like '%2021-09%' and type_ like '%adj%'

--蝦皮錢包調整，沒有ordersn
INSERT INTO shopee_wallet_adjustment (ordersn, orderid, shopid, amount, transaction_time, transaction_type, grass_date, [description]) 
	VALUES ('NA',	'1667266658173120000',	'0',	'-1499',	'2022-11-01 09:37:38', 'others',	'2022-11-30', '賠款金額錯誤,扣除多餘款項')

--------------------------------------------------------------------餘額----------------------------------------------------------------------------------------------------------
--會有跨月但相同訂單調整對沖DIFF，實際< or >整單數，暫時停用
SELECT * FROM
(
SELECT * 
		, CASE WHEN diff BETWEEN -1 AND 1 THEN 'pass'
		       WHEN Write_off_order IS NULL AND diff > 1 THEN '未沖帳'
			   WHEN Accrued_order IS NULL AND diff < -1 THEN '未估列'
			   WHEN Accrued_order IS NOT NULL AND diff > 1 THEN '尚有餘額'
			   WHEN Write_off_order IS NOT NULL AND diff < -1 THEN '超沖'
			   ELSE 'TBC'
		  END Note
FROM
	(SELECT a.ordersn AS Accrued_order, a.period_ AS Accrued_period, a.amt AS Accrued_amt, b.ordersn AS Write_off_order, b.period_ AS Write_off_p, b.amt AS Write_off_amt
			, CASE WHEN a.amt IS NOT NULL AND b.amt IS NOT NULL THEN a.amt-b.amt
				   WHEN a.amt IS NOT NULL AND b.amt IS NULL THEN a.amt-0
				   WHEN a.amt IS NULL AND b.amt IS NOT NULL THEN b.amt * -1
				   WHEN a.amt IS NULL AND b.amt IS NULL THEN 'Issue'
				   ELSE 'Unknown'
			  END diff
	  FROM
		(select ordersn, CAST(period_ AS CHAR(7)) period_, sum(amt) amt 
			from 
			(
				SELECT * FROM [PRD_SCM].[dbo].[112002_detail] WHERE type_ NOT LIKE '%refund%'
				UNION ALL
				SELECT ordersn,
					   supplier_id,
					   period_,
					   account,
					   type_,
					   CASE WHEN cr_dr = 'cr' THEN 'dr'
					   ELSE 'cr'
					   END cr_dr,
					   amt * -1 AS amt
					   FROM [PRD_SCM].[dbo].[112002_detail] WHERE type_ LIKE '%refund%') t
			where period_ like '2021%' --OR period_ like '2021-02%'                              --調整餘額表期間
			group by ordersn, cr_dr, CAST(period_ AS CHAR(7)) having cr_dr = 'dr') a
	  FULL JOIN 
		(select ordersn, CAST(period_ AS CHAR(7)) period_, sum(amt) amt 
			from 
			(
				SELECT * FROM [PRD_SCM].[dbo].[112002_detail] WHERE type_ NOT LIKE '%refund%'
				UNION ALL
				SELECT ordersn,
					   supplier_id,
					   period_,
					   account,
					   type_,
					   CASE WHEN cr_dr = 'cr' THEN 'dr'
					   ELSE 'cr'
					   END cr_dr,
					   amt * -1 AS amt
					   FROM [PRD_SCM].[dbo].[112002_detail] WHERE type_ LIKE '%refund%') t
			where period_ like '2021%' --OR period_ like '2021-02%'                              --調整餘額表期間
			group by ordersn, cr_dr, CAST(period_ AS CHAR(7)) having cr_dr = 'cr') b
	  ON a.ordersn = b.ordersn
	) c
) d
WHERE Note NOT LIKE 'pass'
ORDER BY Accrued_order, Accrued_period, Write_off_order, Write_off_p



--112002科目明細餘額表，訂單彙整，無期間；e.g.期間2021~202204，未估計數約16M，與ME Accrued vs Wallet Movement difference Report相同，實際餘額不參考期初，1.9M
--約3X分，期間與調整備註後併 202205一筆 202206無
WITH for_time (ordersn, period_) AS (
SELECT ordersn,　dbo.DistinctList(STRING_AGG(CONVERT(NVARCHAR(max), ISNULL(period_ ,'N/A')), ','), ',') AS  period_  
FROM [PRD_SCM].[dbo].[112002_detail] Group by ordersn
)

SELECT m.*,
		CASE WHEN p.period_ IS NOT NULL THEN p.period_
		     ELSE p2.period_
		END period_
		, wallet_adj.description
FROM (
SELECT Accrued_order, Accrued_amt, Write_off_order, Write_off_amt, diff AS Balance, Note 
FROM (
	SELECT *
			, CASE WHEN diff BETWEEN -1 AND 1 THEN 'pass'
				   WHEN Write_off_order IS NULL AND diff > 1 THEN '未沖帳'
				   WHEN Accrued_order IS NULL AND diff < -1 THEN '未估列'
				   WHEN Accrued_order IS NOT NULL AND diff > 1 THEN '尚有餘額'
				   WHEN Write_off_order IS NOT NULL AND diff < -1 THEN '超沖'
				   ELSE 'TBC'
			  END Note
	FROM (
			SELECT a.ordersn AS Accrued_order, a.amt AS Accrued_amt, b.ordersn AS Write_off_order, b.amt AS Write_off_amt
					, CASE WHEN a.amt IS NOT NULL AND b.amt IS NOT NULL THEN a.amt-b.amt
						   WHEN a.amt IS NOT NULL AND b.amt IS NULL THEN a.amt-0
						   WHEN a.amt IS NULL AND b.amt IS NOT NULL THEN b.amt * -1
						   WHEN a.amt IS NULL AND b.amt IS NULL THEN 'Issue'
						   ELSE 'Unknown'
					  END diff
			  FROM
				(select ordersn, sum(amt) amt 
					from 
					(
						SELECT * FROM [PRD_SCM].[dbo].[112002_detail] WHERE type_ NOT LIKE '%refund%'
						UNION ALL
						SELECT ordersn,
							   supplier_id,
							   period_,
							   account,
							   type_,
							   CASE WHEN cr_dr = 'cr' THEN 'dr'
							   ELSE 'cr'
							   END cr_dr,
							   amt * -1 AS amt
							   FROM [PRD_SCM].[dbo].[112002_detail] WHERE type_ LIKE '%refund%') t
					where period_ like '2022-08%' OR period_ like '2022-07%'                              --調整餘額表期間
					group by ordersn, cr_dr having cr_dr = 'dr') a
			  FULL JOIN 
				(select ordersn, sum(amt) amt 
					from 
					(
						SELECT * FROM [PRD_SCM].[dbo].[112002_detail] WHERE type_ NOT LIKE '%refund%'
						UNION ALL
						SELECT ordersn,
							   supplier_id,
							   period_,
							   account,
							   type_,
							   CASE WHEN cr_dr = 'cr' THEN 'dr'
							   ELSE 'cr'
							   END cr_dr,
							   amt * -1 AS amt
							   FROM [PRD_SCM].[dbo].[112002_detail] WHERE type_ LIKE '%refund%') t
					where period_ like '2022-08%' OR period_ like '2022-07%'                              --調整餘額表期間
					group by ordersn, cr_dr having cr_dr = 'cr') b
ON a.ordersn = b.ordersn) c) d
WHERE Note NOT LIKE 'pass'

) m
LEFT JOIN
(SELECT * FROM for_time) p
ON m.Accrued_order = p.ordersn
LEFT JOIN
(SELECT * FROM for_time) p2
ON m.Write_off_order = p2.ordersn
LEFT JOIN　
(SELECT ordersn, dbo.DistinctList(STRING_AGG(CONVERT(NVARCHAR(max), ISNULL(description ,'N/A')), ','), ',') AS description FROM shopee_wallet_adjustment GROUP BY ordersn) wallet_adj
ON m.Write_off_order = wallet_adj.ordersn
ORDER BY Accrued_order, Write_off_order




-- 查看各項數值 VG/CON/DIR/OUT/REFUND-----------------------------------------------------------------------------------------------
select period_, CONVERT(VARCHAR,CAST(sum(total_sold_price)AS MONEY),1) total_sold_price
	  , CONVERT(VARCHAR,CAST(sum(total_sold_price)AS MONEY),1) total_sold_price
	  , CONVERT(VARCHAR,CAST(sum([total_cost])AS MONEY),1) [total_cost]
	  , CONVERT(VARCHAR,CAST(sum([seller_voucher_rebate])AS MONEY),1) [seller_voucher_rebate]
	  , CONVERT(VARCHAR,CAST(sum([buyer_shipping_fee])AS MONEY),1) [buyer_shipping_fee]
	  , CONVERT(VARCHAR,CAST(sum([seller_transaction_fee])AS MONEY),1) [seller_transaction_fee]
	  from vg where period_ like '2021%' and pay_method LIKE '%JKO%' group by cube (period_) 

SELECT grass_date, contract_type, GROUPING(grass_date) NU, GROUPING(contract_type) NU, GROUPING_ID(grass_date,contract_type) NU
	  , CONVERT(VARCHAR,CAST(sum(buyer_paid_product_price)AS MONEY),1) buyer_paid_product_price
	  , CONVERT(VARCHAR,CAST(sum(refund_amount)AS MONEY),1) refund_amount
	  , CONVERT(VARCHAR,CAST(sum(actual_buyer_paid_shipping_fee)AS MONEY),1) actual_buyer_paid_shipping_fee
	  , CONVERT(VARCHAR,CAST(sum(actual_shipping_fee)AS MONEY),1) actual_shipping_fee
	  , CONVERT(VARCHAR,CAST(sum(actual_shipping_fee_rebate)AS MONEY),1) actual_shipping_fee_rebate
	  , CONVERT(VARCHAR,CAST(sum(seller_voucher)AS MONEY),1) seller_voucher
	  , CONVERT(VARCHAR,CAST(sum(seller_promotion_rebate)AS MONEY),1) seller_promotion_rebate
	  , CONVERT(VARCHAR,CAST(sum(transaction_fee)AS MONEY),1) transaction_fee
	  , CONVERT(VARCHAR,CAST(sum( seller_coin_cashback_voucher)AS MONEY),1)  seller_coin_cashback_voucher
	  , CONVERT(VARCHAR,CAST(sum( escrow_amount)AS MONEY),1)  escrow_amount
	  from consignment_ac where grass_date like '2021-03%' group by cube (grass_date, contract_type)
	  HAVING GROUPING_ID(grass_date,contract_type) <> 3 AND GROUPING(grass_date) <> 1;

SELECT grass_date, contract_type, GROUPING(grass_date) NU, GROUPING(contract_type) NU, GROUPING_ID(grass_date,contract_type) NU
	  , CONVERT(VARCHAR,CAST(sum(buyer_paid_product_price)AS MONEY),1) buyer_paid_product_price
	  , CONVERT(VARCHAR,CAST(sum(refund_amount)AS MONEY),1) refund_amount
	  , CONVERT(VARCHAR,CAST(sum(actual_buyer_paid_shipping_fee)AS MONEY),1) actual_buyer_paid_shipping_fee
	  , CONVERT(VARCHAR,CAST(sum(actual_shipping_fee)AS MONEY),1) actual_shipping_fee
	  , CONVERT(VARCHAR,CAST(sum(actual_shipping_fee_rebate)AS MONEY),1) actual_shipping_fee_rebate
	  , CONVERT(VARCHAR,CAST(sum(seller_voucher)AS MONEY),1) seller_voucher
	  , CONVERT(VARCHAR,CAST(sum(seller_promotion_rebate)AS MONEY),1) seller_promotion_rebate
	  , CONVERT(VARCHAR,CAST(sum(transaction_fee)AS MONEY),1) transaction_fee
	  , CONVERT(VARCHAR,CAST(sum( seller_coin_cashback_voucher)AS MONEY),1)  seller_coin_cashback_voucher
	  , CONVERT(VARCHAR,CAST(sum( escrow_amount)AS MONEY),1)  escrow_amount
	  FROM direct_ac WHERE grass_date like '202%' group by cube (grass_date, contract_type) -- AND checkout_payment_method NOT LIKE '%JKO%'
	  HAVING GROUPING_ID(grass_date,contract_type) <> 3 AND GROUPING(grass_date) <> 1;

SELECT SUBSTRING(CAST(grass_date AS CHAR(8)),0,8) [period] , GROUPING(SUBSTRING(CAST(grass_date AS CHAR(8)),0,8)) NU      --Outright 202001~08     revised_buyer_paid_product_price；202007 少1.7M sheet Normal WHERE payment_method LIKE '%底稿%' 
	  , CONVERT(VARCHAR,CAST(sum(buyer_paid_product_price)AS MONEY),1) buyer_paid_product_price
	  , CONVERT(VARCHAR,CAST(sum(refund_amount)AS MONEY),1) refund_amount
	  , CONVERT(VARCHAR,CAST(sum(actual_buyer_paid_shipping_fee)AS MONEY),1) actual_buyer_paid_shipping_fee
	  , CONVERT(VARCHAR,CAST(sum(actual_shipping_fee)AS MONEY),1) actual_shipping_fee
	  , CONVERT(VARCHAR,CAST(sum(seller_voucher)AS MONEY),1) seller_voucher
	  , CONVERT(VARCHAR,CAST(sum(seller_promotion_rebate)AS MONEY),1) seller_promotion_rebate
	  , CONVERT(VARCHAR,CAST(sum(transaction_fee)AS MONEY),1) transaction_fee
	  , CONVERT(VARCHAR,CAST(sum( seller_coin_cashback_voucher)AS MONEY),1)  seller_coin_cashback_voucher
	  , CONVERT(VARCHAR,CAST(sum( escrow_amount)AS MONEY),1)  escrow_amount
	  FROM out WHERE grass_date like '2022%' group by cube (SUBSTRING(CAST(grass_date AS CHAR(8)),0,8)) -- AND payment_method NOT LIKE '%JKO%'
	  HAVING GROUPING(SUBSTRING(CAST(grass_date AS CHAR(8)),0,8)) <> 1;

SELECT period_, contract_type, GROUPING(period_) NU, GROUPING(contract_type) NU, GROUPING_ID(period_,contract_type) NU
	  , CONVERT(VARCHAR,CAST(sum(buyer_paid_product_price)AS MONEY),1) buyer_paid_product_price
	  , CONVERT(VARCHAR,CAST(sum(refund_amount)AS MONEY),1) refund_amount
	  , CONVERT(VARCHAR,CAST(sum(actual_buyer_paid_shipping_fee)AS MONEY),1) actual_buyer_paid_shipping_fee
	  , CONVERT(VARCHAR,CAST(sum(actual_shipping_fee)AS MONEY),1) actual_shipping_fee
	  , CONVERT(VARCHAR,CAST(sum(actual_shipping_fee_rebate)AS MONEY),1) actual_shipping_fee_rebate
	  , CONVERT(VARCHAR,CAST(sum(seller_voucher)AS MONEY),1) seller_voucher
	  , CONVERT(VARCHAR,CAST(sum(seller_promotion_rebate)AS MONEY),1) seller_promotion_rebate
	  , CONVERT(VARCHAR,CAST(sum(transaction_fee)AS MONEY),1) transaction_fee
	  , CONVERT(VARCHAR,CAST(sum( seller_coin_cashback_voucher)AS MONEY),1)  seller_coin_cashback_voucher
	  , CONVERT(VARCHAR,CAST(sum( refund_amount)AS MONEY),1)  refund_amount
	  -- escrow con and outright 分開算；A類為貸方負項
	  , CONVERT(VARCHAR,CAST(sum( buyer_paid_product_price+refund_amount+actual_buyer_paid_shipping_fee+actual_shipping_fee_rebate+actual_shipping_fee+seller_voucher+seller_promotion_rebate+transaction_fee+seller_coin_cashback_voucher)AS MONEY),1)  escrow
	  from sbs_refund where (period_ like '2021%' OR period_ like '2022%') AND checkout_payment_method LIKE '%JKO%' group by cube (period_, contract_type)
	  HAVING GROUPING_ID(period_,contract_type) <> 3 AND GROUPING(period_) <> 1;

--sbs_refund contract_type = 0 設Outright
ALTER TABLE sbs_refund ALTER COLUMN contract_type VARCHAR(10)
UPDATE sbs_refund
SET contract_type = REPLACE(contract_type, '0', 'Outright')
WHERE contract_type = '0'
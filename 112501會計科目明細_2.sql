/*
20221007 updated vg and import 2020
*/

USE PRD_SCM
GO
CREATE TABLE [112501_detail] (
	ordersn     VARCHAR(20) NOT NULL,
	supplier_id VARCHAR(20) NOT NULL,
	period_     VARCHAR(10) NOT NULL,
	account     VARCHAR(50) NOT NULL,
	type_       VARCHAR(20) NOT NULL,
	cr_dr       CHAR(2) NOT NULL,
	amt         decimal(19,4) NOT NULL,
)


-- COnsignment插入用
INSERT INTO [dbo].[112501_detail]
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
	  FROM consignment_ac WHERE grass_date LIKE '2023-01%' GROUP bY ordersn, supplier_id, grass_date, checkout_payment_method, contract_type) a
	  WHERE account LIKE '%JKO%'



-- Direct  科目明細表
SELECT GROUPING(period_) NU, GROUPING(account), GROUPING_ID(period_,account), period_, account, CONVERT(VARCHAR,CAST(SUM(amt) AS MONEY),1) amt, count(ordersn) counts 
--SELECT type_, account, count(ordersn) counts, SUM(amt)
INSERT INTO [dbo].[112501_detail]
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
	  FROM direct_ac WHERE grass_date LIKE '2023-01%' GROUP bY ordersn, supplier_id, grass_date, checkout_payment_method, contract_type) a
  WHERE account LIKE '%JKO%'
  --GROUP BY CUBE (type_, account)
  GROUP BY CUBE (period_, account)
  HAVING GROUPING(period_) <> 1  OR GROUPING(account) <> 1 AND SUM(amt) <> 0


-- Outright插入用
INSERT INTO [dbo].[112501_detail]
SELECT * FROM (
SELECT order_sn
	  , 'NA' AS supplier_id
	  , CAST(grass_date AS CHAR(7)) + '-01' period_
	  , CASE WHEN payment_method LIKE '%JKO%' THEN 'UR-JKO'
	         ELSE 'UR-IC_SPE'
		END account
	  , 'Outright' AS type_
	  , CASE WHEN SUM(escrow_amount) >= 0 THEN 'dr'
	    ELSE 'dr'--'cr'
		END cr_dr
	  , SUM(escrow_amount) amt
	  FROM out WHERE grass_date LIKE '2023-01%' GROUP bY order_sn, CAST(grass_date AS CHAR(7)), payment_method) a
	  WHERE account LIKE '%JKO%'

--Refund 112002 明細 與插入紀錄
SELECT type_, account, cr_dr, count(ordersn) counts, SUM(amt)
INSERT INTO [dbo].[112501_detail]
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
	    ELSE 'cr'--'dr'
		END cr_dr
	  , SUM(buyer_paid_product_price+refund_amount+actual_buyer_paid_shipping_fee+actual_shipping_fee_rebate+actual_shipping_fee+seller_voucher+seller_promotion_rebate+transaction_fee+seller_coin_cashback_voucher) amt
	  FROM sbs_refund WHERE period_ LIKE '2020%' AND checkout_payment_method LIKE '%JKO%' GROUP bY ordersn, supplier_id, period_, checkout_payment_method, contract_type) a
  --WHERE 
  GROUP BY CUBE (type_, account, cr_dr)
  GROUP BY CUBE (period_, account)
  HAVING GROUPING(period_) <> 1  OR GROUPING(account) <> 1 AND SUM(amt) <> 0

--補VG   2020-01~2020-09 only
INSERT INTO [dbo].[112501_detail]
SELECT * FROM (
-- vg  112501 科目明細表
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
	  WHERE period_ LIKE '2020%' AND pay_method LIKE '%JKO%'
	  GROUP BY ordersn, supplier_id, period_, pay_method, contract_type) a
  WHERE amt <> 0
  order by ordersn;



--Wallet breakdown
SELECT COUNT(amount), SUM(amount) FROM (
INSERT INTO [dbo].[112501_detail]
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
	SELECT *, 'shopee' AS source FROM PRD_SCM.dbo.shopee_wallet_daily_trans WHERE grass_date LIKE '2023-01%'
	UNION ALL
	SELECT ordersn, orderid, shopid, amount, CAST('1900/1/1' AS datetime) AS transaction_time, 'NA' AS transaction_type, grass_date, 'jko' AS source 
	FROM PRD_SCM.dbo.jko_wallet_daily_trans WHERE grass_date LIKE '2023-01%') a
  GROUP BY ordersn, shopid, source, grass_date) b
WHERE amount <> 0 AND source LIKE '%jko%'
GROUP BY grass_date


-- jko 錢包調整明細
USE PRD_SCM
GO
CREATE TABLE [jko_wallet_adjustment] (
	ordersn       VARCHAR(20) NOT NULL,
	orderid       VARCHAR(20) NOT NULL,
	shopid        VARCHAR(10) NOT NULL,
	amount        DECIMAL(19,4) NOT NULL,
	grass_date    DATE NOT NULL,
	[description] VARCHAR(50) NOT NULL,
)

INSERT INTO [jko_wallet_adjustment] (ordersn, orderid, shopid, amount, grass_date, [description]) 
	VALUES ('_210128FAYTJKF9', 0, 0, -45, '2021-04-01', '補扣運費'),
		   ('_210128FRRDATGS', 0, 0, -45, '2021-04-01', '補扣運費'),
		   ('_210209GU0KBVF7', 0, 0, -45, '2021-04-01', '補扣運費')

INSERT INTO [jko_wallet_adjustment] (ordersn, orderid, shopid, amount, grass_date, [description]) 
	VALUES ('_2211144054890000', 0, 0, 537, '2022-11-30', 'ordersn error')

-- 補蝦皮日嚐選物調整數
INSERT INTO [jko_wallet_adjustment] (ordersn, orderid, shopid, amount, grass_date, [description]) 
	VALUES ('NA', 0, 0, 171, '2022-12-31', '期初餘額調整')

-- JKO錢包調整新增紀錄至明細表
INSERT INTO [dbo].[112501_detail]
SELECT ordersn, shopid AS supplier_id, grass_date AS period_, 'UR-JKO' account, 'Wallet_jko_adj' type_, 'cr' cr_dr, amount AS amt FROM (
	SELECT * FROM jko_wallet_adjustment
	  WHERE description = '補扣運費') a


--------------------------------------------------------------------餘額----------------------------------------------------------------------------------------------------------
/*
SELECT Accrued_order, Accrued_amt, Write_off_order, Write_off_amt, diff AS Balance, Note FROM (
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
(select ordersn, sum(amt) amt from [112501_detail] group by ordersn, cr_dr having cr_dr = 'dr') a
FULL JOIN 
(select ordersn, sum(amt) amt from [112501_detail] group by ordersn, cr_dr having cr_dr = 'cr') b
ON a.ordersn = b.ordersn) c) d
WHERE Note NOT LIKE 'pass'
ORDER BY Accrued_order
*/

WITH for_time (ordersn, period_) AS (
SELECT ordersn,　dbo.DistinctList(STRING_AGG(CONVERT(NVARCHAR(max), ISNULL(period_ ,'N/A')), ','), ',') AS  period_  
FROM [PRD_SCM].[dbo].[112501_detail] Group by ordersn
)

SELECT m.*,
		CASE WHEN p.period_ IS NOT NULL THEN p.period_
		     ELSE p2.period_
		END period_

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
						SELECT * FROM [PRD_SCM].[dbo].[112501_detail] WHERE type_ NOT LIKE '%refund%'
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
							   FROM [PRD_SCM].[dbo].[112501_detail] WHERE type_ LIKE '%refund%') t
					where period_ like '202%' --OR period_ like '2022-05%'                              --調整餘額表期間
					group by ordersn, cr_dr having cr_dr = 'dr') a
			  FULL JOIN 
				(select ordersn, sum(amt) amt 
					from 
					(
						SELECT * FROM [PRD_SCM].[dbo].[112501_detail] WHERE type_ NOT LIKE '%refund%'
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
							   FROM [PRD_SCM].[dbo].[112501_detail] WHERE type_ LIKE '%refund%') t
					where period_ like '202%' --OR period_ like '2022-05%'                              --調整餘額表期間
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
(SELECT ordersn, dbo.DistinctList(STRING_AGG(CONVERT(NVARCHAR(max), ISNULL(description ,'N/A')), ','), ',') AS description FROM jko_wallet_adjustment GROUP BY ordersn) wallet_adj
ON m.Write_off_order = wallet_adj.ordersn
ORDER BY Accrued_order, Write_off_order
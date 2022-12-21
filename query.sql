-- What are the top 5 brands by receipts scanned for most recent month?

# selecting unique receipts count for each barCode
with receipts_cnt as (
select sum(quantity) as cnt, barCode, receipt_id from Receipt_items group by barCode, receipt_id
),
# getting the receipt_id of the most recent month
most_recent as (
select receipt_id from Receipts where date_format(dateScanned, '%Y-%m') = (select date_format(dateScanned,'%Y-%m') as m_y from Receipts order by m_y desc limit 1)
)
# | brand name | brand_cnt | 
select Brands.name,sum(receipts_cnt.cnt) as brands_cnt
	from receipts_cnt JOIN most_recent ON receipts_cnt.receipt_id = most_recent.receipt_id 
					  JOIN Brands ON receipts_cnt.barCode = Brands.barCode 
	group by Brands.name order by sum(receipts_cnt.cnt) desc limit 5;



-- How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?

# selecting unique receipts count for each barCode
with receipts_cnt as (
select sum(quantity) as cnt, barCode, receipt_id from Receipt_items group by barCode, receipt_id
),
# getting the receipt_id of the most recent month & previous month
recent as (
select receipt_id,rNum from (select receipt_id,DENSE_RANK() over (order by date_format(dateScanned,'%Y-%m') desc) as rNum)
where rNum = 1 or rNum = 2
)
# | brand name | brand_cnt | month |
select Brands.name,sum(receipts_cnt.cnt) as brands_cnt, "current month" as month
	from receipts_cnt JOIN recent ON receipts_cnt.receipt_id = recent.receipt_id 
					  JOIN Brands ON receipts_cnt.barCode = Brands.barCode 
	where recent.rNum = 1
	group by Brands.name order by sum(receipts_cnt.cnt) desc limit 5;

UNION ALL

select Brands.name,sum(receipts_cnt.cnt) as brands_cnt, "previous month" as month
	from receipts_cnt JOIN recent ON receipts_cnt.receipt_id = recent.receipt_id 
					  JOIN Brands ON receipts_cnt.barCode = Brands.barCode 
	where recent.rNum = 2
	group by Brands.name order by sum(receipts_cnt.cnt) desc limit 5;



-- When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?

select AVG(totalSpent) as avg_spent,rewardsReceiptStatus from Receipts where rewardsReceiptStatus = 'Accepted'
UNION ALL
select AVG(totalSpent) as avg_spent,rewardsReceiptStatus from Receipts where rewardsReceiptStatus = 'Rejected'



-- When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?

select AVG(purchasedItemCount) as avg_item_cnt,rewardsReceiptStatus from Receipts where rewardsReceiptStatus = 'Accepted'
UNION ALL
select AVG(purchasedItemCount) as avg_item_cnt,rewardsReceiptStatus from Receipts where rewardsReceiptStatus = 'Rejected'



-- Which brand has the most spend among users who were created within the past 6 months?

# users who are created within the past 6 months
with recent_users as (
select userId from Users  where createdDate > curdate() - interval (dayofmonth(curdate()) - 1) day - interval 6 month
)
,recent_receipts as (
select receipt_id from Receipts JOIN recent_users USING (userId)
)
# aggregate on bar code items
, spent as (
select SUM(finalPrice) as sum_by_barcode, barCode from Receipt_items JOIN recent_receipts USING (receipt_id) group by barCode
)
select sum(sum_by_barcode) as most_spent, Brands.name from spent JOIN Brands USING (barCode) group by Brands.name order by most_spent desc LIMIT 1



-- Which brand has the most transactions among users who were created within the past 6 months?

with recent_users as (
select userId from Users  where createdDate > curdate() - interval (dayofmonth(curdate()) - 1) day - interval 6 month
)
,recent_receipts as (
select receipt_id from Receipts JOIN recent_users USING (userId)
)
# aggregate on bar code items
, spent as (
select COUNT(distinct receipt_id) as sum_by_barcode, barCode from Receipt_items JOIN recent_receipts USING (receipt_id) group by barCode
)
select sum(sum_by_barcode) as most_trans, Brands.name from spent JOIN Brands USING (barCode) group by Brands.name order by most_trans desc LIMIT 1


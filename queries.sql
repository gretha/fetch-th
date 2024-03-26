-- These queries are written using Snowflake SQL and are assuming data is in a cleaned state

--What are the top 5 brands by receipts scanned for most recent month?
WITH
    brand_count AS (
        SELECT
            DATE_TRUNC('MONTH', TO_TIMESTAMP_NTZ (r.purchaseDate)) AS month,
            b.name AS brand_name,
            COUNT(DISTINCT r._id) AS total_receipt_ids
        FROM receipts r
        LEFT JOIN itemList i on r._id=i.receipt_id
        LEFT JOIN brands b USING (barcode)
        WHERE DATE_TRUNC('MONTH', TO_TIMESTAMP_NTZ (purchaseDate)) = DATE_TRUNC ('MONTH', DATE_DIFF (CURRENT_DATE, month, -1))
        GROUP BY month, brand_name
    )
SELECT
    month,
    brand_name,
    total_receipt_ids,
    RANK() OVER (
        ORDER BY
            total_receipt_ids desc
    ) AS RANK
FROM brand_count
ORDER BY RANK asc
LIMIT 5;

--When considering average spend from receipts with 'rewardsReceiptStatus' of 'Accepted' or 'Rejected', which is greater?            
SELECT
    rewardReceiptStatus,
    avg(totalSpent) AS avg_total_spent,
    avg_total_spent - lag(avg_total_spent, 1) OVER (
        ORDER BY
            rewardReceiptStatus
    ) AS avg_total_spent_diff
FROM receipts
WHERE rewardsReceiptStatus IN ('Accepted', 'Rejected')
GROUP BY rewardReceiptStatus
ORDER BY avg_total_spent desc;

--When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
SELECT
    rewardReceiptStatus,
    SUM(purchasedItemCount) AS total_items,
    total_items - lag (total_items, 1) OVER (
        ORDER BY
            rewardReceiptStatus
    ) AS total_items_diff
FROM receipts
WHERE rewardsReceiptStatus IN ('Accepted', 'Rejected')
GROUP BY rewardReceiptStatus
ORDER BY total_items desc;

--Which brand has the most spend among users who were created within the past 6 months?
WITH
    users_6mo AS (
        SELECT DISTINCT
            _id AS userId
        FROM users
        WHERE TO_TIMESTAMP_NTZ (createdDate) >= DATE_DIFF (CURRENT_DATE, MONTH, -6)
    ),
    recs_6mo AS (
        SELECT
            r._id,
            i.itemPrice * i.quantityPurchased AS total_cost,
            i.barcode
        FROM receipts r
        LEFT JOIN itemList i on r._id=i.receipt_id
        INNER JOIN users_6mo USING(userId)
    )
SELECT
    b.name AS brand_name,
    SUM(r.total_cost) AS total_brand_spend
FROM recs_6mo r
LEFT JOIN brands b USING (barcode)
GROUP BY brand_name
ORDER BY total_brand_spend desc
LIMIT 1;
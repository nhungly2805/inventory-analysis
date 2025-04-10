
UPDATE [PurchasesFINAL12312016]
	SET ["VendorName"] = CONCAT(["VendorName"], ["PONumber"]), 
	["PONumber"] = ["PODate"],
	["PODate"] = ["ReceivingDate"],
	["ReceivingDate"] = ["InvoiceDate"],
	["InvoiceDate"] = ["PayDate"],
	["PurchasePrice"] = ["Quantity"],
	["Quantity"] = ["Dollars"],
	["Dollars"] = LEFT(["Classification"], CHARINDEX(',', ["Classification"]) - 1),
	["Classification"] =  RIGHT(["Classification"], LEN(["Classification"]) - CHARINDEX(',', ["Classification"]))
	WHERE ["VendorNumber"] IN (3950, 2, 7240, 8664)

-- Xu ly du lieu o table '2017PurchasePricesDec'
SELECT CAST(["Brand"] AS INT) AS brand_id,
		["Price"] AS price, 
		TRIM(REPLACE(["Description"],'"','')) AS description,
		TRIM(REPLACE(["Size"],'"','')) AS size,
		TRIM(REPLACE(["Volume"],'"','')) AS volume,
		["Classification"] AS classification,
		["PurchasePrice"] AS purchase_price,
		TRIM(REPLACE(["VendorName"],'"','')) AS vendor_name,
		["VendorNumber"] AS vendor_number
INTO purchase_2017
FROM [2017PurchasePricesDec]

-- Xu ly du lieu o table 'BegInvFINAL12312016'
SELECT TRIM(REPLACE(["InventoryId"],'"','')) AS inventory_id,
		CAST(["Store"] AS INT) AS store_id, 
		TRIM(REPLACE(["City"],'"','')) AS city_name,
		CAST(["Brand"] AS INT) AS brand_id,
		TRIM(REPLACE(["Description"],'"','')) AS description,
		TRIM(REPLACE(["Size"],'"','')) AS size,
		CAST(["onHand"] AS INT) AS on_hand,
		CAST(["Price"] AS FLOAT) AS invent_price,
		CAST(["startDate"] AS DATE) AS start_date
INTO inventory_begin
FROM [BegInvFINAL12312016]

-- Tương tự xử lý dữ liệu ở table 'EndInvFINAL12312016'
SELECT TRIM(REPLACE(["InventoryId"],'"','')) AS inventory_id,
		CAST(["Store"] AS INT) AS store_id, 
		TRIM(REPLACE(["City"],'"','')) AS city_name,
		CAST(["Brand"] AS INT) AS brand_id,
		TRIM(REPLACE(["Description"],'"','')) AS description,
		TRIM(REPLACE(["Size"],'"','')) AS size,
		CAST(["onHand"] AS INT) AS on_hand,
		CAST(["Price"] AS FLOAT) AS invent_price,
		CAST(["endDate"] AS DATE) AS end_date
INTO inventory_end
FROM [EndInvFINAL12312016]
	
SELECT CAST(["VendorNumber"] AS INT) AS vendor_number,
		TRIM(REPLACE(["VendorName"],'"','')) AS vendor_name, 
		CONVERT(DATE,REPLACE(["InvoiceDate"],'"','')) AS invoice_date,
		CAST(["PONumber"] AS INT) AS po_number,
		CONVERT(DATE,REPLACE(["PODate"],'"','')) AS po_date,
		CONVERT(DATE,REPLACE(["PayDate"],'"','')) AS pay_date,
		CAST(["Quantity"] AS INT) AS quantity,
		CAST(["Dollars"] AS FLOAT) AS dollars,
		CAST(["Freight"] AS FLOAT) AS freight,
		TRIM(REPLACE(["Approval"],'"','')) AS approval
INTO invoice_purchase
FROM [InvoicePurchases12312016]

SELECT TRIM(REPLACE(["InventoryId"],'"','')) AS inventory_id,
			CAST(["Store"] AS INT) AS store_id,
			CAST(["Brand"] AS INT) AS brand_id,
			TRIM(REPLACE(["Description"],'"','')) AS description,
			TRIM(REPLACE(["Size"],'"','')) AS size,
			CAST(["VendorNumber"] AS INT) AS vendor_number,
			TRIM(REPLACE(["VendorName"],'"','')) AS vendor_name,
			CAST(["PONumber"] AS INT) AS po_number,
			CONVERT(DATE,REPLACE(["PODate"],'"','')) AS po_date,
			CONVERT(DATE,REPLACE(["ReceivingDate"],'"','')) AS receiving_date,
			CONVERT(DATE,REPLACE(["InvoiceDate"],'"','')) AS invoice_date,
			CONVERT(DATE,REPLACE(["PayDate"],'"','')) AS pay_date,
			CAST(["PurchasePrice"] AS FLOAT) AS purchase_price,
			CAST(["Quantity"] AS INT) AS quantity,
			CAST(["Dollars"] AS FLOAT) AS dollars,
			CAST(["Classification"] AS INT) AS classification
INTO purchase_2016
FROM PurchasesFINAL12312016

SELECT TRIM(InventoryId) AS inventory_id,
			CAST(Store AS INT) AS store_id,
			CAST(Brand AS INT) AS brand_id,
			TRIM(Description) AS description,
			TRIM(Size) AS size,
			CAST(SalesQuantity AS INT) AS sales_quantity,
			CAST(SalesDollars AS FLOAT) AS sales_dollars,
			CAST(SalesPrice AS FLOAT) AS sales_price,
			CAST(SalesDate AS date) AS sales_date,
			CAST(Volume AS INT) AS volume,
			CAST(Classification AS INT) AS classification,
			CAST(ExciseTax AS FLOAT) AS excise_tax,
			CAST(VendorNo AS INT) AS vendor_no,
			TRIM(VendorName) AS vendor_name
INTO sales_2016
FROM [SalesFINAL12312016]

--- Calculate lead time
ALTER TABLE purchase_2016
ADD lead_time INT NULL

UPDATE purchase_2016
SET lead_time = DATEDIFF(day, po_date, receiving_date)

--- Calculate sales after excise_tax

ALTER TABLE sales_2016
ADD dollars_after_tax FLOAT NULL

UPDATE sales_2016
SET dollars_after_tax = sales_dollars - excise_tax

-- Update some values
UPDATE inventory_begin
SET invent_price = 9.99
WHERE brand_id = 19138

UPDATE inventory_end
SET city_name = 'TYWARDREATH'
WHERE store_id = 46

UPDATE purchase_2016
SET purchase_price = 54.99, dollars = ROUND(54.99*quantity,2)
WHERE brand_id = 2166

UPDATE invoice_purchase
SET vendor_name = 'VINEYARD BRANDS INC'
WHERE vendor_number = 1587

UPDATE invoice_purchase
SET vendor_name = 'SOUTHERN GLAZERS WINE AND SPIRITS'
WHERE vendor_number = 2000

UPDATE purchase_2016
SET vendor_name = 'VINEYARD BRANDS INC'
WHERE vendor_number = 1587

UPDATE purchase_2016
SET vendor_name = 'SOUTHERN GLAZERS WINE AND SPIRITS'
WHERE vendor_number = 2000

-- Prepare some metrics
WITH sales_2016_group AS
(SELECT store_id, description, ROUND(AVG(sales_quantity),0) AS avg_sales_quantity, SUM(sales_quantity) AS total_sales_quantity, 
		ROUND(SUM(dollars_after_tax),2) AS total_dollars_after_tax, ROUND(MAX(sales_price),2) AS sales_per, COUNT(*) OVER() as total
FROM sales_2016
GROUP BY store_id, description),

purchase_2016_group AS
(SELECT store_id, description, ROUND(AVG(lead_time),0) AS avg_lead_time, SUM(quantity) AS total_purchase, 
		ROUND(MAX(purchase_price),2) AS purchase_per, COUNT(*) OVER() as total
FROM purchase_2016
GROUP BY store_id, description),

inventory_begin_group AS
(SELECT store_id, description, SUM(on_hand) AS on_hand_begin, COUNT(*) OVER() as total
FROM inventory_begin 
GROUP BY store_id, description),

inventory_end_group AS
(SELECT store_id, description, SUM(on_hand) AS on_hand_end, COUNT(*) OVER() as total
FROM inventory_end 
GROUP BY store_id, description)

SELECT total_group.description, total_group.store_id, ISNULL(total_group.on_hand_end,0) AS on_hand_end, 
		ISNULL(total_group.on_hand_begin,0) as on_hand_begin, ISNULL(total_group.avg_lead_time,0) as avg_lead_time,
		ISNULL(total_group.avg_sales_quantity,0) as avg_sales_quantity, ISNULL(total_group.reorder_point,0) as reorder_point, 
		CASE WHEN (total_group.reorder_point - total_group.on_hand_end) > 0 THEN (total_group.reorder_point - total_group.on_hand_end)
					       ELSE 0 END as order_quantity, 
		ISNULL(total_group.total_sales_quantity,0) as total_sales_quantity, ISNULL(total_group.total_purchase,0) as total_purchase, 
		ISNULL(total_group.sales_per,0) as sales_per, ISNULL(total_group.purchase_per,0) as purchase_per, 
		ISNULL(total_group.total_dollars_after_tax,0) as total_dollars_after_tax, 
		total_group.cumulative_total_dollars, total_group.total_dollars_store, total_group.cumulative_percent, 
		total_group.product_rank_by_revenue, total_group.class
INTO abc_group
FROM
(SELECT abc.description, abc.store_id, e.on_hand_end AS on_hand_end, b.on_hand_begin AS on_hand_begin, avg_lead_time, avg_sales_quantity, 
		CEILING(avg_lead_time*avg_sales_quantity + (CASE WHEN class = 'A' THEN 0.3
												WHEN class = 'B' THEN 0.2
												ELSE 0.1 END)*avg_lead_time*avg_sales_quantity) AS reorder_point,
		total_sales_quantity, total_purchase, sales_per, purchase_per, ROUND(total_dollars_after_tax,2) AS total_dollars_after_tax, 
		ROUND(cumulative_total_dollars,2) AS cumulative_total_dollars, ROUND(total_dollars,2) AS total_dollars_store, 
		ROUND(cumulative_percent,2) AS cumulative_percent, product_rank_by_revenue, class
FROM inventory_end_group e
RIGHT JOIN
(SELECT p.description, p.store_id, avg_lead_time, avg_sales_quantity, total_sales_quantity, total_purchase, sales_per, 
	purchase_per, total_dollars_after_tax,
	SUM(total_dollars_after_tax) OVER(PARTITION BY p.store_id ORDER BY total_dollars_after_tax DESC) AS cumulative_total_dollars,
	SUM(total_dollars_after_tax) OVER(PARTITION BY p.store_id) AS total_dollars,
	SUM(total_dollars_after_tax) OVER(PARTITION BY p.store_id ORDER BY total_dollars_after_tax DESC) / SUM(total_dollars_after_tax) OVER(PARTITION BY p.store_id) AS cumulative_percent,
	DENSE_RANK() OVER(PARTITION BY p.store_id ORDER BY total_dollars_after_tax DESC) AS product_rank_by_revenue,
	CASE 
		WHEN SUM(total_dollars_after_tax) OVER(PARTITION BY p.store_id ORDER BY total_dollars_after_tax DESC) / SUM(total_dollars_after_tax) OVER(PARTITION BY p.store_id) <= 0.7 
			THEN 'A'
		WHEN SUM(total_dollars_after_tax) OVER(PARTITION BY p.store_id ORDER BY total_dollars_after_tax DESC) / SUM(total_dollars_after_tax) OVER(PARTITION BY p.store_id) <= 0.9 
			THEN 'B'
		ELSE 'C'
	END AS class
FROM purchase_2016_group p
LEFT JOIN sales_2016_group s
ON p.description = s.description
AND p.store_id = s.store_id
WHERE p.store_id != 81) abc
ON abc.description = e.description 
AND abc.store_id = e.store_id
LEFT JOIN inventory_begin_group b
ON b.description = abc.description 
AND abc.store_id = b.store_id
) total_group

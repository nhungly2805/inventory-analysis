-- Check for data validation
SELECT *
FROM purchase_2017
WHERE brand_id IS NULL OR description IS NULL OR purchase_price IS NULL 
	OR size IS NULL OR volume IS NULL OR classification IS NULL OR
	purchase_price IS NULL OR vendor_name IS NULL OR vendor_number IS NULL

SELECT *
FROM inventory_begin
WHERE inventory_id IS NULL OR store_id IS NULL OR city_name IS NULL 
	OR brand_id IS NULL OR description IS NULL OR size IS NULL OR
	on_hand IS NULL OR invent_price IS NULL OR start_date IS NULL

SELECT *
FROM inventory_end
WHERE inventory_id IS NULL OR store_id IS NULL OR city_name IS NULL 
	OR brand_id IS NULL OR description IS NULL OR size IS NULL OR
	on_hand IS NULL OR invent_price IS NULL OR end_date IS NULL

SELECT *
FROM invoice_purchase
WHERE vendor_number IS NULL OR vendor_name IS NULL OR invoice_date IS NULL 
	OR po_number IS NULL OR po_date IS NULL OR pay_date IS NULL OR
	quantity IS NULL OR dollars IS NULL OR freight IS NULL OR approval IS NULL

SELECT *
FROM purchase_2016
WHERE inventory_id IS NULL OR store_id IS NULL OR brand_id IS NULL OR
	description IS NULL OR size IS NULL or vendor_number IS NULL OR
	vendor_name IS NULL OR po_number IS NULL OR po_date IS NULL OR 
	receiving_date IS NULL OR pay_date IS NULL OR purchase_price IS NULL OR
	quantity IS NULL OR dollars IS NULL OR classification IS NULL

SELECT *
FROM sales_2016
WHERE inventory_id IS NULL OR store_id IS NULL OR brand_id IS NULL OR
	description IS NULL OR size IS NULL OR description IS NULL OR
	sales_quantity IS NULL OR sales_dollars IS NULL OR sales_price IS NULL OR
	sales_date IS NULL OR volume IS NULL OR classification IS NULL OR
	excise_tax IS NULL OR vendor_no IS NULL OR vendor_name IS NULL

-- EDA for each table
--- EDA for begin inventory
SELECT COUNT(*) as total_observation, COUNT(DISTINCT(inventory_id)) as number_inventory_id, 
		COUNT(DISTINCT(store_id)) AS number_store, COUNT(DISTINCT(city_name)) as number_city, 
		COUNT(DISTINCT(brand_id)) AS number_brand, COUNT(DISTINCT(description)) as number_description, 
		MAX(invent_price) as max_price, MIN(invent_price) as min_price, AVG(invent_price) as avg_invent_price, 
		MAX(on_hand) as max_on_hand, MIN(on_hand) as min_on_hand, AVG(on_hand) as avg_on_hand
FROM inventory_begin

SELECT *
FROM inventory_begin
WHERE invent_price = 0

SELECT *
FROM inventory_end
WHERE brand_id = 19138

SELECT brand_id, COUNT(DISTINCT(description))
FROM inventory_begin
GROUP BY brand_id
HAVING COUNT(DISTINCT(description)) != 1

SELECT b.brand_id, b.description, p.vendor_name
FROM inventory_begin b
INNER JOIN (SELECT description, COUNT(DISTINCT(brand_id)) as number_description
FROM inventory_begin 
GROUP BY description
HAVING COUNT(DISTINCT(brand_id)) > 1) c
ON b.description = c.description
LEFT JOIN purchase_2016 p
ON p.brand_id = b.brand_id
GROUP BY b.brand_id, b.description, p.vendor_name
ORDER BY b.description

SELECT b.description, p.vendor_name
FROM inventory_begin b
LEFT JOIN purchase_2016 p
ON p.brand_id = b.brand_id
WHERE b.description IN (SELECT b.description
						FROM inventory_begin b
						INNER JOIN (SELECT description, COUNT(DISTINCT(brand_id)) as number_description
						FROM inventory_begin 
						GROUP BY description
						HAVING COUNT(DISTINCT(brand_id)) > 1) c
						ON b.description = c.description
						LEFT JOIN purchase_2016 p
						ON p.description = b.description
						GROUP BY b.description
						HAVING COUNT(DISTINCT(p.vendor_name)) > 1
						)
GROUP BY b.description, p.vendor_name
ORDER BY b.description

--- EDA for ending inventory
SELECT COUNT(*) as total_observation, COUNT(DISTINCT(inventory_id)) as number_inventory_id, 
		COUNT(DISTINCT(store_id)) AS number_store, COUNT(DISTINCT(city_name)) as number_city, 
		COUNT(DISTINCT(brand_id)) AS number_brand, COUNT(DISTINCT(description)) as number_description, 
		MAX(invent_price) as max_price, MIN(invent_price) as min_price, AVG(invent_price) as avg_invent_price, 
		MAX(on_hand) as max_on_hand, MIN(on_hand) as min_on_hand, AVG(on_hand) as avg_on_hand
FROM inventory_end

SELECT b.store_id as begin_store_id, b.city_name as begin_city_name, e.store_id as end_store_id, e.city_name as end_city_name
FROM (SELECT store_id, city_name
FROM inventory_begin
GROUP BY store_id, city_name) b
FULL JOIN
(SELECT store_id, city_name
FROM inventory_end
GROUP BY store_id, city_name) e
ON b.store_id = e.store_id AND b.store_id = e.store_id
WHERE (e.city_name != b.city_name) OR b.city_name IS NULL OR  e.city_name IS NULL
ORDER BY b.store_id

--- EDA for purchase 2016
SELECT COUNT(*) as total_observation, COUNT(DISTINCT(inventory_id)) as number_inventory_id, 
		COUNT(DISTINCT(store_id)) AS number_store, COUNT(DISTINCT(brand_id)) AS number_brand, 
		COUNT(DISTINCT(description)) as number_description, MAX(purchase_price) as max_price, 
		MIN(purchase_price) as min_price, AVG(purchase_price) as avg_purchase_price
FROM purchase_2016

SELECT *
FROM purchase_2016
WHERE purchase_price = 0

SELECT vendor_number, vendor_name, SUM(quantity) as total_quantity, SUM(dollars) as total_dollars
FROM purchase_2016
WHERE vendor_number = 2561
GROUP BY vendor_number, vendor_name

SELECT vendor_number, vendor_name, SUM(quantity) as total_quantity, SUM(dollars) as total_dollars
FROM invoice_purchase
WHERE vendor_number = 2561
GROUP BY vendor_number, vendor_name

SELECT *
FROM inventory_end
WHERE brand_id = 2166

--- EDA for sales 2016
SELECT COUNT(*) as total_observation, COUNT(DISTINCT(inventory_id)) as number_inventory_id, 
		COUNT(DISTINCT(store_id)) AS number_store, COUNT(DISTINCT(brand_id)) AS number_brand, 
		COUNT(DISTINCT(description)) as number_description, MAX(sales_price) as max_price, MIN(sales_price) as min_price,
		 AVG(sales_price) as avg_sales_price, MAX(sales_date) as max_sales_date, MIN(excise_tax) as min_tax
FROM sales_2016

SELECT *
FROM sales_2016
WHERE store_id = 81

--- EDA for invoice purchase
SELECT COUNT(*) as total_observation, COUNT(DISTINCT(vendor_name)) AS number_vendor_name,
	COUNT(DISTINCT(vendor_number)) AS number_vendor, MAX(invoice_date) AS max_invoice_date,
	MIN(invoice_date) AS min_invoice_date, MIN(quantity) AS min_quantity, MAX(quantity) AS max_quantity,
	MIN(dollars) AS min_purchase, MAX(dollars) AS max_purchase, MIN(freight) AS min_freight,
	MAX(freight) AS max_freight
FROM invoice_purchase
WHERE YEAR(invoice_date) = 2016

SELECT vendor_number, vendor_name, SUM(dollars) as total_dollars, SUM(freight) as total_freight, MAX(dollars) as max_dollars, MAX(freight) as max_freight
FROM invoice_purchase
WHERE vendor_number IN 
(SELECT vendor_number
FROM invoice_purchase
GROUP BY vendor_number
HAVING COUNT(DISTINCT(vendor_name)) > 1) AND YEAR(invoice_date) = 2016
GROUP BY vendor_number, vendor_name 

-- Analyse inventory
--- Beginning
SELECT TOP 10 description, SUM(on_hand) as begin_on_hand
FROM inventory_begin
GROUP BY description
ORDER BY begin_on_hand DESC

--- Ending
SELECT TOP 10 description, SUM(on_hand) as end_on_hand
FROM inventory_end
GROUP BY description
ORDER BY end_on_hand DESC

-- Analyse sales
--- Sales by description
SELECT TOP 10 description, SUM(sales_quantity) as total_sales_quantity
FROM sales_2016
GROUP BY description
ORDER BY total_sales_quantity DESC

--- Sales by store_id
SELECT TOP 5 store_id, ROUND(SUM(dollars_after_tax),2) as total_sales
FROM sales_2016
GROUP BY store_id
ORDER BY total_sales DESC

SELECT TOP 5 store_id, ROUND(SUM(dollars_after_tax),2) as total_sales
FROM sales_2016
GROUP BY store_id
ORDER BY total_sales

--- Sales by month
SELECT MONTH(sales_date) as month, ROUND(SUM(dollars_after_tax),2) as total_sales
FROM sales_2016
GROUP BY MONTH(sales_date)
ORDER BY total_sales

--- Sales by city
SELECT TOP 5 e.city_name, ROUND(SUM(dollars_after_tax),2) as total_sales 
FROM sales_2016 s
LEFT JOIN inventory_end e
ON s.store_id = e.store_id
GROUP BY city_name
ORDER BY total_sales DESC

SELECT TOP 5 e.city_name, ROUND(SUM(dollars_after_tax),2) as total_sales 
FROM sales_2016 s
LEFT JOIN inventory_end e
ON s.store_id = e.store_id
GROUP BY city_name
ORDER BY total_sales

-- Analyse purchases
--- Purchase by quantity
SELECT TOP 5 vendor_name, SUM(quantity) as total_quantity
FROM purchase_2016
GROUP BY vendor_name
ORDER BY total_quantity DESC
--- Purchase by cost
SELECT TOP 5 vendor_name, ROUND(SUM(dollars),2) as total_dollars
FROM purchase_2016
GROUP BY vendor_name
ORDER BY total_dollars DESC


WITH sales_2016_group AS
(SELECT description, SUM(sales_quantity) AS total_sales_quantity, 
		ROUND(SUM(dollars_after_tax),2) AS total_dollars_after_tax
FROM sales_2016
GROUP BY description),

purchase_2016_group AS
(SELECT description, SUM(quantity) AS total_purchase
FROM purchase_2016
WHERE YEAR(po_date) = 2016 AND month(po_date) <= 2
GROUP BY description)

SELECT p.description, total_sales_quantity, total_purchase, total_dollars_after_tax,
	SUM(total_dollars_after_tax) OVER() AS total_dollars,
	ROUND(total_dollars_after_tax / SUM(total_dollars_after_tax) OVER() *100, 2) AS percent_total,
	DENSE_RANK() OVER(ORDER BY total_dollars_after_tax DESC) AS product_rank_by_revenue
FROM purchase_2016_group p
LEFT JOIN sales_2016_group s
ON p.description = s.description
ORDER BY total_dollars_after_tax DESC

SELECT *
FROM abc_group
WHERE store_id = 3
ORDER BY store_id, total_dollars_after_tax DESC
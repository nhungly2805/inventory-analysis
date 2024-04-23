# Inventory Analysis Case Study
## 1. Background
Any Manufacturing Company is a medium-sized manufacturing company that produces electronic components. They have a wide range of products and maintain an inventory of raw materials, work-in-progress (WIP), and finished goods. The company has been experiencing issues with inventory management, including stockouts, excess inventory, and increased carrying costs. The management team wants to conduct an inventory analysis to identify areas for improvement and optimize their inventory management practices.
## 2. Analysis phase
### _2.1. Step 1: Ask_
_2.1.1. Objective_

- General objective:
	- Aims to improve its inventory management practices, reduce costs, and enhance customer satisfaction by ensuring the availability of products.
- Detail objective:
	- Identify opportunities to reduce stockouts and excess inventory.
	- Streamline the procurement and production processes to improve efficiency.
	- Develop a sustainable inventory management strategy for future growth.
_2.1.2. Tasks need to be performed_
- ABC analysis: Classify inventory items based on their value and importance to prioritize management efforts.
- Lead time analysis: Calculate the lead time for each product.
- Reorder point analysis: Calculate the reorder point for each product to avoid stockouts.

### _2.2. Step 2: Prepare_

Answer the question: What metrics to measure?

_2.2.1. ABC analysis techniques in inventory management

**ABC analysis technique** is the principle of analyzing stored goods into 3 basic groups. 
- Products that make 70% of the sales are in Class A
- Products that make 20% of the sales are in Class B
- Products that make 10% of the sales are in Class C

_2.2.2. Reorder point_

**Reorder point (ROP)** = Demand During Lead Time + Safety Stock

With the dataset used:

- **Demand During Lead Time** = Average lead time * Average sales per day

- **Safety Stock**:
	- Class A: 0.3* Demand During Lead Time
	- Class B: 0.2* Demand During Lead Time
	- Class C: 0.1* Demand During Lead Time
 
_2.2.3. Lead Time_

**Lead time** is the total time from when a customer places an order until it’s delivered. 

 ![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/fd2b0b65-f0c1-4f8f-9d49-8bf04f86bc54)
 
### _2.3. Step 3: Process_

_2.3.1. Update data_

Some rows of the following two tables are corrupted, so before making a copy, the author will update the data first.

```sh
UPDATE [InvoicePurchases12312016]
SET ["VendorName"] = CONCAT(["VendorName"], ["InvoiceDate"]), 
	["InvoiceDate"] = ["PONumber"], 
	["PONumber"] = ["PODate"],
	["PODate"] = ["PayDate"],
	["PayDate"] = ["Quantity"],
	["Quantity"] = ["Dollars"],
	["Dollars"] = ["Freight"],
	["Freight"] = LEFT(["Approval"], CHARINDEX(',', ["Approval"]) - 1),
	["Approval"] =  RIGHT(["Approval"], LEN(["Approval"]) - CHARINDEX(',', ["Approval"]))
WHERE ["VendorNumber"] IN (3950, 2, 7240, 8664)
```

```sh
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
 ```

_2.3.2. Create copy table_

```sh
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
```

```sh
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
```

```sh
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
```

```sh	
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
```

```sh
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
```

```sh
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
```

_2.3.3. Cleaning data_

- Checking missing value:

```sh
SELECT *
FROM purchase_2017
WHERE brand_id IS NULL OR description IS NULL OR purchase_price IS NULL 
	OR size IS NULL OR volume IS NULL OR classification IS NULL OR
	purchase_price IS NULL OR vendor_name IS NULL OR vendor_number IS NULL
```

```sh
SELECT *
FROM inventory_begin
WHERE inventory_id IS NULL OR store_id IS NULL OR city_name IS NULL 
	OR brand_id IS NULL OR description IS NULL OR size IS NULL OR
	on_hand IS NULL OR invent_price IS NULL OR start_date IS NULL
```

```sh
SELECT *
FROM inventory_end
WHERE inventory_id IS NULL OR store_id IS NULL OR city_name IS NULL 
	OR brand_id IS NULL OR description IS NULL OR size IS NULL OR
	on_hand IS NULL OR invent_price IS NULL OR end_date IS NULL
```

```sh
SELECT *
FROM invoice_purchase
WHERE vendor_number IS NULL OR vendor_name IS NULL OR invoice_date IS NULL 
	OR po_number IS NULL OR po_date IS NULL OR pay_date IS NULL OR
	quantity IS NULL OR dollars IS NULL OR freight IS NULL OR approval IS NULL
```

```sh
SELECT *
FROM purchase_2016
WHERE inventory_id IS NULL OR store_id IS NULL OR brand_id IS NULL OR
	description IS NULL OR size IS NULL or vendor_number IS NULL OR
	vendor_name IS NULL OR po_number IS NULL OR po_date IS NULL OR 
	receiving_date IS NULL OR pay_date IS NULL OR purchase_price IS NULL OR
	quantity IS NULL OR dollars IS NULL OR classification IS NULL
```

```sh
SELECT *
FROM sales_2016
WHERE inventory_id IS NULL OR store_id IS NULL OR brand_id IS NULL OR
	description IS NULL OR size IS NULL OR description IS NULL OR
	sales_quantity IS NULL OR sales_dollars IS NULL OR sales_price IS NULL OR
	sales_date IS NULL OR volume IS NULL OR classification IS NULL OR
	excise_tax IS NULL OR vendor_no IS NULL OR vendor_name IS NULL
```

**Result: No missing value.**

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/684dec69-fde3-4ffb-814a-fc58ee66c688)

- Table begin inventory:

```sh
SELECT COUNT(*) as total_observation, COUNT(DISTINCT(inventory_id)) as number_inventory_id, 
		COUNT(DISTINCT(store_id)) AS number_store, COUNT(DISTINCT(city_name)) as number_city, 
		COUNT(DISTINCT(brand_id)) AS number_brand, COUNT(DISTINCT(description)) as number_description, 
		MAX(invent_price) as max_price, MIN(invent_price) as min_price, AVG(invent_price) as avg_invent_price, 
		MAX(on_hand) as max_on_hand, MIN(on_hand) as min_on_hand, AVG(on_hand) as avg_on_hand
FROM inventory_begin
```

The price value represents the price of inventory but has a value of 0. This is not reasonable, so the author looked at information about which variable has the value 0. 

```sh
SELECT *
FROM inventory_begin
WHERE invent_price = 0
```

The result found brand_id = 19138 has price value equal 0. 

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/2c3555af-6ac0-4c89-a9c0-0b254dada0c1)

The author performs a price check based on information from the inventory_end table.

```sh
SELECT *
FROM inventory_end
WHERE brand_id = 19138
```

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/d6b9436c-0bb5-4e61-a582-159f3ece8e82)

Result found the missing value is 9.99, perform update value.

```sh
UPDATE inventory_begin
SET invent_price = 9.99
WHERE brand_id = 19138
```

After updating, the new statistical results are as follows. The company has a total of 79 stores spread across 67 cities with 7,287 different products.
 
Normally a description will correspond to a brand_id, but the results above show that the brand_id number is 8094, while the description is only 7287. The author performs the check with the following command:

```sh
SELECT brand_id, COUNT(DISTINCT(description))
FROM inventory_begin
GROUP BY brand_id
HAVING COUNT(DISTINCT(description)) != 1
```

```sh
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
```

The results found that 1 brand_id only has 1 description but there are many brand_id's with the same description.  

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/0e435b16-0ada-4277-9e2f-ec40baacd68f)

 
The author suspects that the cause may be due to one product but there are many different vendors, so the new brand_id is different. Check with the command:

```sh
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
```


However, after checking, the author found that in cases where 1 description has many different brand_id, most 1 product has only 1 vendor, and **there are only 7 products from 2 different vendors. The company should adjust the data to make it consistent so that a product is only represented by 1 brand_id**. 

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/ea0e927c-ef33-479f-a8ca-3e7a67b931f8)

 - Table inventory_end:

```sh
SELECT COUNT(*) as total_observation, COUNT(DISTINCT(inventory_id)) as number_inventory_id, 
		COUNT(DISTINCT(store_id)) AS number_store, COUNT(DISTINCT(city_name)) as number_city, 
		COUNT(DISTINCT(brand_id)) AS number_brand, COUNT(DISTINCT(description)) as number_description, 
		MAX(invent_price) as max_price, MIN(invent_price) as min_price, AVG(invent_price) as avg_invent_price, 
		MAX(on_hand) as max_on_hand, MIN(on_hand) as min_on_hand, AVG(on_hand) as avg_on_hand
FROM inventory_end
```


By the end of the year, the company could see the company grow to 80 stores across 68 cities with 8,727 different products.

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/bb0a8b15-cd16-4216-a341-779ec778e969)

 
The author checks the store_id in the new city with the command:

```sh
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
```

Discovered new store_id is 81 in Pembroke city. Store_id 46 missed the city name, so the author updated it with the command below. The article did not detect any information about store_id 80 in both inventory tables end and begin, proving that **store_id 80 does not exist but the company placed the new store_id directly at number 81. The company needs to set store_id according to the rules for later inspection**.

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/cc031ffb-681c-44c7-9829-31e31e0d80cc)

```sh
UPDATE inventory_end
SET city_name = 'TYWARDREATH'
WHERE store_id = 46
 	Table purchase_2016:
SELECT COUNT(*) as total_observation, COUNT(DISTINCT(inventory_id)) as number_inventory_id, 
		COUNT(DISTINCT(store_id)) AS number_store, COUNT(DISTINCT(brand_id)) AS number_brand, 
		COUNT(DISTINCT(description)) as number_description, MAX(purchase_price) as max_price, 
		MIN(purchase_price) as min_price, AVG(purchase_price) as avg_purchase_price
FROM purchase_2016
```

The result shows that the price value is 0. 

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/35530019-9d23-47f1-8b10-8a86fe13d2f1)

 
Check which brand has this value with the following command:

```sh
SELECT *
FROM purchase_2016
WHERE purchase_price = 0
```

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/c07524ff-ba1d-46cd-a99c-936032a690d3)

The author wants to rely on the invoice purchase table to find information, but the results show that the total dollar value of the two tables is equal, so the calculation cannot be performed to find the missing value.

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/09d620fe-3b85-499a-ba30-0923c5392bd6)

 
Although the value at purchase is different from the value in the inventory price column, because no alternative data could be found, the author decided to take the price value obtained from inventory_end and update it.

```sh
SELECT *
FROM inventory_end
WHERE brand_id = 2166
```

```sh
UPDATE purchase_2016
SET purchase_price = 54.99, dollars = ROUND(54.99*quantity,2)
WHERE brand_id = 2166
```

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/fa9ead01-b24a-4b4d-8b4d-2c81b202c700)

Check the information again after updating:

```sh
SELECT COUNT(*) as total_observation, COUNT(DISTINCT(inventory_id)) as number_inventory_id, 
		COUNT(DISTINCT(store_id)) AS number_store, COUNT(DISTINCT(brand_id)) AS number_brand, 
		COUNT(DISTINCT(description)) as number_description, MAX(purchase_price) as max_price, 
		MIN(purchase_price) as min_price, AVG(purchase_price) as avg_purchase_price
FROM purchase_2016
```

The new results show that the total purchases were spread across 80 stores with 9,645 different products. This quantity is larger than the inventory quantity, proving that **there are products that were purchased and sold during the year but were not updated in the inventory table. The company needs to introduce a more frequent and complete update policy**.
 
![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/3b723f0d-f2aa-4970-b83e-cf6a41284487)

- Table sales:

```sh
SELECT COUNT(*) as total_observation, COUNT(DISTINCT(inventory_id)) as number_inventory_id, 
		COUNT(DISTINCT(store_id)) AS number_store, COUNT(DISTINCT(brand_id)) AS number_brand, 
		COUNT(DISTINCT(description)) as number_description, MAX(sales_price) as max_price, MIN(sales_price) as min_price,
		 AVG(sales_price) as avg_sales_price, MAX(sales_date) as max_sales_date, MIN(excise_tax) as min_tax
FROM sales_2016
```

The results showed that in the first 2 months, the brand sold products across 79 stores with 6888 types of products sold, there was 1 store with no statistics, probably a newly opened store, store_id 81. 

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/8495f5a3-2b03-40cc-a1f7-5441e5734bc0)

Check the new store's statistics:

```sh
SELECT *
FROM sales_2016
WHERE store_id = 81
```

Indeed, this is a store without statistics. 

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/99f3ca90-a11c-4d8c-839e-0b63ec18cf23)

- Table invoice purchase:

```sh
SELECT COUNT(*) as total_observation, COUNT(DISTINCT(vendor_name)) AS number_vendor_name,
	COUNT(DISTINCT(vendor_number)) AS number_vendor, MAX(invoice_date) AS max_invoice_date,
	MIN(invoice_date) AS min_invoice_date, MIN(quantity) AS min_quantity, MAX(quantity) AS max_quantity,
	MIN(dollars) AS min_purchase, MAX(dollars) AS max_purchase, MIN(freight) AS min_freight,
	MAX(freight) AS max_freight
FROM invoice_purchase
WHERE YEAR(invoice_date) = 2016 
```

The results show that the number of vendor_name is 128 and number_vendor is 126. Normally 1 vendor_number will correspond to 1 vendor_name so there is a possibility of data error here.

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/cebf066f-4d89-43bf-8dc5-e015eb7da705)

```sh
SELECT vendor_number, vendor_name, SUM(dollars) as total_dollars, SUM(freight) as total_freight, MAX(dollars) as max_dollars, MAX(freight) as max_freight
FROM invoice_purchase
WHERE vendor_number IN 
(SELECT vendor_number
FROM invoice_purchase
GROUP BY vendor_number
HAVING COUNT(DISTINCT(vendor_name)) > 1) AND YEAR(invoice_date) = 2016
GROUP BY vendor_number, vendor_name
```

After checking, the author discovered that even though it is the same company, the vendor_name is different, so the author will update the data to the same name. Because the 2016 purchase table also has the same problem, I performed an update value on both 2 tables.

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/5b06d923-5aff-4b90-b217-4ae67da6a318)

```sh
UPDATE invoice_purchase
SET vendor_name = 'VINEYARD BRANDS INC'
WHERE vendor_number = 1587
```

```sh
UPDATE invoice_purchase
SET vendor_name = 'SOUTHERN GLAZERS WINE AND SPIRITS'
WHERE vendor_number = 2000
```

```sh
UPDATE purchase_2016
SET vendor_name = 'VINEYARD BRANDS INC'
WHERE vendor_number = 1587
```

```sh
UPDATE purchase_2016
SET vendor_name = 'SOUTHERN GLAZERS WINE AND SPIRITS'
WHERE vendor_number = 2000
```

Results after updating.

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/6b631adc-0177-44ca-ab75-21f051d65a54)

2.3.4. Calculate necessary data and join tables for analysis

- Calculate lead time:
```sh
ALTER TABLE purchase_2016
ADD lead_time INT NULL
```

```sh
UPDATE purchase_2016
SET lead_time = DATEDIFF(day, po_date, receiving_date)
```

- Calculate revenue after tax:

```sh
ALTER TABLE sales_2016
ADD dollars_after_tax FLOAT NULL
```

```sh
UPDATE sales_2016
SET dollars_after_tax = sales_dollars - excise_tax
```

- Create data tables to analyze lead time and reorder points:

```sh
SELECT *
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
) abc
ON abc.description = e.description 
AND abc.store_id = e.store_id
LEFT JOIN inventory_begin_group b
ON b.description = abc.description 
AND abc.store_id = b.store_id) total_group
```

## **2.4. Step 4: Analyze**

_2.4.1. Inventory Analysis_

Which product has the most inventory?

```sh
SELECT TOP 10 description, SUM(on_hand) as begin_on_hand
FROM inventory_begin
GROUP BY description
ORDER BY begin_on_hand DESC
```

```sh
SELECT TOP 10 description, SUM(on_hand) as end_on_hand
FROM inventory_end
GROUP BY description
ORDER BY end_on_hand DESC
```

- Beginning inventory:

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/ad4c474c-078b-4652-a132-bf83d9352e50)

- Ending inventory:

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/e1d310cf-e6ef-41d0-a1e8-898a0ebabd57)

 
- Smirnoff 80 Proof had the most inventory at the beginning of the year but by the end of the year had fallen out of the top 10. Smirnoff 80 Proof seems to have undergone a brand update or rebranding 
- Jack Daniels No 7 Black rose from 6th at the beginning of the year to 2nd, Ketel One Vodka from 10th to 6th, Jameson Irish Whiskey was not in the top 10 at the beginning of the year but was in 8th at the end of the year. This could imply an increased demand or higher restocking levels for these products during the year.
- The remaining products do not have much change in ranking.
--> **The overall high consistency among the top products suggests steady demand and effective inventory replenishment strategies for popular items.**

_2.4.2. Sales Analysis_

- Sales by description:

Which product has the highest sales volume?

```sh
SELECT TOP 10 description, SUM(sales_quantity) as total_sales_quantity
FROM sales_2016
GROUP BY description
ORDER BY total_sales_quantity DESC
```

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/4d02a896-1831-4315-b148-7ddf54aa47e4)

- **Smirnoff 80 Proof had the most total sales** in the first 2 months but by the end of the year, the inventory was not in the top 10. **The company may have inventory problems with this product.**

- Some products are in the top sales but not in the top 10 inventory: Dr. McGillicuddy's Mentholmnt, Yukon Jack, Smirnoff Raspberry Vodka, Tito's Handmade Vodka, Canadian Club. **Consider increasing the inventory of these products and decreasing the inventory of some products that are in the top inventory but not top sales**: Bacardi Superior Rum, Baileys Irish Cream, Ketel One Vodka, Kahlua, Jameson Irish Whiskey, Gray Goose Vodka.

- Sales by store_id:

Which store has the highest revenue and which store has the lowest revenue? 

```sh
SELECT TOP 5 store_id, ROUND(SUM(dollars_after_tax),2) as total_sales
FROM sales_2016
GROUP BY store_id
ORDER BY total_sales DESC
```

```sh
SELECT TOP 5 store_id, ROUND(SUM(dollars_after_tax),2) as total_sales
FROM sales_2016
GROUP BY store_id
ORDER BY total_sales
```

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/888904d8-e353-4d6d-b3d8-9729eafd2b5e)

The results show that in the first 2 months of the year, the store with the highest revenue is store 34. The store with the lowest revenue is store 3.

- Sales by month:

How was the revenue in January and February?

```sh
SELECT MONTH(sales_date) as month, ROUND(SUM(dollars_after_tax),2) as total_sales
FROM sales_2016
GROUP BY MONTH(sales_date)
ORDER BY total_sales
```

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/9230f961-dc75-4a64-add3-53a343481189)

**February sales dropped seriously. More specific analysis is needed to find the cause of the decrease.**
	
- Sales by city:

Which city has the largest revenue and which city has the smallest revenue?

```sh
SELECT TOP 5 e.city_name, ROUND(SUM(dollars_after_tax),2) as total_sales 
FROM sales_2016 s
LEFT JOIN inventory_end e
ON s.store_id = e.store_id
GROUP BY city_name
ORDER BY total_sales DESC
```

```sh
SELECT TOP 5 e.city_name, ROUND(SUM(dollars_after_tax),2) as total_sales 
FROM sales_2016 s
LEFT JOIN inventory_end e
ON s.store_id = e.store_id
GROUP BY city_name
ORDER BY total_sales
```

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/f0d71e4f-03d4-4b37-a31b-b69d357a7480)

The city of Mountmend generated the largest total revenue. Knife’s edge city brings in the lowest total revenue.

_2.4.3. Purchasing Analysis_

In terms of quantity (cost), which supplier does the company import the most products from?

```sh
SELECT TOP 5 vendor_name, SUM(quantity) as total_quantity
FROM purchase_2016
GROUP BY vendor_name
ORDER BY total_quantity DESC
```

```sh
SELECT TOP 5 vendor_name, ROUND(SUM(dollars),2) as total_dollars
FROM purchase_2016
GROUP BY vendor_name
ORDER BY total_dollars DESC
```

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/c93bea1a-7893-406b-a759-aef1148b9f66)

- DIAGEO NORTH AMERICA INC stands out as the top vendor with the highest total cost, amounting to 50,959,796.85 US dollars.
- The following two vendors,  MARTIGNETTI COMPANIES' and 'JIM BEAM BRANDS COMPANY', have notable purchase costs of 27,861,690.02 and 24,203,151.05, respectively.
- The top 3 companies by quantity are also the top 3 companies by total cost.
- It's interesting to see that the top 5 vendors have a significant difference in their purchase costs, with 'DIAGEO NORTH AMERICA INC' nearly leading double total cost from the vendor in the second position.

_2.4.4. Combine analysis of sales and purchasing tables_

```sh
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
```

![image](https://github.com/nhungly2805/inventory-analysis/assets/128270865/c8ebf331-4c38-4801-b2c3-ab44f7de9a95)

- **The companies in the top 10 best sellers by volume are also the companies in the top 10 by revenue, except for two brands, Crown Royal and Smirnoff 80 Proof. Most products sell more than half of the purchased amount.**
- Although Crown Royal has a relatively low sales volume, it is in the top 10 brands with the highest revenue, this can be a high-end brand. Meanwhile, Smirnoff 80 Proof with the largest sales volume of 43,423 has a rather modest position in the top 12 in terms of revenue.
- Capt Morgan Spiced Rum and Jack Daniels No 7 Black make an outstanding impression when they are in the top 2 brands bringing in the largest revenue, **each brand accounting for 1.8% and 1.7% of total revenue respectively**.

_2.4.5. Lead time và reorder point analysis_

Finally, the author calculates lead time and reorder point for each store based on the formula presented in Step 2.

```sh
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
```

**Each store can consider which additional products they need to order by looking at the order_quantity column. If the order_quantity column > 0, you need to order more of that product immediately**. Stores can review their business situation with the following command, replacing store_id with the id of their store. For example, here the author wants to consider the situation of store_id 3.

```sh
SELECT *
FROM abc_group
WHERE store_id = 3
ORDER BY store_id, total_dollars_after_tax DESC
```

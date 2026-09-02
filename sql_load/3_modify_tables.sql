/*
⚠️ Database Load Issues (follow if receiving permission denied when running COPY below)
 
NOTE: If you get error:
'could not open file "[your file path]\...csv" for reading: Permission denied.'
 
1. Open pgAdmin
2. In Object Explorer, navigate to the `olist_ecommerce` database
3. Right-click it and select `PSQL Tool` (opens a terminal window)
4. Get the absolute file path of your csv files
   (right-click a CSV file in VS Code and select "Copy Path")
5. Paste the following into `PSQL Tool`, with the CORRECT file path:
 
\copy customers FROM 'csv_files/olist_customers_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
\copy sellers FROM 'csv_files/olist_sellers_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
\copy product_category_name_translation FROM 'csv_files/product_category_name_translation.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
\copy products FROM 'csv_files/olist_products_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
\copy orders FROM 'csv_files/olist_orders_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
\copy order_items FROM 'csv_files/olist_order_items_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
\copy order_payments FROM 'csv_files/olist_order_payments_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
\copy order_reviews FROM 'csv_files/olist_order_reviews_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
\copy geolocation FROM 'csv_files/olist_geolocation_dataset.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
 
*/
 
-- NOTE: Import order matters — tables with foreign keys must be loaded
-- AFTER the tables they reference (see comments below).
 
-- 1. No dependencies
COPY customers
FROM '\csv_files\olist_customers_dataset.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
 
COPY sellers
FROM 'csv_files/olist_sellers_dataset.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
 
COPY product_category_name_translation
FROM '\csv_files\product_category_name_translation.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
 
COPY geolocation
FROM 'csv_files/olist_geolocation_dataset.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
 
-- 2. Depends on product_category_name_translation
COPY products
FROM 'csv_files/olist_products_dataset.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
 
-- 3. Depends on customers
COPY orders
FROM 'csv_files/olist_orders_dataset.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
 
-- 4. Depends on orders, products, sellers
COPY order_items
FROM 'csv_files/olist_order_items_dataset.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
 
-- 5. Depends on orders
COPY order_payments
FROM 'csv_files/olist_order_payments_dataset.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
 
-- 6. Depends on orders
COPY order_reviews
FROM 'csv_files/olist_order_reviews_dataset.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
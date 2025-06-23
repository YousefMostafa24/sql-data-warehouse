/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/


-- Create Dimension: gold.dim_customers
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
 SELECT 
	 ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
	 CI.cst_id AS customer_id,
	 CI.cst_key AS customer_number,
	 CI.cst_firstname AS first_name,
	 CI.cst_lastname AS last_name,
	 LA.cntry AS country,
	 CI.cst_material_status AS material_status,
	 CASE WHEN CI.cst_gndr !='UnKnown' THEN CI.cst_gndr
		ELSE COALESCE(CA.gen, 'UnKnown')
	 END AS gender,
	 CA.bdate AS birthdate,
	 CI.cst_create_date AS create_date
 FROM silver.crm_cust_info CI LEFT JOIN silver.erp_cust_az12 CA
 ON	CI.cst_key = CA.cid
 LEFT JOIN silver.erp_loc_a101 LA
 ON  CI.cst_key = LA.cid
 GO


  
-- Create Dimension: gold.dim_products
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY PN.prd_start_dt,PN.prd_key) AS product_key,
	PN.prd_id AS product_id ,
	PN.prd_key AS product_number,
	PN.prd_nm AS product_name,
	PN.cat_id AS category_id,
	PC.cat AS category,
	PC.subcat AS subcategory,
	PC.maintenance,
	PN.prd_cost AS cost,
	PN.prd_line AS product_line,
	PN.prd_start_dt AS start_date
FROM silver.crm_prd_info PN LEFT JOIN silver.erp_px_cat_g1v2 PC
ON PN.cat_id = PC.id
WHERE prd_end_dt IS NULL
GO




-- Create Fact Table: gold.fact_sales
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
	DROP VIEW gold.fact_sales
GO

CREATE VIEW gold.fact_sales AS
SELECT 
	S.sls_ord_num AS order_number,
	PR.product_key,
	CU.customer_key,
	S.sls_order_dt AS order_date,
	S.sls_ship_dt AS shipping_date,
	S.sls_due_dt AS due_date,
	S.sls_sales AS sales_amount,
	S.sls_quantity AS quanity,
	S.sls_price AS price 
FROM silver.crm_sales_details S LEFT JOIN gold.dim_products PR
ON S.sls_prd_key = PR.product_number
LEFT JOIN gold.dim_customers CU
ON S.sls_cust_id = CU.customer_id
GO



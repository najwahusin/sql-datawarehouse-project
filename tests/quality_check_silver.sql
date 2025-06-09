-- ======================================================
-- Quality Check
-- ======================================================

-- This scripts perform multiple quality check on the datasets to assure the accuracy of data for future analysis.

-- ======================================================
-- Quality Check in silver.crm_cust_info
-- ======================================================

-- Check duplicates and NULL using P.Key. Expectation: No Result

SELECT
	cst_id,
	COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check unwanted spaces. Expectation: No Result

SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)  

-- Data Standardization & Consistency. Expectation: No Result

SELECT DISTINCT cst_material_status
FROM silver.crm_cust_info

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT * FROM silver.crm_cust_info;

-- ======================================================
-- Quality Check silver.crm_prd_info
-- ======================================================

-- Check for unwanted spaces. Expectation: No Result

SELECT 
	prd_id,
	COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted spaces

SELECT prd_nme
FROM silver.crm_prd_info
WHERE prd_nme != TRIM(prd_nme)			-- No unwanted spaces

-- Check for NULLs or negative numbers in prd_cost

SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Data Standardization & Consistency

SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- Check invalid date orders

SELECT * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

-- Overall Quality Check

SELECT * 
FROM silver.crm_prd_info;

-- ======================================================
-- Quality Check of silver.crm_sales_details
-- ======================================================

-- Check for NULLs and duplicates in sls_ord_num
SELECT
	sls_ord_num,
	COUNT(*)
FROM silver.crm_sales_details
GROUP BY sls_ord_num
HAVING COUNT(*) > 1 OR sls_ord_num IS NULL;	-- No NULLs and duplicates

-- Check for unwanted spaces
SELECT *
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)			-- No unwanted spaces

-- Check for matching sls_prd_key and prd_key in bronze.crm_prd_info
SELECT *
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN 
(SELECT prd_key FROM bronze.crm_prd_info)

-- Check for matching sls_cust_id and prd_key in bronze.crm_cust_info
SELECT *
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN 
(SELECT cst_id FROM bronze.crm_cust_info)

-- Data Standardization & Consistency
SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price

SELECT * FROM silver.crm_sales_details;

-- ======================================================
-- Quality Check in silver.erp_cust_az12
-- ======================================================

--Check for unwanted character
SELECT
	cid,
	bdate,
	gndr
FROM silver.erp_cust_az12
WHERE cid NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info);

-- Identifying out of range dates
SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Data standardization & consistency
SELECT DISTINCT 
	gndr
FROM silver.erp_cust_az12

SELECT * FROM silver.erp_cust_az12;

-- ======================================================
-- Quality Check in silver.erp_cust_az12
-- ======================================================

--Check for mismatch cid and_cst_key
SELECT
	REPLACE(cid, '-', '') cid
FROM silver.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN 
(SELECT cst_key FROM silver.crm_cust_info)

-- Data standardization & consistency
SELECT DISTINCT cntry
FROM silver.erp_loc_a101

SELECT * FROM silver.erp_loc_a101;

-- ======================================================
-- Quality Check in silver.erp_cust_az12
-- ======================================================

-- Check for unwanted spaces
SELECT *
FROM silver.erp_px_cat_giv2
WHERE cat != TRIM(cat) 
OR subcat != TRIM(subcat) 
OR maintenance != TRIM(maintenance)

-- Data standardization & consistency
SELECT DISTINCT cat
FROM silver.erp_px_cat_giv2

SELECT DISTINCT subcat
FROM silver.erp_px_cat_giv2

SELECT DISTINCT maintenance
FROM silver.erp_px_cat_giv2

SELECT * FROM silver.erp_px_cat_giv2;

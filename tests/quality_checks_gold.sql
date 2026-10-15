
/*
===============================================================================
Quality Checks: Gold Layer
===============================================================================
Script Purpose:
    This script performs data quality checks to validate the integrity,
    consistency, and reliability of the Gold Layer views in the Data Warehouse.

Checks Performed:
    - Verifies the uniqueness of surrogate keys in the customer dimension.
    - Verifies the uniqueness of surrogate keys in the product dimension.
    - Checks referential integrity between the sales fact view and the
      customer and product dimension views.
    - Identifies sales records that do not have matching customer or product
      dimension records.

Views Reviewed:
    - gold.dim_customers
    - gold.dim_products
    - gold.fact_sales

Usage Notes:
    - Run these checks after creating or updating the Gold Layer views.
    - The uniqueness checks should return no results if surrogate keys are unique.
    - The fact-to-dimension relationship check identifies sales records whose
      customer or product keys do not match the corresponding dimension views.
    - Investigate and resolve any discrepancies found during the checks before
      using the data for analytics and reporting.

Note:
    These queries inspect and report potential data quality issues. They do not
    automatically modify or correct the data.
===============================================================================
*/

-- ====================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================
-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No results
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.dim_products'
-- ====================================================================
-- Check for Uniqueness of Product Key in gold.dim_products
-- Expectation: No results
SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================
-- Check the data model connectivity between fact and dimensions
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL;

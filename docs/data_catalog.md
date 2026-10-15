# Data Catalog for Gold Layer

## Overview

The Gold Layer represents the business-ready data layer of the Data Warehouse. It provides structured datasets designed to support analytical queries, reporting, and business intelligence.

The layer consists of customer and product dimensions, along with a sales fact view. These views follow a Star Schema approach by connecting sales transactions with descriptive customer and product information from the Silver Layer.

---

### 1. `gold.dim_customers`

**Purpose:** Provides customer information enriched with demographic and geographic attributes from CRM and ERP data sources. It includes a surrogate key for analytical relationships and prioritizes CRM gender information, using ERP data as a fallback when necessary.

**Columns:**

| Column Name | Data Type | Description |
|---|---|---|
| `customer_key` | INT | Surrogate key generated using `ROW_NUMBER()` to identify customer records in the dimension view. |
| `customer_id` | INT | Customer identifier originating from the CRM source. |
| `customer_number` | NVARCHAR(50) | Customer business identifier used to match customer information across source systems. |
| `first_name` | NVARCHAR(50) | Customer's first name, obtained from the CRM customer information. |
| `last_name` | NVARCHAR(50) | Customer's last name, obtained from the CRM customer information. |
| `country` | NVARCHAR(50) | Customer's country information obtained from the ERP location data. |
| `marital_status` | NVARCHAR(50) | Customer's marital status, such as Single or Married, as standardized in the Silver Layer. |
| `gender` | NVARCHAR(50) | Customer's gender. CRM is the primary source, and ERP gender is used as a fallback when the CRM value is `'n/a'`. |
| `birthdate` | DATE | Customer's date of birth obtained from the ERP customer demographic data. |
| `create_date` | DATE | Date when the customer record was created in the CRM source. |

---

### 2. `gold.dim_products`

**Purpose:** Provides product information enriched with category, subcategory, and maintenance attributes from ERP data. The view includes currently valid product records and assigns a surrogate key to each product record.

**Columns:**

| Column Name | Data Type | Description |
|---|---|---|
| `product_key` | INT | Surrogate key generated using `ROW_NUMBER()` to identify product records in the dimension view. |
| `product_id` | INT | Internal product identifier originating from the CRM product information. |
| `product_number` | NVARCHAR(50) | Product business identifier used to associate products with sales transactions. |
| `product_name` | NVARCHAR(50) | Descriptive name of the product. |
| `category_id` | NVARCHAR(50) | Identifier of the product category, derived from the CRM product key. |
| `category` | NVARCHAR(50) | High-level product classification obtained from the ERP product category data. |
| `subcategory` | NVARCHAR(50) | More specific product classification obtained from the ERP product category data. |
| `maintenance` | NVARCHAR(50) | Maintenance-related attribute associated with the product category in the ERP source. |
| `cost` | INT | Product cost obtained from the CRM product information. Missing costs are standardized to zero in the Silver Layer. |
| `product_line` | NVARCHAR(50) | Product line classification, such as Mountain, Road, Other Sales, or Touring. |
| `start_date` | DATE | Date when the product record became valid, based on the product start date. |

---

### 3. `gold.fact_sales`

**Purpose:** Provides sales transaction data for analytical and reporting purposes. The view combines sales measures and transaction dates with surrogate keys from the customer and product dimensions, enabling analysis by customer, product, and time.

**Columns:**

| Column Name | Data Type | Description |
|---|---|---|
| `order_number` | NVARCHAR(50) | Identifier of the sales order associated with the transaction. |
| `product_key` | INT | Surrogate key linking the sales transaction to `gold.dim_products`. |
| `customer_key` | INT | Surrogate key linking the sales transaction to `gold.dim_customers`. |
| `order_date` | DATE | Date when the sales order was placed. |
| `shipping_date` | DATE | Date associated with shipping the order. |
| `due_date` | DATE | Due date associated with the sales transaction. |
| `sales_amount` | INT | Sales amount associated with the transaction line, based on the cleansed sales data. |
| `quantity` | INT | Number of product units associated with the sales transaction line. |
| `price` | INT | Unit price associated with the sales transaction line, based on the cleansed sales data. |

---

## Notes

- The Gold views are built on top of the Silver Layer tables.
- `customer_key` and `product_key` are generated surrogate keys used to connect the dimensions with the sales fact view.
- The product dimension excludes historical product records by filtering for records where `prd_end_dt IS NULL`.
- The customer and product dimensions enrich source attributes by integrating information from CRM and ERP data.
- The data types documented above reflect the SQL view definitions and their underlying source columns.
- `gold.fact_sales` is a view rather than a physical table, although it serves as the fact component of the Star Schema.

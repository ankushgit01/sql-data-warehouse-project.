# Data Model

## 1. Architecture

The project uses a three-layer Medallion architecture implemented as separate MySQL databases:

- Bronze — raw source ingestion
- Silver — cleaned and standardized data
- Gold — analytics-ready views

```
CRM CSVs -> Bronze -> Silver -> Gold
ERP CSVs --------------------^
```

## 2. Bronze layer

Raw source tables:

- `bronze.crm_cust_info`
- `bronze.crm_prd_info`
- `bronze.crm_sales_details`
- `bronze.erp_cust_az12`
- `bronze.erp_loc_a101`
- `bronze.erp_px_cat_g1v2`

Bronze keeps source fields close to their original structure. The customer create-date loader has one explicit exception: the source value `0000-00-00` is converted to `NULL` because MySQL strict mode rejects it as a DATE.

## 3. Silver layer

Cleaned tables:

- `silver.crm_cust_info`
- `silver.crm_prd_info`
- `silver.crm_sales_details`
- `silver.erp_cust_az12`
- `silver.erp_loc_a101`
- `silver.erp_px_cat_g1v2`

Key transformations:

- trimming whitespace
- standardizing marital status and gender
- retaining the latest CRM customer record per `cst_id`
- normalizing product category and product keys
- deriving product validity windows with `LEAD()`
- converting YYYYMMDD integers into DATE values
- reconciling inconsistent sales and price values
- normalizing ERP customer/location identifiers
- deduplicating ERP customer/location/category business keys
- preventing future ERP birth dates from entering Silver

## 4. Gold layer

Gold is implemented as views using a star-schema-style model.

### `gold.dim_customers`

One row per customer.

Key columns:

- `customer_key` — analytical surrogate key
- `customer_id` — CRM customer ID
- `customer_number` — business customer key
- `first_name`, `last_name`
- `country`
- `marital_status`
- `gender`
- `birthdate`
- `create_date`

### `gold.dim_products`

One row per product business key, using the latest Silver product version.

Key columns:

- `product_key` — analytical surrogate key
- `product_id`
- `product_number`
- `product_name`
- `category_id`
- `category`
- `subcategory`
- `maintenance`
- `cost`
- `product_line`
- `start_date`

Historical product versions remain in `silver.crm_prd_info`.

### `gold.fact_sales`

One row per sales transaction line.

Columns:

- `order_number`
- `customer_key`
- `product_key`
- `order_date`
- `shipping_date`
- `due_date`
- `sales_amount`
- `quantity`
- `price`

The fact view uses LEFT JOIN to retain unmapped transactions so Gold quality checks can detect missing dimension references.

## 5. Relationships

```
dim_customers (1) -> fact_sales (*) <- (1) dim_products
```

## 6. Design decisions

### Customer integration

CRM customer attributes are preferred. ERP gender is used as a fallback when CRM gender is unavailable.

### Product integration

Silver keeps product history. Gold exposes the latest row for each `prd_key` so there is one dimension row per product business key for this portfolio model and fact joins remain straightforward.

### Surrogate keys

Gold keys are generated with `ROW_NUMBER()`. They are deterministic for the current source snapshot but are not persistent warehouse keys across arbitrary source changes.

### MySQL layer namespaces

Because MySQL uses databases rather than nested schemas, `bronze`, `silver`, and `gold` are separate databases that act as the project's layer namespaces.

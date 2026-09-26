# Data model

## Medallion architecture

### Bronze

Raw source tables:
- `bronze.crm_cust_info`
- `bronze.crm_prd_info`
- `bronze.crm_sales_details`
- `bronze.erp_cust_az12`
- `bronze.erp_loc_a101`
- `bronze.erp_px_cat_g1v2`

### Silver

Cleaned and standardized tables. Transformations include trimming text, standardizing status/gender, deduplicating CRM customers, converting YYYYMMDD integers to DATE values, correcting sales/price inconsistencies, and normalizing ERP identifiers.

### Gold

The Gold layer is a view-based star schema:

- `gold.dim_customers` — one row per customer.
- `gold.dim_products` — one row per active product.
- `gold.fact_sales` — sales transaction lines.

```text
gold.dim_customers  1 ───────< gold.fact_sales >─────── 1  gold.dim_products
       customer_key                         product_key
```

## Key design decisions

- Gold uses surrogate keys generated with `ROW_NUMBER()` for analytical joins.
- CRM customer attributes take priority; ERP gender is used as a fallback.
- Only active products (`prd_end_dt IS NULL`) are exposed in `dim_products`.
- Fact-to-dimension joins remain `LEFT JOIN`s so missing mappings can be detected by Gold quality checks rather than silently removing transactions.

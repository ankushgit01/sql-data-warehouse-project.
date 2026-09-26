# Data Quality Rules

The project treats data quality as part of the pipeline rather than a final manual step.

## Bronze

Bronze checks focus on ingestion integrity:

- source row counts
- null primary/source identifiers
- obviously invalid integer date values
- successful loading of all six checked-in CSV files

Bronze is intentionally close to the source. The one ingestion exception is the CRM customer date value `0000-00-00`, which MySQL strict mode cannot store as a DATE. The loader converts that known value to `NULL`.

## Silver

Silver checks validate:

- unique customer IDs after deduplication
- trimmed business/customer attributes
- controlled values for marital status and gender
- nonnegative product cost
- valid product date windows
- controlled product-line values
- positive sales, quantity, and price
- sales reconciliation against quantity x price
- no future ERP birth dates
- normalized ERP customer/location/category keys

Source anomalies are not silently discarded. The quality-check SQL returns the affected rows so the transformation can be reviewed.

## Gold

Gold checks validate:

- unique customer surrogate keys
- unique product surrogate keys
- unique customer/product business keys
- fact-to-dimension mapping
- required fact fields
- positive and reconciled measures
- date ordering where both dates are present

The fact model uses LEFT JOINs so missing dimension mappings remain visible to the quality checks instead of disappearing from the analytical layer.

## CI policy

GitHub Actions runs the complete MySQL pipeline on pushes and pull requests targeting `main`.

CI fails on critical structural or measure-quality violations, including:

- missing customer or product keys in Silver
- invalid sales measures
- duplicate Gold business keys
- unmapped customer/product references in Gold
- missing critical fact values
- sales reconciliation failures

Known source order-date anomalies are reported separately. This keeps the pipeline transparent without manufacturing dates that were not present in the source.

## Known source characteristics

The checked-in source snapshot contains historical and imperfect data, including:

- zero/invalid source order dates
- some missing sales or prices
- some sales/price inconsistencies
- historical product records with inconsistent source validity dates
- minor whitespace and coding inconsistencies

Those characteristics are intentionally useful for demonstrating data cleansing, validation, and transformation logic in a portfolio project.

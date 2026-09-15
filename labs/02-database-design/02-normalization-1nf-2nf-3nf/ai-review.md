# AI Review — normalization-1nf-2nf-3nf

Review of `my-work.md` (Attempt: Problems 1-3). The resulting schema was
also deployed for real to `dbeng-lab-postgres` (schema `lab_02_02`), seeded
with the exercise's own sample data, and the three anomalies from Problem 1
were re-tested live against it. Raw output in
`evidence/normalized_schema_test.txt`.

## Problem 1 — anomalies

All three anomalies are correct in the final version, and — unlike the
first pass — grounded in the actual sample data rather than described in
the abstract:

- **Update**: `UPDATE sales_flat SET product_category = 'xxx' WHERE
  invoice_no = 'INV-002'` correctly shown to leave `INV-001`'s copy of
  `CEM-001` with the old category, since the same product's category is
  duplicated across every invoice it appears on.
- **Insert**: correctly identified that the table conflates two
  independent entities (product master data and sale events) into one
  row, so a new product with no sale yet has nowhere to live without
  fabricating sale-side data.
- **Delete**: first draft claimed deleting a row for a departing
  salesperson would "delete the product from the system," which doesn't
  hold up against the actual sample data (`CEM-001` also appears in
  `INV-001`, so it survives). Corrected to the accurate claim: deleting
  the one row where `salesperson_name = 'Boat'` also erases the only
  record of customer `Apex Builders`, since neither appears anywhere else
  in the sample data — checked against the actual rows rather than
  asserted.

## Problem 2 — normalization

This took several passes, and the corrections are worth recording
honestly rather than smoothing over, since they trace one coherent gap in
reasoning about composite keys:

1. **First 2NF attempt was conceptually wrong.** Claimed `invoice` was a
   single-column candidate key with no partial dependency to worry about.
   `INV-001` appears twice in the sample data (once per product), so
   `invoice_no` alone doesn't identify a row — the actual key is
   `(invoice_no, product_code)`. Self-corrected once asked to check
   `invoice_no` alone against the sample data.

3. **`unit_price` in two tables, correctly reasoned as not redundant.**
   Once prompted to compare against `order_items.unit_price` in
   `labs/01-sql/01-joins-and-aggregation/setup/schema.sql` (which carries
   the comment "price at time of order, may differ from
   products.unit_price today"), correctly concluded `product.unit_price`
   (current price) and `invoice_item.unit_price` (price at time of sale)
   are two different facts that happen to share a name — not a
   normalization violation, since 3NF/BCNF only prohibit duplicating the
   *same* fact.
4. **2NF/3NF were initially conflated** — all of the composite-key
   partial-dependency work (extracting `customer`, `salesperson`,
   `product`'s core columns, and separating `invoice` from `invoice_item`)
   was first written under a "3NF" heading alongside the one genuine 3NF
   fix (extracting `category` because `category_discount_pct` depends on
   `product_category`, not on `product_code` directly — a transitive
   dependency). Correctly reorganized once the 2NF-vs-3NF distinction
   (partial dependency on part of a composite key vs. transitive
   dependency between two non-key attributes) was named explicitly.

Final table set (`customer`, `product`, `category`, `salesperson`,
`invoice`, `invoice_item`) is correct, matches the FD analysis, and — see
Experiment below — actually holds up when built for real.

## Problem 3 — denormalize anyway?

Landed on keeping `product_name` cached in `invoice_item` as a
point-in-time snapshot, on the same reasoning as `invoice_item.unit_price`
— correct and consistent. The first draft also cited "performance" as a
second justification without a concrete read pattern behind it; once
pushed to name one, honestly concluded performance doesn't actually
justify it here (`product_code` is a PK, the join is cheap) and kept the
snapshot/historical-correctness argument alone. Notable that the
correction was appended as a parenthetical next to the original claim
rather than silently deleting it — consistent with this repo's own
"preserve mistakes, append corrections" rule, applied unprompted to their
own working notes.

## Experiment

Built the Problem 2 schema for real (`lab_02_02`, 6 tables), seeded it
with the exercise's own sample data, and confirmed the join back through
`invoice_item -> invoice -> customer` and `invoice_item -> product ->
category` reconstructs the original 4-row `sales_flat` sample exactly —
no data lost in the decomposition. Then re-ran each Problem 1 anomaly
scenario against the live schema:

- Update: changing `category.category_discount_pct` for Cement took one
  `UPDATE` on one row; every product under that category reflects it
  immediately through the join.
- Insert: a brand-new product (`TOL-006`) was inserted with zero
  `invoice_item` rows, no fabricated sale data required.
- Delete: removing the one `invoice_item` row involving salesperson
  "Boat" and customer "Apex Builders" left both of their master records
  intact in `customer`/`salesperson`.

All three confirmed live, not just argued from the DDL.

## Overall

Correct end state on all three problems. The real value in this attempt
was in the process, not just the destination — every substantive error
(the wrong 2NF key, the missing line-item table, the misplaced
quantity/unit_price dependency, the 2NF/3NF mislabeling) was caught
through direct confrontation with the sample data rather than abstract
rule recitation, and each fix stuck without needing to be re-explained
once the underlying data was pointed to. The repeated quantity/unit_price
misplacement (three separate times across the session) suggests composite
keys specifically — distinguishing "depends on part of the key" from
"depends on the whole key" — is still the least stable part of this
lab's understanding and worth a quick follow-up check later, even though
the final answer is correct.

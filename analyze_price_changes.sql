-- 1. Create the temporary table to track price changes over time
CREATE TEMP TABLE price_changes AS (
  SELECT
    product_id,
    list_price_converged,
    total_ordered_pieces,
    total_net_sales,
    first_price_date,
    LAG(list_price_converged) OVER(PARTITION BY product_id ORDER BY first_price_date ASC) AS previous_list,
    LAG(total_ordered_pieces) OVER(PARTITION BY product_id ORDER BY first_price_date ASC) AS previous_total_ordered_pieces,
    LAG(total_net_sales) OVER(PARTITION BY product_id ORDER BY first_price_date ASC) AS previous_total_net_sales,
    LAG(first_price_date) OVER(PARTITION BY product_id ORDER BY first_price_date ASC) AS previous_first_price_date
  FROM (
    SELECT
      product_id,
      list_price_converged,
      SUM(invoiced_quantity_in_pieces) AS total_ordered_pieces, 
      SUM(net_sales) AS total_net_sales, 
      MIN(fiscal_date) AS first_price_date
    FROM `lookml-agentic-20260621.Pricing_CDM.CDM_Pricing_Large_Table`
    GROUP BY 1, 2
    ORDER BY 1, 2 ASC
  )
);

-- 2. View the price changes
SELECT * FROM price_changes 
WHERE previous_list IS NOT NULL 
ORDER BY product_id, first_price_date DESC;

-- 3. Calculate the average price change across SKUs
SELECT 
  AVG((previous_list - list_price_converged) / NULLIF(previous_list, 0)) * 100 AS average_price_change 
FROM price_changes;

-- 4. Analyze the relationship between price changes and order volume
SELECT
  (total_ordered_pieces - previous_total_ordered_pieces) / NULLIF(previous_total_ordered_pieces, 0) AS price_changes_percent_ordered_change,
  (list_price_converged - previous_list) / NULLIF(previous_list, 0) AS price_changes_percent_price_change
FROM price_changes;

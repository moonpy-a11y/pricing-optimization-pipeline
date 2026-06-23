-- STEP 1: Unpivot monthly price columns
-- Converts wide columns (Jan, Feb, Mar) into long rows (Price_Date, Price)
WITH unpivoted_pricing AS (
  SELECT 
    Product_Code, 
    Price_Date, 
    Price
  FROM `lookml-agentic-20260621.Pricing_CDM.Raw_Pricing_Data`
  UNPIVOT(Price FOR Price_Date IN (Jan, Feb, Mar))
),

-- STEP 2: Calculate the average transaction value by client, product, and date
-- Using a Window Function to group by as a new column (retaining row-level details)
transaction_aggregates AS (
  SELECT 
    Client_ID,
    SKU,
    Fiscal_Date,
    Gross_Sales,
    Invoiced_quantity_in_Pieces,
    AVG(Gross_Sales) OVER(PARTITION BY Client_ID, SKU, Fiscal_Date) AS Avg_Transaction_Value
  FROM `lookml-agentic-20260621.Pricing_CDM.Clean_Transaction_Data`
)

-- STEP 3: Join pricing data
-- Combines the transactional data with the unpivoted pricing data
SELECT 
  t.*,
  p.Price AS List_Price_Converged
FROM transaction_aggregates t
LEFT JOIN unpivoted_pricing p
  ON t.SKU = p.Product_Code 
  AND t.Fiscal_Date = p.Price_Date;

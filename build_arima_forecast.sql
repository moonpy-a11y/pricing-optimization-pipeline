-- 1. Create or replace the ARIMA_PLUS Time Series model
CREATE OR REPLACE MODEL `lookml-agentic-20260621.Pricing_CDM.bqml_arima`
OPTIONS (
  model_type = 'ARIMA_PLUS',
  time_series_timestamp_col = 'fiscal_date',
  time_series_data_col = 'total_quantity',
  time_series_id_col = 'product_id',
  auto_arima = TRUE,
  data_frequency = 'AUTO_FREQUENCY',
  decompose_time_series = TRUE
) AS
SELECT
  fiscal_date,
  product_id,
  SUM(invoiced_quantity_in_pieces) AS total_quantity
FROM `lookml-agentic-20260621.Pricing_CDM.CDM_Pricing_Large_Table`
GROUP BY 1, 2;

-- 2. Use ML.FORECAST to predict the next 30 days of sales volume
SELECT * FROM ML.FORECAST(
  MODEL `lookml-agentic-20260621.Pricing_CDM.bqml_arima`,
  STRUCT(30 AS horizon, 0.8 AS confidence_level)
);

-- 3. Simulate future revenue based on forecasted quantities and recent prices
SELECT
  SUM(forecast_value * list_price) AS total_revenue
FROM ML.FORECAST(
  MODEL `lookml-agentic-20260621.Pricing_CDM.bqml_arima`,
  STRUCT(30 AS horizon, 0.8 AS confidence_level)
) AS forecasts
LEFT JOIN (
  SELECT 
    product_id,
    ARRAY_AGG(list_price_converged ORDER BY fiscal_date DESC LIMIT 1)[OFFSET(0)] AS list_price
  FROM `lookml-agentic-20260621.Pricing_CDM.CDM_Pricing_Large_Table` 
  GROUP BY 1
) AS recent_prices
USING (product_id);

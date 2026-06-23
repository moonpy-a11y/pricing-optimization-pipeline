view: arima_model {
  derived_table: {
    persist_for: "24 hours"
    sql_create:
      create or replace model ${sql_table_name}
            options
              (model_type = 'arima_plus',
               time_series_timestamp_col = 'fiscal_date',
               time_series_data_col = 'total_quantity',
               time_series_id_col = 'product_id',
               auto_arima = true,
               data_frequency = 'auto_frequency',
               decompose_time_series = true
              ) as
            select
              fiscal_date,
              product_id,
              sum(invoiced_quantity_in_pieces) as total_quantity
            from
              ${cdm_pricing.sql_table_name}
            group by 1,2 ;;
  }
}

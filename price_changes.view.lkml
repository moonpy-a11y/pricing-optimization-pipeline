view: price_changes {
  derived_table: {
    sql: select
        product_id,
        list_price_converged,
        total_ordered_pieces,
        total_net_sales,
        first_price_date,
        lag(list_price_converged) over(partition by product_id order by first_price_date asc) as previous_list,
        lag(total_ordered_pieces) over(partition by product_id order by first_price_date asc) as previous_total_ordered_pieces,
        lag(total_net_sales) over(partition by product_id order by first_price_date asc) as previous_total_net_sales,
        lag(first_price_date) over(partition by product_id order by first_price_date asc) as previous_first_price_date
        from (
      select
         product_id,list_price_converged,sum(invoiced_quantity_in_pieces) as total_ordered_pieces, sum(net_sales) as total_net_sales, min(fiscal_date) as first_price_date
      from ${cdm_pricing.SQL_TABLE_NAME}  AS cdm_pricing
      group by 1,2
      order by 1, 2 asc
      )
       ;;
  }
}

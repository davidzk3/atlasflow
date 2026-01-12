{{ config(materialized='view') }}

select
  cast(block_time as timestamp) as block_time,
  lower(chain) as chain,
  tx_hash,
  cast(log_index as integer) as log_index,
  cast(block_number as bigint) as block_number,
  lower(project) as project,
  lower(version) as version,
  lower(token_in) as token_in,
  lower(token_out) as token_out,
  cast(amount_in as double) as amount_in,
  cast(amount_out as double) as amount_out,
  cast(amount_usd as double) as amount_usd,
  lower(trader) as trader
from read_csv_auto(
  'C:\\Users\\David\\atlasflow\\data\\raw\\dune\\evm_uniswap_swaps_eth_arb.csv',
  header=true
)

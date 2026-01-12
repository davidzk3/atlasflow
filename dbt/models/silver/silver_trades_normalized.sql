{{ config(materialized='view') }}

select
  date_trunc('day', block_time) as date,
  chain,
  tx_hash,
  log_index,

  trader as wallet_address,

  'dex_swap' as event_type,
  project as venue,
  version,

  token_in,
  token_out,

  amount_in,
  amount_out,
  amount_usd

from {{ ref('bronze_uniswap_swaps') }}
where trader is not null

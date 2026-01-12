{{ config(materialized='table') }}

select
  date,
  chain,
  wallet_address,

  count(distinct tx_hash) as transaction_count,
  count(*) as swap_count,

  count(distinct token_in)
    + count(distinct token_out) as unique_tokens_touched,

  sum(amount_usd) as total_volume_usd,
  avg(amount_usd) as avg_trade_usd,
  max(amount_usd) as max_trade_usd

from {{ ref('silver_trades_normalized') }}
group by 1,2,3

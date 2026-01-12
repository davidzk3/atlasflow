{{ config(materialized='view') }}

select
  date_trunc('day', block_time) as date,
  block_time,
  bridge,
  source_chain,
  destination_chain,
  tx_hash,
  sender as wallet_address,
  recipient,
  token_symbol,
  amount,
  amount_usd
from {{ ref('bronze_bridge_flows') }}
where wallet_address is not null

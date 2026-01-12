{{ config(materialized='table') }}

select
  date,
  bridge,
  source_chain,
  destination_chain,
  count(distinct wallet_address) as unique_wallets,
  count(distinct tx_hash) as tx_count,
  sum(amount_usd) as total_amount_usd
from {{ ref('silver_bridge_events_normalized') }}
group by 1,2,3,4

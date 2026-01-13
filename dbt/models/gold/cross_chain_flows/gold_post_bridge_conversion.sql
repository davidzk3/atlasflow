{{ config(materialized='table') }}

with bridge_ins as (
  -- Define a "bridge-in" as a bridge event where destination_chain = the chain the wallet arrives on
  select
    wallet_address,
    bridge,
    destination_chain as arrival_chain,
    block_time as bridge_time,
    date_trunc('day', block_time) as bridge_date,
    tx_hash as bridge_tx_hash,
    amount_usd as bridged_amount_usd
  from {{ ref('silver_bridge_events_normalized') }}
),

first_swap_after_bridge as (
  select
    b.wallet_address,
    b.bridge,
    b.arrival_chain,
    b.bridge_time,
    b.bridge_date,
    b.bridge_tx_hash,
    b.bridged_amount_usd,

    min(t.block_time) as first_swap_time,
    min(t.tx_hash) as first_swap_tx_hash

  from bridge_ins b
  left join {{ ref('bronze_uniswap_swaps') }} t
    on lower(t.trader) = lower(b.wallet_address)
   and lower(t.chain) = lower(b.arrival_chain)
   and t.block_time > b.bridge_time

  group by 1,2,3,4,5,6,7
),

conversion_flags as (
  select
    wallet_address,
    bridge,
    arrival_chain,
    bridge_time,
    bridge_date,
    bridge_tx_hash,
    bridged_amount_usd,

    first_swap_time,
    first_swap_tx_hash,

    -- conversion = any swap after bridging
    case when first_swap_time is not null then 1 else 0 end as converted_to_dex_user_flag,

    -- time to convert in hours
    case
      when first_swap_time is null then null
      else date_diff('hour', bridge_time, first_swap_time)
    end as time_to_first_swap_hours

  from first_swap_after_bridge
),

retention_flags as (
  select
    c.*,

    -- retained = any swap between (bridge_time + 7 days) and (bridge_time + 30 days)
    case
      when exists (
        select 1
        from {{ ref('bronze_uniswap_swaps') }} t
        where lower(t.trader) = lower(c.wallet_address)
          and lower(t.chain) = lower(c.arrival_chain)
          and t.block_time >= c.bridge_time + interval 7 day
          and t.block_time <  c.bridge_time + interval 30 day
      ) then 1 else 0
    end as retained_after_bridge_flag

  from conversion_flags c
)

select * from retention_flags

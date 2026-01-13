{{ config(materialized='table') }}

with wallet_rollup as (
  select
    wallet_address,
    chain,
    count(distinct date) as active_days,
    count(distinct tx_hash) as tx_count,
    sum(amount_usd) as total_volume_usd,
    avg(amount_usd) as avg_trade_usd
  from {{ ref('silver_trades_normalized') }}
  group by 1,2
),

volume_thresholds as (
  -- Simple deterministic thresholds for v1.
  -- In production you would compute percentiles (p90/p50) per chain.
  select
    chain,
    1000.0 as whale_usd_threshold,
    300.0 as mid_usd_threshold
  from (select distinct chain from wallet_rollup)
),

wallet_tiered as (
  select
    w.*,
    case
      when w.total_volume_usd >= t.whale_usd_threshold then 'whale'
      when w.total_volume_usd >= t.mid_usd_threshold then 'mid'
      else 'tail'
    end as volume_tier
  from wallet_rollup w
  join volume_thresholds t
    on w.chain = t.chain
),

activation as (
  select
    wallet_address,
    chain,
    activated_within_7d_flag,
    activated_within_30d_flag
  from {{ ref('gold_wallet_funnel') }}
),

segments as (
  select
    w.wallet_address,
    w.chain,
    w.active_days,
    w.tx_count,
    w.total_volume_usd,
    w.avg_trade_usd,
    w.volume_tier,

    coalesce(a.activated_within_7d_flag, 0) as activated_within_7d_flag,
    coalesce(a.activated_within_30d_flag, 0) as activated_within_30d_flag,

    case
      when coalesce(a.activated_within_7d_flag, 0) = 1 then 'activated_7d'
      when coalesce(a.activated_within_30d_flag, 0) = 1 then 'activated_30d'
      else 'not_activated'
    end as activation_label,

    (w.volume_tier || '__' ||
      case
        when coalesce(a.activated_within_7d_flag, 0) = 1 then 'activated_7d'
        when coalesce(a.activated_within_30d_flag, 0) = 1 then 'activated_30d'
        else 'not_activated'
      end
    ) as segment

  from wallet_tiered w
  left join activation a
    on w.wallet_address = a.wallet_address
   and w.chain = a.chain
),

bridge_conversion as (
  select
    wallet_address,
    arrival_chain as chain,
    max(converted_to_dex_user_flag) as converted_after_bridge_flag,
    min(time_to_first_swap_hours) as best_time_to_first_swap_hours
  from {{ ref('gold_post_bridge_conversion') }}
  group by 1,2
),

joined as (
  select
    s.*,
    coalesce(b.converted_after_bridge_flag, 0) as converted_after_bridge_flag,
    b.best_time_to_first_swap_hours
  from segments s
  left join bridge_conversion b
    on s.wallet_address = b.wallet_address
   and s.chain = b.chain
)

select
  segment,
  chain,

  count(distinct wallet_address) as wallets,

  avg(active_days) as avg_active_days,
  avg(tx_count) as avg_tx_count,

  sum(total_volume_usd) as total_volume_usd,
  avg(total_volume_usd) as avg_wallet_volume_usd,

  avg(avg_trade_usd) as avg_trade_usd,

  -- share of wallets that converted after bridging into this chain (if present)
  avg(cast(converted_after_bridge_flag as double)) as bridge_conversion_rate,

  -- only meaningful where conversion exists
  avg(best_time_to_first_swap_hours) as avg_time_to_first_swap_hours

from joined
group by 1,2
order by chain, wallets desc

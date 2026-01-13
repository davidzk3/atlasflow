{{ config(materialized='table') }}

with activity as (
  select
    wallet_address,
    chain,
    date_trunc('week', date) as activity_week
  from {{ ref('silver_trades_normalized') }}
  group by 1,2,3
),

first_week as (
  select
    wallet_address,
    chain,
    min(activity_week) as cohort_week
  from activity
  group by 1,2
),

labeled as (
  select
    a.wallet_address,
    a.chain,
    f.cohort_week,
    a.activity_week,
    date_diff('week', f.cohort_week, a.activity_week) as weeks_since_first
  from activity a
  join first_week f
    on a.wallet_address = f.wallet_address
   and a.chain = f.chain
),

cohort_sizes as (
  select
    cohort_week,
    chain,
    count(distinct wallet_address) as cohort_size
  from first_week
  group by 1,2
),

retained as (
  select
    cohort_week,
    chain,
    weeks_since_first,
    count(distinct wallet_address) as retained_wallets
  from labeled
  group by 1,2,3
)

select
  r.cohort_week,
  r.chain,
  r.weeks_since_first,
  s.cohort_size,
  r.retained_wallets,
  cast(r.retained_wallets as double) / nullif(cast(s.cohort_size as double), 0) as retention_rate
from retained r
join cohort_sizes s
  on r.cohort_week = s.cohort_week
 and r.chain = s.chain
order by 1,2,3

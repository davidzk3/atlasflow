{{ config(materialized='table') }}

with swaps as (
  select
    wallet_address,
    chain,
    date as swap_date,
    tx_hash
  from {{ ref('silver_trades_normalized') }}
),

ordered_swaps as (
  select
    wallet_address,
    chain,
    swap_date,
    tx_hash,
    row_number() over (
      partition by wallet_address, chain
      order by swap_date, tx_hash
    ) as swap_rank
  from swaps
),

first_second as (
  select
    wallet_address,
    chain,
    min(case when swap_rank = 1 then swap_date end) as first_swap_date,
    min(case when swap_rank = 2 then swap_date end) as second_swap_date
  from ordered_swaps
  group by 1,2
)

select
  wallet_address,
  chain,
  first_swap_date,
  second_swap_date,

  case
    when second_swap_date is not null
     and second_swap_date <= first_swap_date + interval 7 day
    then 1 else 0
  end as activated_within_7d_flag,

  case
    when second_swap_date is not null
     and second_swap_date <= first_swap_date + interval 30 day
    then 1 else 0
  end as activated_within_30d_flag

from first_second

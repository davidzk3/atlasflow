{{ config(materialized='view') }}

with across as (
  select
    cast(block_time as timestamp) as block_time,
    lower(bridge) as bridge,
    lower(source_chain) as source_chain,
    lower(destination_chain) as destination_chain,
    tx_hash,
    lower(sender) as sender,
    lower(recipient) as recipient,
    lower(token_symbol) as token_symbol,
    cast(amount as double) as amount,
    cast(amount_usd as double) as amount_usd
  from read_csv_auto(
    'C:\\Users\\David\\atlasflow\\data\\raw\\dune\\evm_across_bridge_flows_eth_arb.csv',
    header=true
  )
),
stargate as (
  select
    cast(block_time as timestamp) as block_time,
    lower(bridge) as bridge,
    lower(source_chain) as source_chain,
    lower(destination_chain) as destination_chain,
    tx_hash,
    lower(sender) as sender,
    lower(recipient) as recipient,
    lower(token_symbol) as token_symbol,
    cast(amount as double) as amount,
    cast(amount_usd as double) as amount_usd
  from read_csv_auto(
    'C:\\Users\\David\\atlasflow\\data\\raw\\dune\\evm_stargate_bridge_flows_multi.csv',
    header=true
  )
)

select * from across
union all
select * from stargate

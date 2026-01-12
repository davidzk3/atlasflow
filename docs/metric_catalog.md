# Metric Catalog

This document defines the core metrics and gold marts produced by ATLASFLOW.

Each metric is designed to be:
- Clearly defined
- Reproducible
- Stable for downstream analytics and dashboards

Unless stated otherwise, all metrics are computed daily.

---

## Wallet Activity Metrics

### gold_wallet_daily_activity

**Grain**  
One row per wallet, per chain, per day

**Description**  
Captures daily onchain activity and trading behavior for wallets interacting with supported protocols.

**Key Fields**
- `date`
- `chain`
- `wallet_address`
- `transaction_count`
- `swap_count`
- `unique_tokens_traded`
- `unique_pools_traded`
- `total_volume_usd`

**Use Cases**
- Active wallet tracking
- Power user identification
- Behavioral segmentation inputs

---

## User Journey and Retention Metrics

### gold_wallet_funnel

**Grain**  
One row per wallet

**Description**  
Models the progression of wallets through key engagement stages.

**Stages**
- First onchain interaction
- First DEX swap
- First repeat swap
- Retained at week 4

**Key Fields**
- `wallet_address`
- `first_seen_date`
- `first_swap_date`
- `second_swap_date`
- `week_4_retained_flag`

**Use Cases**
- Funnel conversion analysis
- Product engagement diagnostics

---

### gold_retention_cohorts

**Grain**  
One row per cohort, per retention window

**Description**  
Tracks retention over time based on a wallet’s first activity date.

**Key Fields**
- `cohort_week`
- `weeks_since_first_activity`
- `active_wallets`
- `retention_rate`

**Use Cases**
- Long-term engagement analysis
- Cross-chain and cross-protocol comparisons

---

## Liquidity Metrics

### gold_liquidity_movement_daily

**Grain**  
One row per pool, per chain, per day

**Description**  
Tracks liquidity additions and removals over time.

**Key Fields**
- `date`
- `chain`
- `protocol`
- `pool_id`
- `liquidity_added_usd`
- `liquidity_removed_usd`
- `net_liquidity_change_usd`

**Use Cases**
- Liquidity churn monitoring
- LP behavior analysis

---

### gold_liquidity_where_it_lives

**Grain**  
One row per protocol, per chain, per day

**Description**  
Aggregates liquidity to identify concentration and venue dominance.

**Key Fields**
- `total_liquidity_usd`
- `top_pool_liquidity_share`
- `top_3_pools_liquidity_share`
- `liquidity_concentration_index`

**Use Cases**
- Liquidity resilience assessment
- Concentration risk analysis

---

## Bridge and Cross-Chain Metrics

### gold_bridge_flows_daily

**Grain**  
One row per bridge, per source chain, per destination chain, per day

**Description**  
Tracks cross-chain capital movement via supported bridges.

**Key Fields**
- `date`
- `bridge`
- `source_chain`
- `destination_chain`
- `amount_usd`
- `unique_wallets`

**Supported Bridges**
- Across
- Stargate

**Use Cases**
- Capital migration analysis
- Cross-chain demand monitoring

---

### gold_post_bridge_conversion

**Grain**  
One row per wallet

**Description**  
Measures how wallets behave after bridging capital to a new chain.

**Key Fields**
- `wallet_address`
- `bridge_used`
- `bridge_date`
- `time_to_first_swap_hours`
- `converted_to_dex_user_flag`
- `retained_after_bridge_flag`

**Use Cases**
- Bridge effectiveness evaluation
- Post-bridge user activation analysis

---

## Wallet Identity and Segmentation

### gold_wallet_clusters

**Grain**  
One row per wallet

**Description**  
Assigns wallets to behavioral clusters based on onchain activity patterns.

**Feature Inputs**
- Swap frequency
- Average trade size
- Token diversity
- Pool diversity
- Time-based activity patterns

**Key Fields**
- `wallet_address`
- `cluster_id`
- `cluster_label`

**Use Cases**
- Segment-level analysis
- Targeted product or liquidity strategies

---

## Attribution Metrics

### gold_segment_performance_attribution

**Grain**  
One row per segment, per chain, per period

**Description**  
Attributes trading activity and growth metrics to wallet segments.

**Key Fields**
- `segment`
- `chain`
- `total_volume_usd`
- `active_wallets`
- `retention_rate`
- `volume_growth_rate`

**Use Cases**
- Understanding which segments drive growth
- Evaluating sustainability of activity

---

## Notes on Metric Stability

- Gold marts are treated as **stable contracts**
- Any breaking change requires explicit versioning and documentation
- Assumptions and known limitations are documented in `docs/assumptions_limits.md`

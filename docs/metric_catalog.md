# ATLASFLOW Metric Catalog

This catalog defines the core **gold marts** and the metrics they expose.
It is written to be unambiguous, reproducible, and suitable for BI + downstream analysis.

Conventions:
- **Grain** describes the unique row key of the table.
- All timestamps are assumed UTC for v1.
- Chain values are normalized to lowercase (e.g., `ethereum`, `arbitrum`).
- Wallet addresses are stored lowercase.

---

## 1) Trading and Wallet Activity

### 1.1 `main_gold.gold_wallet_daily_activity`

**Purpose**  
Daily wallet activity and trading intensity on supported DEX venues.

**Grain**  
`date × chain × wallet_address`

**Source Models**
- `main_silver.silver_trades_normalized`

**Core Dimensions**
- `date` — day of activity (date truncated)
- `chain` — chain where the swap occurred
- `wallet_address` — trader / initiating wallet

**Core Metrics**
- `transaction_count` — count of distinct `tx_hash` for that wallet/day/chain
- `swap_count` — count of swap events (rows) for that wallet/day/chain
- `unique_tokens_touched` — distinct tokens interacted with (token_in + token_out)
- `total_volume_usd` — sum of `amount_usd`
- `avg_trade_usd` — average `amount_usd` per swap
- `max_trade_usd` — max `amount_usd` per swap

**Interpretation Notes**
- `transaction_count` may be ≤ `swap_count` if multiple swap events occur in a single tx.
- `unique_tokens_touched` is activity-oriented (not holdings). It does not imply balance.

**Primary Use Cases**
- Active traders trend (DAW/WAU style rollups)
- Identifying heavy users and whales
- Inputs to segmentation and retention analyses

---

## 2) Cross-Chain Flows and Bridging

### 2.1 `main_gold.gold_bridge_flows_daily`

**Purpose**  
Daily bridge flow summary across supported bridges and chain routes.

**Grain**  
`date × bridge × source_chain × destination_chain`

**Source Models**
- `main_silver.silver_bridge_events_normalized`

**Core Dimensions**
- `date` — day of bridge event
- `bridge` — `across` or `stargate`
- `source_chain` — origin chain
- `destination_chain` — destination chain

**Core Metrics**
- `unique_wallets` — count of distinct `wallet_address` bridging on that route/day
- `tx_count` — count of distinct `tx_hash`
- `total_amount_usd` — sum of `amount_usd` bridged

**Interpretation Notes**
- Flows represent bridge transactions, not necessarily net-new capital (wallets may cycle).
- USD normalization depends on ingestion source pricing logic for v1.

**Primary Use Cases**
- Monitoring migration of capital across chains
- Detecting route-level spikes and bridge dependency
- Inputs to conversion analysis (bridge-in → usage)

---

### 2.2 `main_gold.gold_post_bridge_conversion`

**Purpose**  
Quantifies activation and retention after a wallet bridges into a chain.

This mart answers:
- Do bridged wallets actually use the destination chain?
- How fast do they convert into trading activity?
- Do they stick around?

**Grain**  
One row per bridge event (per wallet per bridge-in event):
`wallet_address × bridge_time × arrival_chain`

**Source Models**
- `main_silver.silver_bridge_events_normalized`
- `main_bronze.bronze_uniswap_swaps` (v1 trade event source)

**Core Dimensions**
- `wallet_address` — bridging wallet (sender)
- `bridge` — bridge used (`across` / `stargate`)
- `arrival_chain` — destination chain of the bridge event
- `bridge_time` — timestamp of bridge event
- `bridge_date` — date truncated bridge_time
- `bridge_tx_hash` — tx hash of bridge event
- `bridged_amount_usd` — bridged size

**Core Metrics**
- `converted_to_dex_user_flag`
  - 1 if wallet executed any swap on the arrival chain after bridging
  - 0 otherwise
- `time_to_first_swap_hours`
  - hours from `bridge_time` to first observed swap time on arrival chain
  - null if no swap observed
- `retained_after_bridge_flag`
  - 1 if wallet swaps again between day 7 and day 30 after bridging
  - 0 otherwise

**Interpretation Notes**
- v1 uses Uniswap swaps as the conversion event source; later versions should expand to:
  - additional DEXs
  - lending actions (Aave)
  - staking (Lido)
  - transfers / contract interactions
- Retention definition is activity-based (behavior), not balance-based.

**Primary Use Cases**
- Measuring bridge route quality (who bridges and becomes active)
- Comparing bridges (Across vs Stargate) on conversion speed
- Understanding if migration leads to durable activity

---

## 3) Metric Quality and Caveats (v1)

### 3.1 Coverage
- v1 conversion uses DEX swap events only.
- v1 bridging uses sample extracts shaped like Dune outputs; replace with real exports for production coverage.

### 3.2 Identity
- Wallet clustering / entity resolution is out of scope for v1 marts.
- Wallet addresses are treated as independent identities.

### 3.3 Pricing
- `amount_usd` assumes upstream USD logic; formal price joins will be added in later versions.

---

## 4) Planned Additions

- `gold_wallet_funnel` — stage-based journey (first seen → first swap → repeat usage)
- `gold_retention_cohorts` — cohort retention curves (D7/D30)
- `gold_wallet_clusters` — behavioral segmentation
- `gold_segment_performance_attribution` — which segments drive volume and retention
- Liquidity marts:
  - `gold_liquidity_movement_daily`
  - `gold_liquidity_where_it_lives`

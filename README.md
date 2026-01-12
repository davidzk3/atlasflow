# ATLASFLOW — Multi-Chain Onchain Analytics & Capital Flow Intelligence

ATLASFLOW is a production-style analytics platform designed to transform raw onchain activity into **decision-ready datasets, metrics, and insights**.

The system focuses on how wallets behave, how liquidity moves, and how capital flows across chains, protocols, and bridges. It is built to support scalable analytics workflows using version-controlled models, reproducible pipelines, and BI-ready outputs.

ATLASFLOW is intentionally structured like an internal analytics platform rather than a standalone dashboard or notebook.

---

## What ATLASFLOW Models

ATLASFLOW covers the full onchain lifecycle across trading, liquidity, and cross-chain movement:

- **Wallet activity and trading behavior** across chains and venues
- **Liquidity movement and concentration**, including LP adds/removals and venue dominance
- **Cross-chain capital flows** via major bridges
- **Wallet clustering and segmentation** based on behavioral features
- **Attribution frameworks** to understand which segments drive volume, retention, and growth

---

## Chains and Protocols (v1 Scope)

### Chains
- Ethereum  
- Arbitrum  
- Solana  

### Decentralized Exchanges
- Uniswap v3 (Ethereum, Arbitrum)
- Jupiter (Solana)

### Lending and Staking (optional extensions)
- Aave (Ethereum, Arbitrum)
- Lido (Ethereum)

### Bridges
- Across (Ethereum ↔ Arbitrum)
- Stargate (multi-chain bridging flows)

---

## Data Outputs (dbt Gold Marts)

ATLASFLOW produces curated, analytics-ready tables intended for BI tools, downstream analysis, and reporting:

- `gold_wallet_daily_activity`
- `gold_wallet_funnel`
- `gold_retention_cohorts`
- `gold_liquidity_movement_daily`
- `gold_liquidity_where_it_lives`
- `gold_bridge_flows_daily` (Across and Stargate)
- `gold_post_bridge_conversion` (bridge-in → DEX usage)
- `gold_wallet_clusters`
- `gold_segment_performance_attribution`

Each mart is designed with explicit metric definitions, data contracts, and test coverage.

---

## Architecture Overview

1. **Ingestion**  
   - EVM data via curated SQL queries (e.g. Dune / Flipside APIs)  
   - Solana data via indexed APIs for program and wallet activity  

2. **Storage and Modeling**  
   - Raw extracts stored as partitioned files  
   - dbt models structured as bronze → silver → gold  

3. **Analytics Layer**  
   - Wallet clustering and segmentation  
   - Capital flow and bridge analysis  
   - Funnel, retention, and attribution modeling  

4. **Reporting**  
   - BI dashboards (screenshots committed)  
   - Written analytics memos capturing key findings and implications  

---

## Repository Structure

Key directories:

- `src/` — ingestion, transformations, analytics logic
- `dbt/` — version-controlled data models and tests
- `docs/` — architecture, metric definitions, and analytical playbooks
- `memos/` — written insights derived from the data
- `dashboards/screenshots/` — BI outputs for reference
- `ops/` — orchestration and operational scripts

---

## Documentation

- `docs/architecture.md` — system design and data flow
- `docs/metric_catalog.md` — definitions for all metrics and marts
- `docs/decision_examples.md` — example analytical questions and how ATLASFLOW answers them
- `docs/analytics_playbook.md` — guidance on interpreting outputs and using the data responsibly
- `docs/assumptions_limits.md` — known limitations and modeling assumptions

---

## Local Development

Local setup and execution instructions are added incrementally as components are implemented:

- Python environment setup
- DuckDB + dbt configuration
- Initial ingestion scripts and models
- Incremental backfills and daily runs

---

## Design Principles

ATLASFLOW is built around a few core principles:

- **Analytics over dashboards** — metrics and models come first
- **Reproducibility** — version-controlled logic, deterministic outputs
- **Data quality by default** — tests, sanity checks, and freshness expectations
- **Decision orientation** — outputs are designed to inform product, trading, and growth decisions

---

## Roadmap

- Expand Solana coverage and normalization
- Add advanced flow graph analytics
- Extend attribution frameworks across chains
- Introduce automated anomaly detection and alerts

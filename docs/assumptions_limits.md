\# ATLASFLOW — Assumptions \& Limitations (v1)



This document captures the explicit assumptions, known limitations, and design tradeoffs in ATLASFLOW v1.



The goal is transparency: metrics are only meaningful when their boundaries are understood.



---



\## 1) Data Coverage Assumptions



\### 1.1 Protocol Coverage

\- v1 DEX activity is derived from \*\*Uniswap v3 swaps only\*\* on Ethereum and Arbitrum.

\- Other DEXs (Curve, Sushi, Balancer, Jupiter) are not included in v1 metrics.

\- As a result, trading activity and conversion metrics represent \*\*partial onchain behavior\*\*, not total activity.



\### 1.2 Bridging Coverage

\- v1 bridge flows include:

&nbsp; - Across (Ethereum ↔ Arbitrum)

&nbsp; - Stargate (selected multi-chain routes)

\- Other bridges (Hop, Synapse, Celer, native bridges) are excluded.

\- Bridge metrics should be interpreted as \*\*route-specific indicators\*\*, not comprehensive migration flows.



---



\## 2) Identity Assumptions



\### 2.1 Wallet-Level Identity

\- Wallet addresses are treated as independent identities.

\- No wallet clustering, ENS resolution, or entity attribution is applied in v1.

\- A single user operating multiple wallets will appear as multiple identities.



\### 2.2 Contract vs EOA

\- v1 does not explicitly distinguish EOAs from smart contracts.

\- Contract-based wallets (multisigs, bots, aggregators) may be included in metrics.



---



\## 3) Pricing and Valuation



\### 3.1 USD Normalization

\- `amount\_usd` values are assumed to be provided by the upstream data source.

\- v1 does not independently reprice swaps or bridge events.

\- Pricing discrepancies or oracle mismatches may affect absolute USD metrics.



\### 3.2 Volume Interpretation

\- Volume metrics represent \*\*gross notional\*\*, not economic profit.

\- No fees, slippage, or realized PnL adjustments are applied.



---



\## 4) Funnel and Conversion Logic



\### 4.1 Conversion Definition

\- Conversion is defined as \*\*any DEX swap\*\* on the destination chain after a bridge-in event.

\- Non-trading interactions (transfers, contract calls, staking) do not count as conversion in v1.



\### 4.2 Time Windows

\- Time-to-conversion is measured in hours from bridge timestamp to first swap timestamp.

\- Retention is defined as activity between day 7 and day 30 after the bridge event.

\- These windows are heuristic and may be adjusted based on product context.



---



\## 5) Temporal Assumptions



\- All timestamps are assumed UTC.

\- Day-level aggregations use date truncation on event timestamps.

\- Late-arriving data is not handled in v1.



---



\## 6) Data Quality Considerations



\- v1 relies on clean, schema-consistent raw extracts.

\- No automated anomaly detection or volume sanity checks are enforced.

\- dbt tests (uniqueness, not-null, accepted values) are planned but not yet implemented.



---



\## 7) Intended Use



ATLASFLOW v1 is intended for:

\- Exploratory onchain analytics

\- Relative comparisons (routes, segments, cohorts)

\- Product and growth hypothesis testing



It is \*\*not\*\* intended for:

\- Financial reporting

\- Accounting or reconciliation

\- Risk management decisions without further validation



---



\## 8) Planned Improvements



\- Expand protocol coverage (DEXs, lending, staking)

\- Add wallet clustering and entity resolution

\- Introduce explicit pricing joins

\- Implement dbt tests and freshness checks

\- Support late-arriving and reorg-aware data




\# ATLASFLOW — Architecture



ATLASFLOW is a production-style analytics platform that converts raw onchain activity into decision-ready datasets using a Bronze → Silver → Gold modeling approach.



This document describes the current v1 architecture (DuckDB + dbt local), and how the system scales to production patterns (cloud warehouse + orchestrated ingestion).



---



\## 1) System Overview



ATLASFLOW is structured as four layers:



1\. \*\*Raw Extracts\*\*

&nbsp;  - Immutable data snapshots pulled from external sources (Dune-style exports / indexed APIs)

&nbsp;  - Stored as partitionable files under `data/raw/`



2\. \*\*dbt Modeling\*\*

&nbsp;  - Bronze: raw ingestion with type casting and minimal standardization

&nbsp;  - Silver: normalized event schemas (trades, bridge events)

&nbsp;  - Gold: analytics marts for BI, reporting, and downstream models



3\. \*\*Analytics Layer\*\*

&nbsp;  - Conversion, retention, cohorting

&nbsp;  - Segmentation and clustering (planned)

&nbsp;  - Attribution (planned)



4\. \*\*Reporting\*\*

&nbsp;  - BI dashboards (planned)

&nbsp;  - Written insight memos (planned)



---



\## 2) Current Data Coverage (v1)



\### Chains

\- Ethereum

\- Arbitrum

\- Solana (planned ingestion path; v1 focuses EVM for swaps + bridging)



\### Event Domains

\- DEX swaps: Uniswap v3 (Ethereum, Arbitrum)

\- Bridging: Across (ETH ↔ ARB), Stargate (multi-chain routes)



---



\## 3) Data Layout



\### Raw

`data/raw/dune/`

\- `evm\_uniswap\_swaps\_eth\_arb.csv`

\- `evm\_across\_bridge\_flows\_eth\_arb.csv`

\- `evm\_stargate\_bridge\_flows\_multi.csv`



Raw files are treated as immutable inputs. Downstream models must be reproducible from these extracts.



---



\## 4) dbt Model Layers



\### Bronze (minimal transformation)

\*\*Goal:\*\* enforce schema and types, normalize casing, preserve event-level fidelity.



Examples:

\- `main\_bronze.bronze\_uniswap\_swaps`

\- `main\_bronze.bronze\_bridge\_flows`



\### Silver (normalized event schemas)

\*\*Goal:\*\* unify event structures into analytics-friendly canonical formats.



Examples:

\- `main\_silver.silver\_trades\_normalized`

\- `main\_silver.silver\_bridge\_events\_normalized`



Silver models define the “source of truth” event schema for downstream metrics.



\### Gold (analytics marts)

\*\*Goal:\*\* stable contracts for BI dashboards, product analytics, and decision-making.



Examples:

\- `main\_gold.gold\_wallet\_daily\_activity`

\- `main\_gold.gold\_bridge\_flows\_daily`

\- `main\_gold.gold\_post\_bridge\_conversion`



Gold marts follow explicit definitions in `docs/metric\_catalog.md`.



---



\## 5) Data Quality



v1 enforces quality through:

\- Explicit casting and normalization in Bronze

\- Canonical schemas in Silver

\- Stable mart grains and definitions in Gold



Planned additions:

\- dbt tests (uniqueness / not-null / accepted-values)

\- freshness checks and volume sanity checks

\- schema contracts and documentation persistence



---



\## 6) Scaling Path (Production)



ATLASFLOW is designed to migrate from local DuckDB to production patterns:



\- \*\*Warehouse:\*\* Snowflake / BigQuery / Databricks / Postgres

\- \*\*Ingestion:\*\* scheduled pulls from APIs / subgraphs / node providers

\- \*\*Orchestration:\*\* Airflow / Dagster / Prefect

\- \*\*Serving:\*\* BI tools + notebooks + alerting



The Bronze → Silver → Gold boundary remains unchanged; only storage and orchestration evolve.



---



\## 7) Design Principles



\- \*\*Reproducible by default:\*\* deterministic builds from raw → marts

\- \*\*Decision-oriented:\*\* marts map to actionable questions (conversion, retention, flow)

\- \*\*Extensible:\*\* add chains/protocols without rewriting downstream logic

\- \*\*Documented contracts:\*\* every gold mart has an explicit grain and metric definitions




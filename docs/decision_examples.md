\# ATLASFLOW — Decision Examples



This document illustrates how ATLASFLOW’s analytics marts can be used by

Product, Growth, and Trading teams to inform real decisions.



The examples are intentionally concrete and action-oriented.



---



\## 1) Cross-Chain Growth Decision



\### Question

Which bridge routes generate durable trading activity after capital migrates?



\### Data Used

\- `main\_gold.gold\_bridge\_flows\_daily`

\- `main\_gold.gold\_post\_bridge\_conversion`

\- `main\_gold.gold\_wallet\_funnel`



\### Analysis

\- Compare bridge volume vs post-bridge conversion rate by route

\- Measure time-to-first-swap after bridge

\- Segment wallets by activation speed



\### Insight

A route may generate high bridge volume but low conversion,

indicating speculative or transient capital.



\### Action

\- Prioritize routes with:

&nbsp; - high conversion rate

&nbsp; - fast time-to-first-swap

&nbsp; - higher activated-within-7d share

\- Deprioritize routes with volume but poor activation



---



\## 2) Product Activation Optimization



\### Question

How quickly do new onchain users become repeat traders?



\### Data Used

\- `main\_gold.gold\_wallet\_funnel`

\- `main\_gold.gold\_retention\_cohorts`



\### Analysis

\- Measure share of wallets activating within 7 and 30 days

\- Track week-1 and week-2 retention by cohort



\### Insight

Most long-term retention is driven by wallets that activate within the first 7 days.



\### Action

\- Focus onboarding and education on accelerating the second trade

\- Introduce incentives or UX nudges targeting first-time traders



---



\## 3) Segment-Level Value Assessment



\### Question

Which wallet segments drive volume vs retention?



\### Data Used

\- `main\_gold.gold\_segment\_performance\_attribution`



\### Analysis

\- Compare total volume vs wallet count by segment

\- Measure retention and bridge conversion by segment



\### Insight

Whale segments drive volume but may not retain,

while mid-tier segments often show better repeat behavior.



\### Action

\- Tailor product features and messaging by segment

\- Avoid over-optimizing solely for whale volume



---



\## 4) Chain-Level Strategy Comparison



\### Question

Which chains attract higher-quality onchain users?



\### Data Used

\- `main\_gold.gold\_retention\_cohorts`

\- `main\_gold.gold\_segment\_performance\_attribution`



\### Analysis

\- Compare cohort retention curves by chain

\- Compare segment composition across chains



\### Insight

Some chains generate faster activation but weaker long-term retention.



\### Action

\- Adjust go-to-market strategy by chain

\- Align incentives with observed user behavior patterns



---



\## 5) Trading Signal Exploration (Exploratory)



\### Question

Do certain segments consistently precede volume surges?



\### Data Used

\- `main\_gold.gold\_segment\_performance\_attribution`

\- `main\_silver.silver\_trades\_normalized`



\### Analysis

\- Monitor changes in activity among high-value segments

\- Correlate segment activity spikes with aggregate volume



\### Insight

Segment-level activity shifts may act as early signals of liquidity movement.



\### Action

\- Use segments as exploratory indicators

\- Combine with order book and offchain data for confirmation



---



\## Summary



ATLASFLOW enables teams to:

\- Understand where capital moves

\- Identify which users matter

\- Optimize activation and retention

\- Align product and growth strategy with real onchain behavior






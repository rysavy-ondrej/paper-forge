# Experimental Setup {#sec:experiments}

The evaluation uses **synthetic data**: 10,000 alerts with a 5% share of true attacks, and agent outputs sampled to imitate agents of different quality.
The data and the script that produces every figure are part of the repository (`data/tradeoff.csv`, `figures/src/`).

@Tbl:setup lists the agents.

: Agents used in the evaluation. {#tbl:setup}

| Agent   | Input view        | Model size | Context |
|:--------|:------------------|-----------:|:-------:|
| Payload | Packet payload    |         7B |    4k   |
| Flow    | Flow statistics   |         7B |    2k   |
| Host    | Host alert history|        13B |    8k   |

We report precision, recall, F1 score, and the escalation rate, i.e., the share of alerts sent to an analyst.
Thresholds are $\tau_c = 0.15$ and $\tau_d = 0.04$.

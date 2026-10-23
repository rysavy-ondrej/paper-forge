# Methodology {#sec:methodology}

@Fig:architecture shows the architecture.
Each alert is enriched with flow context and passed to $N$ agents, each specialized in one view of the alert: payload, flow statistics, or host history.

![Architecture of the multi-agent triage system. Each agent classifies the alert independently; the aggregator computes the confidence and decides whether to escalate.](figures/architecture.pdf){#fig:architecture width=100%}

## Confidence Model {#sec:confidence}

Agent $i$ returns the probability $p_i(x)$ that alert $x$ is malicious.
We define the classification confidence as the mean of the agent probabilities:

$$
C(x) = \frac{1}{N}\sum_{i=1}^{N}p_i(x)
$$ {#eq:confidence}

and the disagreement as the variance of the probabilities around $C(x)$:

$$
D(x) = \frac{1}{N}\sum_{i=1}^{N}\left(p_i(x) - C(x)\right)^2 .
$$ {#eq:disagreement}

## Escalation Rule

An alert is classified automatically when the agents agree and the confidence is far from the decision boundary; otherwise it is escalated:

```{=latex}
\begin{align}
  \mathrm{escalate}(x) &\iff |C(x) - 0.5| < \tau_c \;\lor\; D(x) > \tau_d, \label{eq:escalation-raw}
\end{align}
```

where $\tau_c$ and $\tau_d$ are thresholds tuned on validation data.
The rule in Eq.\ \eqref{eq:escalation-raw} combines @eq:confidence and @eq:disagreement.

$$
\mathrm{escalate}(x) = \mathbf{1}\left[\,|C(x) - 0.5| < \tau_c \lor D(x) > \tau_d\,\right]
$$ {#eq:escalation}

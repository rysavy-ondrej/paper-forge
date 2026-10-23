# Results {#sec:results}

@Tbl:results compares single agents with the ensemble on the synthetic data.
The ensemble achieves the highest F1 score; the price is that 6.8% of alerts are escalated.

: Detection performance on synthetic data (higher is better, except escalation). {#tbl:results}

| Method           | Precision | Recall |    F1 | Escalated |
|:-----------------|----------:|-------:|------:|----------:|
| Payload agent    |     0.712 |  0.804 | 0.755 |        --- |
| Flow agent       |     0.655 |  0.781 | 0.712 |        --- |
| Host agent       |     0.741 |  0.766 | 0.753 |        --- |
| Ensemble (ours)  | **0.823** |  0.851 | **0.837** |    6.8% |

@Fig:tradeoff shows how F1 and the escalation rate change with the confidence threshold $\tau_c$.
Increasing $\tau_c$ sends more uncertain alerts to an analyst and raises the F1 score of the automatically classified alerts.

![F1 score of automatically classified alerts and escalation rate as functions of the confidence threshold $\tau_c$ (synthetic data).](figures/tradeoff.pdf){#fig:tradeoff width=100%}

Table\ \ref{tbl:agreement} reports pairwise agreement between agents as Cohen's kappa [@cohen1960coefficient].

```{=latex}
\begin{table}
  \centering
  \caption{Pairwise agreement (Cohen's $\kappa$) between agents on synthetic data.}
  \label{tbl:agreement}
  \begin{tabular}{lccc}
    \toprule
            & Payload & Flow & Host \\
    \midrule
    Payload & ---     & 0.61 & 0.58 \\
    Flow    & 0.61    & ---  & 0.49 \\
    Host    & 0.58    & 0.49 & ---  \\
    \bottomrule
  \end{tabular}
\end{table}
```

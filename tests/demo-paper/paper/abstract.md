Security operations centers receive far more intrusion detection alerts than analysts can investigate, and most of these alerts are false positives.
This demonstration paper describes a multi-agent triage architecture in which several specialized language-model agents classify each alert independently and an aggregator combines their verdicts into a confidence score.
Alerts with low confidence or high agent disagreement are escalated to a human analyst.
The paper exists to exercise the paper-forge toolchain: the evaluation uses synthetic data generated for this purpose, and its numbers carry no scientific meaning.
On this synthetic data, the ensemble of agents improves the F1 score over the best single agent while escalating a small fraction of alerts for human review.

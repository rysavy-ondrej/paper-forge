# Related Work {#sec:related-work}

Axelsson showed that the base-rate fallacy bounds the usefulness of intrusion detectors: unless the false-alarm rate is extremely low, most alerts will be false [@axelsson2000baserate].
Sommer and Paxson argued that anomaly detection with machine learning suffers from a high cost of errors, a semantic gap between detections and operator understanding, and difficult evaluation [@sommer2010outside, pp. 305--307].
Our design targets the semantic gap by asking each agent to justify its verdict.

Ensembles of independent classifiers, such as random forests [@breiman2001random], reduce variance by aggregating many weak decisions.
The proposed aggregator follows the same principle with heterogeneous agents instead of decision trees.
Agreement between agents is measured with Cohen's kappa [@cohen1960coefficient].

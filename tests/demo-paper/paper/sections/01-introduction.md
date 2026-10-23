# Introduction {#sec:introduction}

Network intrusion detection systems (IDSs) produce large volumes of alerts, and the low base rate of real attacks means that even accurate detectors generate mostly false alarms [@axelsson2000baserate].
Machine learning has long been proposed to reduce this burden, but deploying it in operational networks is harder than in other domains [@sommer2010outside].
Language models based on the Transformer architecture [@vaswani2017attention] offer a new option: they can read the context of an alert and explain their verdict.

This paper is a demonstration of the paper-forge workflow.
**All experimental data in it is synthetic** and was generated only to exercise figures, tables, and cross-references.

## Research Questions {#sec:research-questions}

This paper investigates three research questions:

1. Can specialized agents improve detection accuracy over a single agent?
2. How does agent disagreement affect the reliability of the verdict?
3. When should the system request human intervention?

## Contributions

- A multi-agent triage architecture with an explicit confidence model (@sec:methodology).
- An escalation rule based on confidence and inter-agent agreement (@eq:escalation).
- An evaluation on synthetic alert data (@sec:results).

The rest of the paper is organized as follows.
@Sec:related-work reviews related work, @sec:methodology describes the architecture, @sec:experiments the setup, @sec:results the results, and @sec:conclusion concludes.

"""F1 / escalation trade-off plot. Usage: tradeoff.py OUTPUT.pdf"""
import csv
import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

plt.rcParams.update({
    "font.family": "serif",
    "font.serif": ["Times New Roman", "Times", "Nimbus Roman", "DejaVu Serif"],
    "mathtext.fontset": "stix",
    "font.size": 8,
    "axes.labelsize": 8,
    "legend.fontsize": 7,
    "pdf.fonttype": 42,
    "ps.fonttype": 42,
})

data = Path(__file__).resolve().parents[2] / "data" / "tradeoff.csv"
with data.open() as f:
    rows = list(csv.DictReader(line for line in f if not line.startswith("#")))
tau = [float(r["tau_c"]) for r in rows]
f1 = [float(r["f1"]) for r in rows]
escalated = [100 * float(r["escalated"]) for r in rows]

fig, ax = plt.subplots(figsize=(3.5, 2.0))
ax.plot(tau, f1, "o-", color="#1f4e79", label="F1 (automatic)")
ax.set_xlabel(r"Confidence threshold $\tau_c$")
ax.set_ylabel("F1 score")
ax2 = ax.twinx()
ax2.plot(tau, escalated, "s--", color="#c55a11", label="Escalated")
ax2.set_ylabel("Escalated alerts (%)")
lines = ax.get_lines() + ax2.get_lines()
ax.legend(lines, [l.get_label() for l in lines], loc="lower right", frameon=False)
fig.tight_layout()
fig.savefig(sys.argv[1], bbox_inches="tight")

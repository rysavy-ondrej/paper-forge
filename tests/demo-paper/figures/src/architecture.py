"""Block diagram of the triage architecture. Usage: architecture.py OUTPUT.pdf"""
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

plt.rcParams.update({
    "font.family": "serif",
    "font.serif": ["Times New Roman", "Times", "Nimbus Roman", "DejaVu Serif"],
    "mathtext.fontset": "stix",
    "font.size": 6.5,
    "pdf.fonttype": 42,
})

fig, ax = plt.subplots(figsize=(3.5, 1.6))
ax.set_xlim(-0.2, 10.2)
ax.set_ylim(0, 4.5)
ax.axis("off")


def box(x, y, w, h, text):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.05",
                                fc="#eef3f8", ec="#1f4e79", lw=0.8))
    ax.text(x + w / 2, y + h / 2, text, ha="center", va="center")


def arrow(x1, y1, x2, y2):
    ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle="->", lw=0.7, color="#333333"))


box(0.0, 1.75, 1.5, 1.0, "Alert +\ncontext")
for i, name in enumerate(["Payload agent", "Flow agent", "Host agent"]):
    y = 3.2 - 1.4 * i
    box(2.2, y, 2.3, 0.9, name)
    arrow(1.55, 2.25, 2.15, y + 0.45)
    arrow(4.55, y + 0.45, 5.15, 2.25)
box(5.2, 1.75, 2.1, 1.0, "Aggregator\n$C(x)$, $D(x)$")
box(8.1, 2.7, 1.9, 0.9, "Automatic\nverdict")
box(8.1, 0.9, 1.9, 0.9, "Analyst")
arrow(7.35, 2.45, 8.05, 3.15)
arrow(7.35, 2.05, 8.05, 1.35)

fig.savefig(sys.argv[1], bbox_inches="tight")

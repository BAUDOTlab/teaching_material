# /// script
# requires-python = ">=3.10"
# dependencies = [
#   "marimo>=0.23.2",
#   "pandas",
#   "matplotlib",
#   "numpy",
# ]
# ///

import marimo

__generated_with = "0.23.2"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo

    return (mo,)


@app.cell
def _(mo):
    mo.md(r"""
    # 🌊 marimo — demo notebook

    This file tests that the **marimo Cursor extension** (v0.12.6) and the
    **marimo CLI** (installed via `uv tool install "marimo[recommended]"`) are
    working correctly.

    Open this file with the marimo logo button (top-right) to switch to the
    reactive notebook view, or run from the terminal:

    ```bash
    # Sandboxed — deps are inlined above (PEP 723 metadata)
    uvx marimo edit --sandbox demo.py

    # Or with the system-level tool
    marimo edit demo.py
    ```
    """)
    return


@app.cell
def _(mo):
    # --- 1. Reactive slider --------------------------------------------------
    n = mo.ui.slider(start=5, stop=100, step=5, value=20, label="Number of points")
    n
    return (n,)


@app.cell
def _(mo, n):
    import numpy as np

    x = np.linspace(0, 2 * np.pi, n.value)
    y = np.sin(x)

    mo.md(f"**n = {n.value}** → array shape: `{x.shape}`")
    return np, x, y


@app.cell
def _(mo, x, y):
    import matplotlib.pyplot as plt

    fig, ax = plt.subplots(figsize=(7, 3))
    ax.plot(x, y, marker="o", markersize=4, linewidth=1.5, color="#2563EB")
    ax.set(title="sin(x) — reactive plot", xlabel="x", ylabel="sin(x)")
    ax.grid(alpha=0.3)
    plt.tight_layout()

    mo.md("### Reactive plot — drag the slider above to update")
    return


@app.cell
def _(mo, n, np):
    import pandas as pd

    df = pd.DataFrame(
        {
            "x": np.linspace(0, 2 * np.pi, n.value).round(3),
            "sin(x)": np.sin(np.linspace(0, 2 * np.pi, n.value)).round(4),
            "cos(x)": np.cos(np.linspace(0, 2 * np.pi, n.value)).round(4),
        }
    )

    mo.vstack([
        mo.md("### Reactive table — updates with the slider"),
        mo.ui.table(df),
    ])
    return


@app.cell
def _(mo):
    mo.md(r"""
    ---
    ## ✅ Checklist — what this demo tests

    | Feature | Expected behaviour |
    |---|---|
    | Reactive slider | Plot and table update on drag |
    | `mo.md()` | Markdown renders in notebook view |
    | `mo.ui.table()` | Sortable, filterable table |
    | Sandbox deps (PEP 723) | `uvx marimo edit --sandbox demo.py` installs deps automatically |
    | Extension toggle | Click marimo logo (top-right) to switch view |
    """)
    return


if __name__ == "__main__":
    app.run()

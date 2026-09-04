# Stochastic Computing — Hardware SNG & Stochastic Multiplier Investigation

This repository documents an **8-bit stochastic computing (SC) multiplier study**, progressing from stochastic-computing fundamentals to hardware-oriented stochastic number generation (SNG), exhaustive configuration search, correlation/dependence analysis, and an interactive multiplier simulator.

The work is aimed at understanding how **finite stochastic bitstreams, SNG sequence quality, LFSR polynomial choice, seed selection, and stream dependence** affect multiplication accuracy, with the eventual goal of translating the selected architecture into **RTL hardware**.

---

## Project Objective

The main target is an unsigned **8-bit × 8-bit stochastic multiplier**:

- Input range: `0–255`
- Normalized value: `x = X / 255`
- Product range: `0–65025`
- Stochastic vector lengths investigated: **16 and 32 bits**
- Multiplication operator: **AND gate** in unipolar stochastic computing
- Hardware-oriented SNG investigated: **8-bit LFSR + comparator**

The central question is not only whether stochastic multiplication works, but **which SNG configuration gives robust accuracy across the complete 8-bit input space**.

---

## Repository Contents

| File | Purpose |
|---|---|
| `01_Fundamentals (1).ipynb` | Introduction to stochastic representation, finite streams, decoding, and baseline stochastic multiplication. |
| `02_Investigation (11).ipynb` | Hardware-oriented SNG investigation, LFSR configurations, exhaustive pair evaluation, dependence analysis, error analysis, and candidate selection. |
| `stochastic_multiplier_interactive_simulator_ranked (1) (1).html` | Standalone interactive simulator for experimenting with ranked SNG pairs and 8-bit input values. |

---

# 1. Stochastic Computing Fundamentals

In **unipolar stochastic computing**, a real value in `[0,1]` is represented by the probability of observing a `1` in a stochastic bitstream.

For an unsigned 8-bit input `X`:

```text
x = X / 255
```

A stochastic stream of length `L` approximates this value through its one-density:

```text
p̂ = Number of ones / L
```

For two independent stochastic streams, multiplication can be performed using a single AND gate:

```text
Z_SC = A_SC AND B_SC
```

The output probability ideally becomes:

```text
P(Z=1) = P(A=1) × P(B=1)
```

The corresponding decoded product is:

```text
P_SC = p_AND × 255²
```

and the exact binary product is:

```text
P_exact = A × B
```

The fundamental notebook demonstrates why finite stream length causes approximation error even when the stochastic multiplier itself is only an AND gate.

---

# 2. From Software Randomness to Hardware-Oriented SNGs

The initial baseline uses software-generated stochastic streams to establish the basic mathematics. The main investigation then moves to **hardware-realizable sequence generation**.

For an 8-bit input, the selected LFSR is also **8 bits wide**, requiring:

```text
8 flip-flops per LFSR/SNG
```

A two-input stochastic multiplier therefore uses two LFSR state registers:

```text
2 × 8 = 16 flip-flops
```

in the basic two-SNG architecture, excluding other logic.

Each SNG follows the structure:

```text
8-bit input
     │
     ├──> 8-bit LFSR (8 FFs)
     │          │
     │          ▼
     │     8-bit comparator
     │          │
     │          ▼
     │    stochastic bit
     │
     └──────────────────┐
                        AND ──> stochastic product bit
```

The comparator rule used in the investigation is:

```text
stochastic_bit = 1  if LFSR_state < input
                  0  otherwise
```

Thus the generated one-density approaches `X/255` over a sufficiently complete LFSR cycle.

---

# 3. LFSR Polynomial Families

Three verified **maximal-length 8-bit Fibonacci LFSR** feedback configurations were investigated:

| Polynomial family | XOR feedback taps |
|---|---|
| **P1** | `[7, 5, 4, 3]` |
| **P2** | `[7, 5, 4, 1]` |
| **P3** | `[7, 6, 1, 0]` |

Using the implementation adopted in the notebook, the feedback bit is formed by XORing the selected state bits before the register is shifted.

All three are maximal-length configurations, so a non-zero seed traverses the **255 non-zero states** of the 8-bit LFSR.

The **seed does not change the hardware width or flip-flop count**. It determines the initial state and therefore changes the phase/order of the generated sequence.

### Important distinction

Numeric distance between two seed values is **not** by itself a meaningful measure of sequence/phase distance. Any phase-related comparison must be based on positions in the LFSR cycle rather than simply subtracting the integer seed values.

---

# 4. Why Seed Selection Matters

For stochastic computing, matching the individual probability is not sufficient.

Two streams can each represent their input values reasonably well and still interact poorly when combined by an AND gate because of **statistical dependence/correlation**.

Therefore, the investigation treats the SNG configuration as a combination of:

```text
Polynomial + Seed + Stream Length + Input Values + Stream Dependence
```

Rather than selecting a single seed from one example, the study evaluates candidate configurations across the **full 8-bit input domain**.

---

# 5. Error Metrics

Several different errors are measured because they answer different questions.

## 5.1 Representation Error

For an input `X`, the ideal normalized value is:

```text
x = X / 255
```

If the generated stream has measured density `p_A`, then:

```text
E_rep = p_A - x
```

and the absolute representation error is:

```text
|E_rep| = |p_A - x|
```

This measures **how accurately an individual SNG represents its input**.

---

## 5.2 Dependence / Correlation Error

For the two streams:

```text
D = p_AND - p_A × p_B
```

where `p_AND` is the measured one-density after the AND operation.

If the streams were perfectly independent, we would expect:

```text
p_AND = p_A × p_B
```

Therefore:

- `D ≈ 0` → close to independence
- `D > 0` → positive dependence; AND tends to produce more ones
- `D < 0` → negative dependence; AND tends to produce fewer ones

The exhaustive study uses **mean absolute dependence error** as a diagnostic:

```text
MAE_dep = mean(|p_AND - p_A × p_B|)
```

Dependence error is important, but it is **not the primary ranking metric** for the multiplier.

---

## 5.3 Multiplication Error

The ideal normalized product is:

```text
x × y = (A/255) × (B/255)
```

The stochastic estimate is `p_AND`, giving:

```text
E_mult = p_AND - x × y
```

The primary ranking metric is:

```text
Multiplication MAE = mean(|E_mult|)
```

Additional metrics include:

- **RMSE** — emphasizes larger errors
- **Maximum absolute error** — worst-case input pair
- **Bias** — average signed error
- **Mean absolute dependence error** — dependence diagnostic
- **Mean absolute representation error** — SNG quality diagnostic

The reported normalized error percentages should be interpreted as **percentage of normalized/full scale**, not relative product error.

---

# 6. Error Decomposition

The multiplier error can be decomposed into dependence and representation contributions:

```text
p_AND - xy
= [p_AND - p_A p_B]
  + [p_A p_B - xy]
```

or conceptually:

```text
Multiplication error
        =
Dependence error
        +
Representation-product error
```

This distinction is important because:

```text
Representation error ≠ Dependence error ≠ Multiplication error
```

A pair with excellent individual SNG representation does not automatically produce the best stochastic multiplier.

---

# 7. Exhaustive Candidate Evaluation

The investigation evaluates selected LFSR/seed candidates exhaustively rather than relying on a few hand-picked input examples.

For each stream length, the selected candidate pool contains **9 SNG configurations** (three seeds from each polynomial family).

All unique non-self SNG pairs are evaluated:

```text
C(9,2) = 36 pairs per stream length
```

For both `L=16` and `L=32`:

```text
36 × 2 = 72 pair configurations
```

Each pair is tested over the complete:

```text
256 × 256 = 65,536
```

possible input combinations.

This gives:

```text
72 × 65,536 = 4,718,592
```

input-pair evaluations across the two stream lengths.

The phrase **“best pair”** in this repository therefore means:

> **Best within the exhaustively evaluated candidate pool.**

It does not claim that no untested SNG architecture or seed could perform better.

---

# 8. Best SNG Pairs Found

## L = 16

The best pair within the evaluated candidate pool is:

```text
P3-174 × P3-121
```

Key results:

| Metric | Result |
|---|---:|
| Multiplication MAE | **0.027448** |
| Multiplication RMSE | **0.034734** |
| Maximum absolute multiplication error | **0.126356** |
| Bias | **+0.000868** |
| Mean absolute dependence error | **0.020523** |
| Mean absolute representation error | **0.018233** |

The normalized MAE corresponds to approximately **2.7448% of normalized/full scale**.

---

## L = 32

The best pair within the evaluated candidate pool is:

```text
P2-198 × P2-86
```

Key results:

| Metric | Result |
|---|---:|
| Multiplication MAE | **0.018916** |
| Multiplication RMSE | **0.024183** |
| Maximum absolute multiplication error | **0.097141** |
| Bias | **−0.001496** |
| Mean absolute dependence error | **0.023437** |
| Mean absolute representation error | **0.019607** |

The normalized MAE corresponds to approximately **1.8916% of normalized/full scale**.

The L=32 winner improves multiplication MAE by approximately **31.08%** compared with the L=16 winner.

---

# 9. Why L = 32 Is the Current RTL Target

The move from 16 to 32 stochastic bits improves output resolution:

```text
L = 16  → density step = 1/16 = 6.25%
L = 32  → density step = 1/32 = 3.125%
```

The exhaustive results show that the selected L=32 pair provides lower overall multiplication MAE and RMSE and a lower worst-case absolute multiplication error than the selected L=16 pair.

Therefore, **L=32 is the current preferred configuration for RTL implementation**, while L=16 remains useful as a lower-latency/lower-stream-length comparison point.

This is an accuracy-driven decision based on the measured candidate-pool results rather than a claim that L=32 is universally optimal for every hardware objective.

---

# 10. Interactive Simulator

The repository includes a standalone HTML simulator for demonstrating the selected SNG configurations without requiring Python or external libraries.

It supports:

- Stream length selection: `16` or `32`
- Ranked SNG-pair selection
- Manual 8-bit input entry (`A`, `B`)
- Stochastic bitstream generation
- Number of ones and one-density
- AND-product stream
- Exact binary product
- Stochastic decoded product
- Representation error
- Dependence error
- Normalized multiplication error
- Absolute multiplication error
- Integer-scale product error
- Running/cumulative density visualization
- Ranking information for candidate pairs

The simulator also supports selecting a **ranked pair** directly so that the best-performing candidate can be demonstrated quickly.

For demonstration purposes, an automatic input-selection mode can identify the input pair giving the **smallest absolute multiplication error** for the selected ranked SNG pair. This is a best-case input demonstration and should not be confused with the exhaustive MAE used to rank the SNG pair itself.

---

# 11. Understanding Relative Product Error

The normalized multiplication error used for candidate ranking is different from conventional relative product error.

For a non-zero exact product:

```text
Relative Error (%)
= |P_SC - P_exact| / |P_exact| × 100
```

where:

```text
P_SC = p_AND × 255²
P_exact = A × B
```

Relative error is useful for an individual example, but it can become very large for small products because the exact product appears in the denominator. Therefore, the project uses **normalized multiplication MAE as the primary global ranking metric** and uses relative error as an additional per-input diagnostic.

---

# 12. Current Research Direction

The current work establishes the software and algorithmic foundation for a hardware stochastic multiplier.

Planned/next-stage work includes:

```text
Exhaustive SNG analysis
        ↓
Selected L=32 SNG pair
        ↓
RTL implementation
        ↓
Simulation / verification
        ↓
Hardware synthesis and resource analysis
        ↓
Comparison against conventional multiplier architectures
```

The intended final hardware structure is a compact stochastic datapath based on:

```text
Two 8-bit LFSRs
      +
Two comparator blocks
      +
One AND gate
      +
Output counting/decoding logic (for digital evaluation)
```

For the two independent LFSRs alone, the state storage is **16 flip-flops**.

---

# 13. Key Takeaways

1. **Stochastic multiplication trades arithmetic complexity for sequence length and statistical quality.**
2. **An AND gate performs unipolar multiplication only under the required independence relationship.**
3. **SNG representation quality and stream dependence are separate issues.**
4. **LFSR polynomial and seed selection materially affect the stochastic multiplication result.**
5. **Exhaustive 256×256 evaluation is much more reliable than judging an SNG from a few sample inputs.**
6. **L=32 currently gives the strongest result among the evaluated candidate configurations.**
7. The current best candidate is **P2-198 × P2-86 for L=32**, with approximately **1.89% normalized multiplication MAE** over the full evaluated 8-bit input space.

---

## Scope and Reproducibility

The reported rankings are tied to the exact implementation, LFSR tap definitions, seed set, comparator rule, stream lengths, and candidate pool used in the investigation notebook.

The results should therefore be interpreted as **experimental findings for this configuration space**, not as universal rankings of every possible stochastic-computing SNG.

---

## Author

**Kousik Kar**  
B.Tech — Electronics / VLSI-oriented coursework and projects

This repository is part of an ongoing exploration of **stochastic computing, hardware-oriented SNG design, RTL implementation, and digital arithmetic architectures**.

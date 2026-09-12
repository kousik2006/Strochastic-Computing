# Stochastic Computing — SNG Investigation, RTL Hardware & Booth Reference

> **An 8-bit stochastic-computing study from fundamentals and exhaustive SNG investigation to synthesizable RTL, Vivado evaluation, and a structural 8×8 Booth multiplier reference.**

---

## Authors

**Kousik Kar**  
**Mustab Al Mamun**  
**Jadavpur University**  
**Department of Electronics & Tele-Communication Engineering (ETCE)**

---

## 1. Project Overview

This repository documents a hardware-oriented study of **unipolar stochastic computing (SC)** for an unsigned **8-bit × 8-bit multiplier**.

The project deliberately progresses through several stages rather than jumping directly to RTL:

```text
Stochastic-computing fundamentals
            ↓
Initial software simulation
            ↓
Finite-stream error analysis
            ↓
Hardware-oriented SNG design
            ↓
8-bit LFSR polynomial investigation
            ↓
Seed investigation
            ↓
Exhaustive SNG-pair evaluation
            ↓
L = 16 vs L = 32 comparison
            ↓
Candidate selection
            ↓
RTL implementation
            ↓
RTL simulation / verification
            ↓
Vivado synthesis
            ↓
Area + power evaluation
            ↓
Structural 8×8 Booth multiplier
            ↓
Architectural comparison
```

The central research question is:

> **How do stochastic-stream length, LFSR feedback polynomial, seed, stream representation, and stream dependence affect the accuracy of an 8-bit stochastic multiplier, and what hardware architecture results from the investigation?**

The repository therefore contains both **algorithmic investigation** and **hardware implementation** material.

---

## 2. Project Specification

The stochastic multiplier studied here uses:

| Parameter | Specification |
|---|---|
| Input A | Unsigned 8-bit, `0–255` |
| Input B | Unsigned 8-bit, `0–255` |
| Normalization | `X / 255` |
| Exact product range | `0–65025` |
| SC representation | Unipolar / one-density |
| Multiplication operator | AND gate |
| LFSR width | 8 bits |
| SNG structure | 8-bit LFSR + comparator |
| Stream lengths investigated | `L=16`, `L=32` |
| Candidate SNG configurations | 9 |
| Pair configurations per stream length | 36 non-self pairs |
| Input combinations | `256 × 256 = 65,536` |
| Total pair/length evaluations | `72 × 65,536 = 4,718,592` |

The project does **not** claim that the selected configuration is universally optimal. The reported winners are the best configurations **within the evaluated candidate pool and investigated implementation**.

---

# 3. Stochastic Computing Fundamentals

## 3.1 Binary-to-stochastic representation

In unipolar stochastic computing, a normalized value in `[0,1]` is represented by the probability, or one-density, of a stochastic bitstream.

For an unsigned 8-bit value `X`:

```text
x = X / 255
```

For a finite stochastic stream of length `L`, the measured probability is:

```text
p̂ = Number of ones / L
```

Therefore the stream does not necessarily represent the ideal value exactly. The finite observation window introduces quantization/approximation effects.

For the two stream lengths used in this project:

```text
L = 16  → density step = 1/16 = 6.25%
L = 32  → density step = 1/32 = 3.125%
```

This difference is one reason why both stream lengths were investigated.

---

## 3.2 Stochastic multiplication

For two stochastic streams representing normalized values `x` and `y`, unipolar multiplication can be performed by an AND gate when the streams satisfy the required independence relationship:

```text
A_SC ─────┐
          AND ────> Z_SC
B_SC ─────┘
```

Ideally:

```text
P(Z=1) = P(A=1) × P(B=1)
```

The measured output density is therefore used as the stochastic estimate of the normalized product.

The corresponding decoded full-scale product is:

```text
P_SC = p_AND × 255²
```

while the exact binary product is:

```text
P_exact = A × B
```

The important architectural trade-off is that the arithmetic operator becomes extremely simple, while **sequence generation, stream statistics, dependence, finite-stream resolution, and output accumulation become important parts of the system**.

---

# 4. Initial Fundamentals Experiment

The first stage of the project establishes the stochastic-computing model in software before introducing hardware-oriented LFSRs.

The fundamentals notebook is:

```text
01_Fundamentals (1).ipynb
```

The intended experimental flow is:

```text
8-bit input
    ↓
Normalization
    ↓
Stochastic stream generation
    ↓
Finite-length stream
    ↓
AND multiplication
    ↓
Count ones / estimate density
    ↓
Decode stochastic product
    ↓
Compare with exact binary product
    ↓
Calculate error
```

### Why start here?

The initial experiment separates the **mathematical concept of stochastic multiplication** from the later hardware problem of generating suitable sequences.

Before designing an LFSR/SNG, it is necessary to understand:

- how probability is represented;
- how finite stream length affects the estimate;
- how an AND gate performs multiplication;
- how the stochastic result differs from the exact result; and
- which error mechanisms need to be investigated further.

The notebook contains the project’s initial simulation evidence and should be consulted for the exact figures and experiment outputs.

---

# 5. From Software Streams to Hardware SNGs

After establishing the baseline, the project moves toward a **hardware-realizable Stochastic Number Generator (SNG)**.

The basic SNG is:

```text
             ┌───────────────┐
Input X ─────>│   Comparator  │────> stochastic bit
             │               │
LFSR state ─>│               │
             └───────────────┘
                    ↑
             8-bit LFSR
```

The comparator rule used by the investigation is:

```text
stochastic_bit = 1  if LFSR_state < input
                  0  otherwise
```

Thus the input value acts as a threshold while the LFSR supplies a deterministic pseudo-random sequence of states.

### Basic hardware cost

One SNG contains an 8-bit LFSR, which means **8 state flip-flops per LFSR/SNG**.

For two input streams:

```text
2 × 8 = 16 LFSR state flip-flops
```

This is the LFSR state-storage component only; the complete multiplier also requires comparators, AND logic, control/clocking, and output counting/decoding where applicable.

---

# 6. LFSR Architecture

The project investigates **8-bit Fibonacci LFSRs**.

A conceptual structure is:

```text
 ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐
 │FF7│→│FF6│→│FF5│→│FF4│→│FF3│→│FF2│→│FF1│→│FF0│
 └───┘ └───┘ └───┘ └───┘ └───┘ └───┘ └───┘ └───┘
    ↑
    └──── XOR feedback from selected taps
```

Important properties investigated in this project include:

- 8-bit state width;
- feedback XOR network;
- shifting of the register state;
- non-zero initialization seed;
- maximal-length operation; and
- the sequence ordering produced by different feedback polynomials and seeds.

For a maximal-length 8-bit LFSR, a non-zero seed traverses the **255 non-zero states** before repeating.

A zero seed must be avoided because it can lock the LFSR into the all-zero state for the usual XOR-feedback implementation.

---

# 7. Three Investigated LFSR Polynomial Families

The investigation compares three maximal-length 8-bit Fibonacci LFSR feedback configurations:

| Family | Tap set |
|---|---|
| **P1** | `[7, 5, 4, 3]` |
| **P2** | `[7, 5, 4, 1]` |
| **P3** | `[7, 6, 1, 0]` |

All three have the same state width and therefore the same basic LFSR flip-flop count.

What changes is the **feedback structure and resulting state/sequence ordering**.

The investigation asks whether those sequence differences matter when finite stochastic streams are used together in an AND multiplier.

### Important interpretation

The project does **not** assume that one polynomial is inherently superior.

Instead, the polynomial is treated as one part of the SNG configuration and evaluated experimentally together with the seed and stream length.

---

# 8. Seed Selection and Sequence Phase

The seed determines the initial state of the LFSR.

For the same polynomial:

```text
Same polynomial
       │
 ┌─────┼─────┐
 ↓     ↓     ↓
Seed A Seed B Seed C
 ↓     ↓     ↓
Seq A  Seq B  Seq C
```

Changing the seed does not change the fundamental LFSR hardware. It changes the initial state and therefore the phase/order of the generated sequence.

This matters because stochastic multiplication combines **two finite sequences**, not just two abstract probabilities.

Two streams can have good individual representation while interacting differently under an AND operation.

### Seed-distance caution

The numeric difference between two seed values is not, by itself, a meaningful measure of phase distance. Phase relationships should be considered in terms of positions in the LFSR cycle.

---

# 9. Representation Error

Representation error measures how closely an individual SNG represents its intended normalized input.

For an input `X`:

```text
x = X / 255
```

If the measured stream density is `p_A`, the signed representation error is:

```text
E_rep = p_A - x
```

and the absolute representation error is:

```text
|E_rep| = |p_A - x|
```

This answers:

> **How accurately does the SNG represent an individual input?**

Representation quality is necessary, but it is not sufficient to guarantee the best multiplier accuracy.

---

# 10. Dependence / Correlation Error

For two stochastic streams, let:

- `p_A` = measured density of stream A;
- `p_B` = measured density of stream B;
- `p_AND` = measured density after the AND operation.

The project uses:

```text
D = p_AND − p_A × p_B
```

Under the ideal independence relationship:

```text
p_AND = p_A × p_B
```

Therefore, `D` measures the deviation of the observed AND density from the product of the two measured individual densities.

The investigation uses mean absolute dependence error as a diagnostic:

```text
MAE_dep = mean(|p_AND − p_A × p_B|)
```

This is distinct from representation error and distinct from overall multiplication MAE.

---

# 11. Multiplication Error

For normalized inputs:

```text
x = A / 255
y = B / 255
```

The ideal normalized product is:

```text
xy
```

The stochastic estimate is:

```text
p_AND
```

Therefore:

```text
E_mult = p_AND − xy
```

The primary global ranking metric used in the investigation is the mean absolute multiplication error:

```text
MAE = mean(|p_AND − xy|)
```

Supporting metrics are:

- RMSE;
- maximum absolute multiplication error;
- bias;
- mean absolute dependence error; and
- mean absolute representation error.

---

# 12. Error Decomposition

A useful way to understand the project’s results is:

```text
p_AND − xy

= [p_AND − p_A p_B]
  + [p_A p_B − xy]
```

The first term represents the dependence-related contribution:

```text
p_AND − p_A p_B
```

The second term represents the mismatch caused by the individual stream representations:

```text
p_A p_B − xy
```

Therefore:

```text
Representation error ≠ Dependence error ≠ Multiplication error
```

This is one of the important conceptual findings of the investigation.

---

# 13. Exhaustive SNG-Pair Investigation

The main investigation is contained in:

```text
02_Investigation (11).ipynb
```

The study does not rely only on a handful of input examples. It evaluates a candidate pool across the complete 8-bit input-pair space.

## Candidate pool

There are **9 SNG configurations**, formed from the three polynomial families and selected seeds.

For each stream length, the number of unique non-self pairs is:

```text
C(9,2) = 36
```

Two stream lengths are investigated:

```text
L = 16
L = 32
```

Therefore:

```text
36 × 2 = 72 pair/stream-length configurations
```

The complete unsigned 8-bit input space contains:

```text
256 × 256 = 65,536
```

input pairs.

Thus the total number of evaluated pair/input combinations is:

```text
72 × 65,536

= 4,718,592
```

### Meaning of “best pair”

The selected pair is the **best within the evaluated candidate pool**.

This does not imply that every possible LFSR polynomial, seed, stream architecture, or stochastic encoding has been searched.

---

# 14. Investigation Methodology

The investigation can be understood as:

```text
9 SNG candidates
       ↓
36 unique pairs per L
       ↓
L = 16 and L = 32
       ↓
65,536 input pairs
       ↓
Compute stream densities
       ↓
AND streams
       ↓
Measure stochastic product
       ↓
Calculate errors
       ↓
Aggregate metrics
       ↓
Rank candidate pairs
```

The most important output of this stage is not simply a single number. The investigation identifies how **polynomial, seed, stream length, representation, and dependence interact**.

---

# 15. Primary and Supporting Metrics

## Primary ranking metric

### Multiplication MAE

```text
MAE = mean(|p_AND − xy|)
```

This represents the average absolute normalized multiplication error across the evaluated input space.

## Supporting metrics

### RMSE

Measures root-mean-square error and gives greater emphasis to larger errors.

### Maximum absolute multiplication error

Identifies the worst observed absolute multiplication error in the evaluated input space.

### Bias

Measures the average signed error.

### Mean absolute dependence error

Measures the average magnitude of the dependence diagnostic.

### Mean absolute representation error

Measures the average magnitude of the individual SNG representation error.

No single supporting metric is treated as a replacement for multiplication MAE when ranking the multiplier candidates.

---

# 16. L = 16 Investigation Result

The best candidate within the evaluated L=16 pool is:

```text
P3-174 × P3-121
```

Verified investigation metrics:

| Metric | Result |
|---|---:|
| Multiplication MAE | **0.027448** |
| RMSE | **0.034734** |
| Maximum absolute multiplication error | **0.126356** |
| Bias | **+0.000868** |
| Mean absolute dependence error | **0.020523** |
| Mean absolute representation error | **0.018233** |

The normalized multiplication MAE is approximately:

```text
2.7448% of normalized/full scale
```

These values should be interpreted as results for the evaluated candidate pool and the exact investigation configuration.

---

# 17. L = 32 Investigation Result

The best candidate within the evaluated L=32 pool is:

```text
P2-198 × P2-86
```

Verified investigation metrics:

| Metric | Result |
|---|---:|
| Multiplication MAE | **0.018916** |
| RMSE | **0.024183** |
| Maximum absolute multiplication error | **0.097141** |
| Bias | **−0.001496** |
| Mean absolute dependence error | **0.023437** |
| Mean absolute representation error | **0.019607** |

The normalized multiplication MAE is approximately:

```text
1.8916% of normalized/full scale
```

Again, this is the best result **within the evaluated L=32 candidate pool**.

---

# 18. L = 16 vs L = 32

| Metric | L=16 | L=32 |
|---|---:|---:|
| Best pair | P3-174 × P3-121 | P2-198 × P2-86 |
| Multiplication MAE | 0.027448 | **0.018916** |
| RMSE | 0.034734 | **0.024183** |
| Maximum absolute error | 0.126356 | **0.097141** |
| Density resolution | 6.25% | **3.125%** |

The reduction in MAE is approximately:

```text
31.08%
```

Thus L=32 gives the stronger measured multiplication-accuracy result among the investigated configurations.

### Important interpretation

The correct conclusion is:

> **L=32 is the current preferred configuration for this investigation.**

It is not correct to conclude:

> “L=32 is universally optimal.”

A longer stochastic stream provides finer probability resolution but requires more cycles/time to process one stochastic result.

---

# 19. An Important Investigation Finding

One particularly useful observation is that the best L=32 pair does **not** have a lower mean absolute dependence error than the best L=16 pair.

```text
L=16 winner dependence MAE = 0.020523

L=32 winner dependence MAE = 0.023437
```

Yet the L=32 winner has lower multiplication MAE:

```text
L=16 MAE = 0.027448
L=32 MAE = 0.018916
```

This demonstrates why the investigation cannot be reduced to one diagnostic such as dependence error.

Overall multiplication accuracy depends on the interaction of:

```text
individual representation
        +
stream dependence
        +
finite stream length
        +
sequence ordering
```

This is an important reason for evaluating the complete multiplier error rather than selecting an SNG using only one intermediate metric.

---

# 20. Interactive Simulator

The repository also contains an interactive HTML simulator for exploring the stochastic multiplier.

The simulator is intended to make the investigation easier to understand interactively.

Its documented functionality includes:

- selecting `L=16` or `L=32`;
- selecting ranked SNG pairs;
- entering manual 8-bit inputs;
- generating the corresponding stochastic streams;
- observing stream ones and one-density;
- applying the AND multiplier;
- comparing stochastic and exact products;
- examining representation error;
- examining dependence error;
- examining normalized multiplication error;
- examining absolute multiplication error; and
- viewing cumulative/running density behavior.

A ranked pair can be selected for demonstration so that the configurations identified by the exhaustive investigation can be inspected directly.

---

# 21. RTL Hardware Implementation

The hardware implementation is separated into independent stream-length configurations.

Directory:

```text
RTL_L16_L32/
```

Structure:

```text
RTL_L16_L32/
├── common/
│   ├── sc_dff.v
│   ├── sc_lfsr8.v
│   ├── sc_comparator8_lt.v
│   ├── sc_sng8.v
│   └── sc_stochastic_multiplier.v
│
├── L16/
│   ├── sc_multiplier_16.v
│   ├── tb_sc_multiplier_16.v
│   ├── strochastic_16 AREA.png
│   └── strochastic_16_power.png
│
├── L32/
│   ├── sc_multiplier_32.v
│   ├── tb_sc_multiplier_32.v
│   ├── 32_sc_area.png
│   └── 32_sc_power.png
│
├── Makefile
└── README.md
```

The L16 and L32 top-level designs are intentionally separate. They are not selected dynamically at run time.

---

# 22. Common RTL Modules

## `sc_dff.v`

Provides the D flip-flop primitive used by the hardware-oriented stochastic sequence-generation logic.

## `sc_lfsr8.v`

Implements the 8-bit LFSR sequence generator used by the SNG architecture.

## `sc_comparator8_lt.v`

Implements the 8-bit less-than comparison between the LFSR state and the input threshold.

The SNG bit follows the project’s comparison rule:

```text
1 if LFSR_state < input
0 otherwise
```

## `sc_sng8.v`

Combines the LFSR and comparator into an 8-bit-input stochastic number generator.

## `sc_stochastic_multiplier.v`

Provides the common stochastic multiplication building block used by the stream-length-specific top-level wrappers.

---

# 23. L = 16 RTL Configuration

Directory:

```text
RTL_L16_L32/L16/
```

Top-level module:

```text
sc_multiplier_16
```

Selected SNG pair:

```text
P3-174 × P3-121
```

Stream length:

```text
16 cycles
```

Testbench:

```text
tb_sc_multiplier_16
```

The testbench is intended only for simulation and must not be included as a synthesis design source.

The repository also contains the corresponding Vivado area and power screenshots:

```text
strochastic_16 AREA.png
strochastic_16_power.png
```

These images are the hardware-evaluation artifacts associated with the L16 configuration.

---

# 24. L = 32 RTL Configuration

Directory:

```text
RTL_L16_L32/L32/
```

Top-level module:

```text
sc_multiplier_32
```

Selected SNG pair:

```text
P2-198 × P2-86
```

Stream length:

```text
32 cycles
```

Testbench:

```text
tb_sc_multiplier_32
```

The repository also contains the corresponding Vivado artifacts:

```text
32_sc_area.png
32_sc_power.png
```

L=32 is the current preferred accuracy configuration from the exhaustive investigation.

---

# 25. RTL Simulation

The project provides independent simulation targets so that L=16 and L=32 are not accidentally compiled together.

From:

```text
RTL_L16_L32/
```

run:

```bash
make sim16
```

for the L16 configuration, or:

```bash
make sim32
```

for the L32 configuration.

The Makefile uses Icarus Verilog with SystemVerilog parsing enabled:

```text
iverilog -g2005-sv
```

Each simulation explicitly selects its corresponding testbench top.

### Important simulation rule

Do **not** compile both L16 and L32 testbenches together.

Each simulation should contain:

```text
one DUT top
+
one matching testbench
```

---

# 26. Vivado Synthesis and Fair Comparison

For L16 synthesis, the design sources are:

```text
common/sc_dff.v
common/sc_lfsr8.v
common/sc_comparator8_lt.v
common/sc_sng8.v
common/sc_stochastic_multiplier.v
L16/sc_multiplier_16.v
```

Synthesis top:

```text
sc_multiplier_16
```

For L32 synthesis:

```text
common/sc_dff.v
common/sc_lfsr8.v
common/sc_comparator8_lt.v
common/sc_sng8.v
common/sc_stochastic_multiplier.v
L32/sc_multiplier_32.v
```

Synthesis top:

```text
sc_multiplier_32
```

The testbench must remain a **Simulation Source**, not a Design Source.

### Fair area/power comparison

For meaningful comparison between L16, L32, and Booth, use the same:

- FPGA part;
- clock constraint;
- synthesis settings;
- implementation settings;
- timing assumptions; and
- activity assumptions.

Area and power results should always be reported together with the conditions under which they were measured.

---

# 27. Hardware Evaluation Artifacts

The repository contains the following Vivado result images.

## Stochastic L16

```text
RTL_L16_L32/L16/strochastic_16 AREA.png
RTL_L16_L32/L16/strochastic_16_power.png
```

## Stochastic L32

```text
RTL_L16_L32/L32/32_sc_area.png
RTL_L16_L32/L32/32_sc_power.png
```

These artifacts should be used as the evidence for the corresponding hardware evaluation. Numerical values should only be quoted when they can be read reliably from the actual reports/screenshots.

---

# 28. Why a Booth Multiplier Is Included

Stochastic computing should not be evaluated in isolation.

The repository therefore also contains a conventional **structural Booth multiplier** as a deterministic arithmetic reference.

The purpose is to provide a second architectural point for discussing:

- exactness;
- deterministic operation;
- arithmetic hardware;
- control complexity;
- area;
- power; and
- latency.

The comparison is architectural rather than a claim that one approach is universally better.

---

# 29. Structural 8×8 Booth Multiplier

Directory:

```text
Booths_8_bit/
```

Specification:

```text
8-bit multiplicand
×
8-bit multiplier
=
16-bit product
```

The Booth implementation is deliberately divided into **DATAPATH** and **CONTROL PATH**.

### Datapath

The datapath contains:

- accumulator `A`;
- multiplier register `Q`;
- `Q−1` register;
- multiplicand `M` extended to the datapath width;
- structural add/subtract logic;
- structural registers; and
- arithmetic right-shift operation.

### Control path

The controller is a one-hot FSM with states including:

```text
IDLE
LOAD
ADD
SUB
SHIFT
```

The iteration counter is an 8-position one-hot counter corresponding to exactly eight Booth iterations.

The implemented iteration sequence is:

```text
0 → 1 → 2 → 3 → 4 → 5 → 6 → 7
```

After the eighth iteration, the multiplication is complete.

---

# 30. Booth Recoding Rules

Booth examines:

```text
Q0, Q−1
```

The operation rules are:

| `Q0 Q−1` | Operation |
|---|---|
| `01` | `A = A + M` |
| `10` | `A = A − M` |
| `00` | No arithmetic operation |
| `11` | No arithmetic operation |

After the arithmetic decision:

```text
{A, Q, Q−1}
        ↓
Arithmetic right shift
        ↓
Counter update
        ↓
Next iteration
```

The DUT does not use the Verilog multiplication operator `*` for its actual multiplication datapath. The testbench may use `*` for calculating an expected/reference result.

---

# 31. Booth RTL File Organization

The Booth directory contains:

```text
Booths_8_bit/
├── README.txt
├── booth_8x8_structural.v
├── booth_adder16.v
├── booth_controller_onehot.v
├── booth_counter_onehot8.v
├── booth_datapath_8x8.v
├── booth_dff.v
├── booth_full_adder.v
├── booth_mux2_1bit.v
├── booth_reg1.v
├── booth_reg8.v
├── booth_reg16.v
├── tb_booth_8x8_structural.v
├── booth_area.png
└── booth_power.png
```

### Module roles

| File | Role |
|---|---|
| `booth_8x8_structural.v` | Top-level structural Booth multiplier |
| `booth_datapath_8x8.v` | Booth datapath |
| `booth_controller_onehot.v` | One-hot controller/FSM |
| `booth_counter_onehot8.v` | 8-position one-hot iteration counter |
| `booth_adder16.v` | Structural 16-bit adder |
| `booth_full_adder.v` | Full-adder primitive |
| `booth_mux2_1bit.v` | 1-bit 2:1 multiplexer primitive |
| `booth_dff.v` | DFF primitive |
| `booth_reg1.v` | 1-bit register |
| `booth_reg8.v` | 8-bit register |
| `booth_reg16.v` | 16-bit register |
| `tb_booth_8x8_structural.v` | Booth simulation testbench |
| `booth_area.png` | Vivado area/utilization artifact |
| `booth_power.png` | Vivado power artifact |

---

# 32. Booth Simulation and Synthesis Setup

Simulation top:

```text
tb_booth_8x8_structural
```

Synthesis top:

```text
booth_8x8_structural
```

Do not synthesize the testbench.

The maximum unsigned product that fits in the 16-bit output is:

```text
255 × 255 = 65025

65025 = 16'hFE01
```

The Booth datapath is designed for an 8-bit × 8-bit multiplication producing a 16-bit result.

---

# 33. Stochastic vs Booth: Architectural Perspective

| Characteristic | Stochastic Multiplier | Booth Multiplier |
|---|---|---|
| Representation | Probability / bitstream | Binary integer |
| Arithmetic operation | AND for unipolar multiplication | Add/subtract + shifts |
| Accuracy | Approximate for finite streams | Deterministic/exact arithmetic |
| Main sequence issue | Stream statistics and dependence | Binary operand/control behavior |
| SNG overhead | LFSR + comparator per input | No stochastic SNG |
| Stream length | L=16 or L=32 investigated | 8 Booth iterations |
| Output evaluation | Count/decode stochastic ones | Binary product directly |
| Latency | Depends on stream length and implementation | Eight algorithmic iterations |
| Area/power | Must be measured for implementation | Must be measured for implementation |
| Best use case | Approximate/probability-domain computation | Deterministic binary arithmetic |

This table is a conceptual architectural comparison. **Actual area, power, and timing conclusions must be based on matched Vivado measurements**, not on assumptions.

---

# 34. Research Findings

The major findings from the project are:

### Finding 1 — Stochastic multiplication simplifies the arithmetic operator

Unipolar multiplication can be implemented with an AND gate when the stochastic streams satisfy the required independence relationship.

### Finding 2 — Finite streams introduce approximation

The stochastic result is estimated from a finite number of bits. Increasing stream length improves density resolution but increases the number of cycles required to process a result.

### Finding 3 — LFSR sequence generation matters

Different maximal-length feedback polynomials produce different sequence orderings, even though they use the same 8-bit state width.

### Finding 4 — Seed selection matters

The seed changes the initial state and phase/order of the sequence and can therefore influence finite-stream interaction between two SNGs.

### Finding 5 — Representation and dependence are different

An SNG can represent an individual input well while the pair can still show dependence-related multiplication error.

### Finding 6 — Exhaustive evaluation is valuable

The investigation evaluates 4,718,592 pair/input combinations across L16 and L32 rather than relying on a few demonstration vectors.

### Finding 7 — The L16 and L32 winners are different

```text
L16 → P3-174 × P3-121
L32 → P2-198 × P2-86
```

This shows that the preferred sequence configuration can depend on stream length.

### Finding 8 — L32 has lower measured multiplication MAE

```text
L16 MAE = 0.027448
L32 MAE = 0.018916
```

The improvement is approximately:

```text
31.08%
```

### Finding 9 — Dependence error alone does not predict the final winner

The L32 winner has a higher mean absolute dependence error than the L16 winner, yet it has substantially lower overall multiplication MAE.

Therefore, overall multiplier accuracy must be evaluated directly.

---

# 35. Current Preferred Configuration

Based on the investigation performed in this repository:

```text
Stream length: L = 32

SNG A: P2-198
SNG B: P2-86

Multiplication MAE: 0.018916
```

This is the **current preferred accuracy configuration for the project**.

It should not be interpreted as a universal optimum because the search space is limited to the investigated candidate pool and exact experimental implementation.

---

# 36. Hardware Architecture Summary

The stochastic multiplier can be summarized as:

```text
                 INPUT A[7:0]
                      │
              ┌───────▼───────┐
              │   SNG A       │
              │ LFSR + CMP    │
              └───────┬───────┘
                      │
                A stochastic bit
                      │
                      ├─────────┐
                                │
                              ┌─▼─┐
                              │AND│
                              └─┬─┘
                                │
                        stochastic product
                                │
                              counter
                                │
                             decoder
                                │
                         digital estimate
                                │
                                └─────────┐
                                          │
                 INPUT B[7:0]             │
                      │                   │
              ┌───────▼───────┐           │
              │   SNG B       │           │
              │ LFSR + CMP    │           │
              └───────┬───────┘           │
                      │                   │
                B stochastic bit ─────────┘
```

At the sequence-generation level, the basic two-input architecture contains:

```text
2 × 8-bit LFSR
2 × comparator
1 × AND
output counting/decoding logic
```

The LFSR state storage alone is 16 flip-flops.

---

# 37. Hardware Trade-Off: L16 vs L32

The fundamental hardware structure does not change from L16 to L32:

```text
8-bit LFSR + comparator
```

What changes is the number of stochastic cycles used to form the result.

### L16

```text
16 cycles
6.25% density resolution
```

Advantages:

- shorter stochastic processing window;
- coarser probability resolution.

### L32

```text
32 cycles
3.125% density resolution
```

Advantages:

- finer probability resolution;
- lower measured multiplication MAE in the investigated candidate pool.

Trade-off:

```text
Longer stream
    ↓
Finer resolution
    ↓
Potentially better accuracy
    ↓
More cycles/time per result
```

The exact implementation-level latency and timing must be taken from the actual RTL/Vivado measurements.

---

# 38. Area, Power and Latency Reporting

The repository contains Vivado result images for:

```text
SC L16
SC L32
Booth 8×8
```

These metrics should be compared only under matched synthesis and implementation conditions.

### Area

Report the exact quantity shown by Vivado, such as utilization/resource count, rather than converting it into a different quantity without explanation.

### Power

Preserve distinctions such as:

- static power;
- dynamic power; and
- total power,

when those quantities are present in the report.

### Latency

Do not confuse:

```text
algorithmic cycle count
```

with:

```text
clock period
```

or:

```text
timing slack
```

A complete hardware comparison should state which definition of latency is being used.

If a numerical value is not clearly available in the repository artifact, it should be reported as:

```text
[VALUE NOT AVAILABLE IN SOURCES]
```

rather than estimated.

---

# 39. Reproducibility Notes

The experimental rankings depend on the exact:

- LFSR tap definitions;
- seed values;
- comparator rule;
- stream length;
- candidate pool;
- pair-selection rule;
- error definitions; and
- input-space evaluation procedure.

Changing any of these can change the ranking.

Therefore, the reported results should be understood as **reproducible findings for the implementation/configuration represented in this repository**, not as universal properties of all stochastic-computing systems.

---

# 40. Repository Structure

The current repository is organized into the following major areas:

```text
Strochastic-Computing/
│
├── 01_Fundamentals (1).ipynb
│       └── Fundamentals / initial stochastic-computing experiments
│
├── 02_Investigation (11).ipynb
│       └── Main LFSR/SNG investigation and exhaustive evaluation
│
├── RTL_L16_L32/
│   ├── common/
│   │   ├── sc_dff.v
│   │   ├── sc_lfsr8.v
│   │   ├── sc_comparator8_lt.v
│   │   ├── sc_sng8.v
│   │   └── sc_stochastic_multiplier.v
│   │
│   ├── L16/
│   │   ├── sc_multiplier_16.v
│   │   ├── tb_sc_multiplier_16.v
│   │   ├── strochastic_16 AREA.png
│   │   └── strochastic_16_power.png
│   │
│   ├── L32/
│   │   ├── sc_multiplier_32.v
│   │   ├── tb_sc_multiplier_32.v
│   │   ├── 32_sc_area.png
│   │   └── 32_sc_power.png
│   │
│   ├── Makefile
│   └── README.md
│
├── Booths_8_bit/
│   ├── README.txt
│   ├── booth_8x8_structural.v
│   ├── booth_datapath_8x8.v
│   ├── booth_controller_onehot.v
│   ├── booth_counter_onehot8.v
│   ├── booth_adder16.v
│   ├── booth_full_adder.v
│   ├── booth_mux2_1bit.v
│   ├── booth_dff.v
│   ├── booth_reg1.v
│   ├── booth_reg8.v
│   ├── booth_reg16.v
│   ├── tb_booth_8x8_structural.v
│   ├── booth_area.png
│   └── booth_power.png
│
└── README.md
```

The exact GitHub tree is the authoritative source if additional files are added later.

---

# 41. Suggested Workflow for a New User

## Step 1 — Understand the fundamentals

Open:

```text
01_Fundamentals (1).ipynb
```

Run through the stochastic representation and initial multiplication experiments.

## Step 2 — Study the investigation

Open:

```text
02_Investigation (11).ipynb
```

Follow the progression from LFSR configuration and seed selection to pair evaluation and ranking.

Pay particular attention to the graphical investigation results.

## Step 3 — Verify the selected configurations

The current selected pairs are:

```text
L16 → P3-174 × P3-121
L32 → P2-198 × P2-86
```

## Step 4 — Simulate RTL

From `RTL_L16_L32/`:

```bash
make sim16
make sim32
```

## Step 5 — Synthesize independently

Use:

```text
sc_multiplier_16
```

and:

```text
sc_multiplier_32
```

as separate synthesis tops.

## Step 6 — Inspect Vivado reports

Record area, power, and timing/latency information directly from the Vivado reports.

## Step 7 — Study Booth

Open:

```text
Booths_8_bit/README.txt
```

Then inspect the datapath, controller, counter, structural building blocks, and testbench.

## Step 8 — Compare architectures

Compare stochastic and Booth architectures using measured data and clearly stated conditions.

---

# 42. Important Limitations

This project is an investigation of a defined candidate space and hardware configuration.

The main limitations include:

1. The SNG search is limited to the candidate configurations included in the investigation.
2. Only the investigated LFSR polynomial families and selected seeds are included in the reported ranking.
3. Only L=16 and L=32 are evaluated in the current study.
4. Finite-stream behavior means stochastic results are approximate.
5. Stream dependence can affect multiplication accuracy.
6. Area and power depend on synthesis/implementation conditions.
7. A stochastic architecture should not be called “lower power” or “smaller” without a matched hardware measurement.
8. The selected L32 configuration is preferred based on the investigated accuracy results, not as a universal optimum.

---

# 43. Final Project Summary

This project demonstrates a complete path from a mathematical stochastic-computing concept to hardware-oriented digital implementation.

The key progression is:

```text
Probability-domain representation
        ↓
Finite stochastic streams
        ↓
AND-based multiplication
        ↓
LFSR-based SNG
        ↓
Polynomial + seed investigation
        ↓
Representation / dependence analysis
        ↓
Exhaustive candidate-pair evaluation
        ↓
L16 / L32 comparison
        ↓
Selected SNG configuration
        ↓
Synthesizable RTL
        ↓
Vivado hardware evaluation
        ↓
Conventional Booth reference
```

The investigation identifies:

```text
L16 best:
P3-174 × P3-121
MAE = 0.027448
```

and:

```text
L32 best:
P2-198 × P2-86
MAE = 0.018916
```

with approximately:

```text
31.08% lower MAE for the L32 winner
```

within the evaluated candidate pool.

The most important lesson is not simply that L32 performed better. It is that **stochastic multiplier accuracy is an interaction problem** involving representation, sequence ordering, stream length, and dependence.

The RTL stage then translates the statistically selected architecture into actual digital hardware, where area, power, timing, and processing latency become additional engineering constraints.

The Booth implementation provides a deterministic arithmetic reference against which those trade-offs can be discussed.

---

# 44. Key Takeaways

> **1. Stochastic multiplication can replace a conventional arithmetic multiplication operation with an AND gate in the unipolar representation.**

> **2. The simplicity of the arithmetic operator shifts complexity toward sequence generation and statistical accuracy.**

> **3. LFSR polynomial and seed selection influence finite-stream behavior.**

> **4. Representation error and dependence error are different phenomena.**

> **5. Exhaustive input-space evaluation gives a much stronger basis for SNG-pair selection than a few example vectors.**

> **6. The best pair depends on the investigated stream length and candidate pool.**

> **7. L=32 is currently preferred for accuracy within this study.**

> **8. Hardware evaluation must consider area, power, latency, and synthesis conditions rather than assuming stochastic computing is automatically superior.**

> **9. Booth provides a useful deterministic reference architecture for the final hardware comparison.**

---

# 45. Final Message

The project can be summarized in one sentence:

> **From probability-domain computation to synthesizable digital hardware — using exhaustive SNG investigation to guide an RTL stochastic multiplier and comparing it against a structural Booth arithmetic architecture.**

---

## Authors

**Kousik Kar**  
**Mustab Al Mamun**  
**Jadavpur University — ETCE**

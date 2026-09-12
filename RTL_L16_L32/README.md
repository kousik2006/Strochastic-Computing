# Separate L=16 and L=32 RTL Evaluation

This directory intentionally separates the two stream-length experiments so that simulation, synthesis, area and power reports can be generated independently.

## Directory structure

```text
RTL_L16_L32/
├── common/
│   ├── sc_dff.v
│   ├── sc_lfsr8.v
│   ├── sc_comparator8_lt.v
│   ├── sc_sng8.v
│   └── sc_stochastic_multiplier.v
├── L16/
│   ├── sc_multiplier_16.v
│   └── tb_sc_multiplier_16.v
├── L32/
│   ├── sc_multiplier_32.v
│   └── tb_sc_multiplier_32.v
└── Makefile
```

## L=16

Top module: `sc_multiplier_16`

Fixed SNG pair: **P3-174 × P3-121**

Stream length: **16 cycles**

The testbench is `L16/tb_sc_multiplier_16.v`. It tests only the L=16 DUT and waits for `done` before reading the final product.

## L=32

Top module: `sc_multiplier_32`

Fixed SNG pair: **P2-198 × P2-86**

Stream length: **32 cycles**

The testbench is `L32/tb_sc_multiplier_32.v`. It tests only the L=32 DUT and waits for `done` before reading the final product.

## Simulation

From this directory:

```bash
make sim16
make sim32
```

Do not compile both testbenches together. Each simulation has exactly one testbench and one DUT top.

## Vivado synthesis: L=16

Add these as **Design Sources**:

```text
common/sc_dff.v
common/sc_lfsr8.v
common/sc_comparator8_lt.v
common/sc_sng8.v
common/sc_stochastic_multiplier.v
L16/sc_multiplier_16.v
```

Set synthesis top to:

```text
sc_multiplier_16
```

Add `L16/tb_sc_multiplier_16.v` only as a **Simulation Source**, never as a synthesis source.

## Vivado synthesis: L=32

Add these as **Design Sources**:

```text
common/sc_dff.v
common/sc_lfsr8.v
common/sc_comparator8_lt.v
common/sc_sng8.v
common/sc_stochastic_multiplier.v
L32/sc_multiplier_32.v
```

Set synthesis top to:

```text
sc_multiplier_32
```

Add `L32/tb_sc_multiplier_32.v` only as a **Simulation Source**, never as a synthesis source.

## Important for fair area/power comparison

Use the same FPGA part, clock constraint, synthesis settings and implementation settings for both runs. The testbench must not be part of the synthesized design.

The two top-level wrappers are fixed configurations; there is no runtime L-select signal. Therefore L=16 and L=32 are genuinely separate hardware configurations for resource/power comparison.

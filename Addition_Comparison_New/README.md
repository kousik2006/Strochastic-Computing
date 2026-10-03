# Addition_Comparison_New

Clean, modular RTL for comparing:

1. Conventional binary addition
2. LFSR-based stochastic scaled addition
3. Sobol-based stochastic scaled addition

## Core RTL

- binary_adder.v — parameterized N-bit binary adder
- lfsr.v — parameterized LFSR
- lfsr_sng.v — LFSR + comparator SNG
- sobol.v — parameterized compact 1-D base-2 Sobol generator
- sobol_sng.v — Sobol + comparator SNG
- select_toggle.v — alternating 0/1 select stream
- mux2.v — 2:1 one-bit MUX
- sc_adder_lfsr.v — LFSR stochastic scaled adder
- sc_adder_sobol.v — Sobol stochastic scaled adder
- stochastic_counter.v — optional stochastic-output counter

## Encoding

Both SNGs use:

    stochastic_bit = (sequence_value <= input_value)

For the current N-bit non-zero sequence space 1 ... (2^N - 1):

    P(bit = 1) = input_value / (2^N - 1)

For stochastic scaled addition:

    P(out = 1) = (P(A = 1) + P(B = 1)) / 2

Decoded estimate:

    estimate = 2 * ones * (2^N - 1) / L

Here, L is the number of stochastic samples collected by the testbench.

## Parameterization

The main RTL modules are parameterized.

Default:

    N = 8

Examples:

    N = 4  -> sequence range 1 ... 15
    N = 8  -> sequence range 1 ... 255
    N = 10 -> sequence range 1 ... 1023

The current comparison testbenches evaluate:

    L = 16
    L = 32

L remains a testbench setting so the same RTL can be evaluated at different stream lengths.

For lfsr.v, provide an N-bit TAP_MASK and SEED explicitly when using N other than the default 8-bit configuration.

## Testbenches

- tb_binary_adder.v
- tb_lfsr_sng.v
- tb_sobol_sng.v
- tb_sc_adder_lfsr_L16.v
- tb_sc_adder_lfsr_L32.v
- tb_sc_adder_sobol_L16.v
- tb_sc_adder_sobol_L32.v

The stochastic-adder testbenches compare the decoded stochastic estimate with the exact binary sum and report absolute error.

## Vivado

### Binary synthesis

Top module:

    binary_adder

Design Sources:

    binary_adder.v

### LFSR stochastic synthesis

Top module:

    sc_adder_lfsr

Design Sources:

    lfsr.v
    lfsr_sng.v
    select_toggle.v
    mux2.v
    sc_adder_lfsr.v

### Sobol stochastic synthesis

Top module:

    sc_adder_sobol

Design Sources:

    sobol.v
    sobol_sng.v
    select_toggle.v
    mux2.v
    sc_adder_sobol.v

Testbenches are simulation sources only.

## Measurement note

Behavioral or inferred RTL does not automatically guarantee lower power or area after synthesis. For a fair Vivado comparison, keep the FPGA part, clock constraints, input width, synthesis settings, implementation settings, and switching assumptions consistent across designs.

Measure area and power after synthesis/implementation.

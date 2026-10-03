# Addition_Comparison_New

Simplified, modular, synthesizable RTL comparison of conventional binary addition, LFSR-based stochastic scaled addition, and Sobol-based stochastic scaled addition.

## Architecture

Binary:
- N-bit parameterized binary adder.

LFSR stochastic:
- Parameterized LFSR
- LFSR SNG = LFSR + comparator
- 50% toggle select
- 2:1 MUX for scaled addition
- Output probability estimated over L cycles

Sobol stochastic:
- Parameterized compact 1-D base-2 Sobol generator
- Sobol SNG = Sobol generator + comparator
- 50% toggle select
- 2:1 MUX for scaled addition
- Output probability estimated over L cycles

## Encoding convention

Both SNGs use:

  stochastic_bit = (sequence_value <= input_value)

The LFSR uses the non-zero N-bit sample space 1...(2^N-1). The current Sobol implementation produces a permutation of the same N-bit non-zero sample space for the architecture-level comparison.

For scaled stochastic addition:

  P(out=1) = (P(A=1)+P(B=1))/2

so the decoded estimate is:

  estimate = 2 * ones * (2^N-1) / L

The probability-estimator counter is a separate block. It counts 0...L, so its width is $clog2(L+1). This is different from the N-bit sequence/index generator.

## Parameterization

Default:
  N = 8

Examples:
  N=4  -> sequence space uses 1...15
  N=8  -> sequence space uses 1...255
  N=10 -> sequence space uses 1...1023

The current project comparisons use L=16 and L=32.

## Files

Core RTL:
- binary_adder.v
- lfsr.v
- lfsr_sng.v
- sobol.v
- sobol_sng.v
- select_toggle.v
- mux2.v
- stochastic_counter.v
- sc_adder_lfsr.v
- sc_adder_sobol.v

Separate testbenches:
- tb_binary_adder.v
- tb_lfsr_sng.v
- tb_sobol_sng.v
- tb_sc_adder_lfsr_L16.v
- tb_sc_adder_lfsr_L32.v
- tb_sc_adder_sobol_L16.v
- tb_sc_adder_sobol_L32.v

These RTL blocks intentionally use a mix of inferred hardware and explicit module boundaries. This keeps the code simple and synthesizable while making it easy to replace individual modules with structural versions later for gate-level comparison.

## Power note

Using behavioral/inferred RTL does not by itself guarantee lower power. Vivado may synthesize equivalent hardware. Power should be measured after synthesis/implementation. The main architectural levers for power are switching activity, SNG cost, sequence length L, generator sharing, and early termination.

# Binary vs LFSR-SC vs Sobol-SC Addition

This directory contains the controlled addition experiment for the stochastic-computing project.

## 1. Architecture

All three designs receive the same two unsigned N-bit binary operands A and B.

Binary:
- exact N-bit + N-bit addition
- N+1-bit result

LFSR-SC:
- A and B go through LFSR-based stochastic number generators
- a third LFSR generates the MUX select stream
- the arithmetic operation is a 2:1 MUX

Sobol-SC:
- A and B go through Sobol-based stochastic number generators
- a third Sobol source generates the MUX select stream
- the arithmetic operation is the same 2:1 MUX

Thus the two stochastic variants use the same binary inputs and the same arithmetic element; the sequence source is the controlled difference.

## 2. MUX-based stochastic addition

For unipolar stochastic streams:

    Y = A*S + B*(1-S)

with P(S=1)=0.5:

    E[Y] = (A+B)/2

The MUX therefore implements scaled addition. The testbench removes the factor-of-two scaling when decoding the L-bit stochastic stream.

This experiment intentionally avoids the OR-based stochastic adder.

## 3. SC output

The stochastic DUTs output one stochastic sum bit per cycle, plus busy/done and debug stream bits.

The testbench:
- drives the same A/B into all three DUTs;
- collects exactly L stochastic sum bits from LFSR-SC and Sobol-SC;
- counts the ones;
- decodes each estimate;
- compares both estimates with the exact binary sum.

The stochastic-to-binary decoder is intentionally kept in the testbench, not in the synthesized stochastic datapath. This avoids inserting a separate conversion circuit into the arithmetic-core area/power measurement.

## 4. Scaling

For N-bit unsigned inputs:

    MAX = 2^N - 1
    x = A / MAX
    y = B / MAX

The MUX produces the scaled value:

    (x+y)/2

If K ones are observed in L output bits:

    decoded_sum = 2*K*MAX/L

The exact binary result is:

    A+B

## 5. Parameters

Default:

    N = 8
    L = 32

L can be set to 16 or 32.

The arithmetic and sequence interfaces are parameterized by N. For N other than 8, provide a suitable N-bit LFSR TAP_MASK. The default 8-bit mask 10110010 corresponds to the project's P2 feedback taps [7,5,4,1].

The Sobol generator uses a parameterized 1-D base-2 direction-number construction.

## 6. Files

    binary_adder_parameterized.v
    sc_lfsr_parameterized.v
    sc_sng_lfsr_parameterized.v
    sc_adder_lfsr_parameterized.v
    sc_sobol_parameterized.v
    sc_sng_sobol_parameterized.v
    sc_adder_sobol_parameterized.v
    tb_addition_comparison.v

## 7. Vivado

Synthesis tops:

    binary_adder_parameterized
    sc_adder_lfsr_parameterized
    sc_adder_sobol_parameterized

Do not synthesize the testbench.

For fair comparison, keep N, L, FPGA part, clock constraint, synthesis settings, implementation settings and activity assumptions identical.

Measure at least:
- area/resources
- critical delay
- average power
- latency
- energy per completed addition

The binary adder is combinational while the stochastic designs require L cycles, so average power and energy per operation should be reported separately.

## 8. Relation to the existing project

The repository already contains the stochastic-computing fundamentals, exhaustive LFSR polynomial/seed investigation, separate L=16/L=32 stochastic multiplier RTL and Vivado results, and the structural 8x8 Booth multiplier.

This directory extends the same methodology from multiplication to addition while holding the A/B workload and MUX arithmetic structure constant.

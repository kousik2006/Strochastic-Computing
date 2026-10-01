# Structural Binary vs LFSR-SC vs Sobol-SC Addition

This directory is the controlled addition study for the stochastic-computing project.

## 1. Goal

The same two unsigned N-bit binary operands are applied to three designs:

1. Structural binary ripple-carry adder
2. Structural LFSR stochastic adder
3. Structural Sobol stochastic adder

The stochastic adders use the same MUX-based arithmetic. The sequence generator is the main architectural difference.

## 2. Minimal top-level ports

Binary:

    input  A[N-1:0]
    input  B[N-1:0]
    output Sum[N:0]

LFSR-SC:

    input  clk
    input  reset
    input  A[N-1:0]
    input  B[N-1:0]
    output sum_bit

Sobol-SC:

    input  clk
    input  reset
    input  A[N-1:0]
    input  B[N-1:0]
    output sum_bit

There is deliberately no start, busy, done, random_value, stochastic_A, stochastic_B or select output port. Those signals are internal to the stochastic datapath. This keeps the top-level interface small and avoids unnecessary observable switching.

The binary adder does not have a clock or reset because adding those ports would add hardware or switching without being part of the combinational addition being measured.

## 3. Structural hierarchy

Binary path:

    A/B -> N x full_adder_structural -> Sum

LFSR stochastic path:

    A -> LFSR SNG -> comparator -> stochastic A --+
                                                    |
    B -> LFSR SNG -> comparator -> stochastic B --+-> 2:1 MUX -> sum_bit
                                                    |
                 LFSR -> select bit ---------------+

Sobol stochastic path:

    A -> Sobol SNG -> comparator -> stochastic A --+
                                                    |
    B -> Sobol SNG -> comparator -> stochastic B --+-> 2:1 MUX -> sum_bit
                                                    |
                 Sobol -> select bit --------------+

The reusable structural blocks are:

    full_adder_structural.v
    dff_structural.v
    xor_reduce_structural.v
    comparator_structural.v
    counter_structural.v
    lfsr_structural.v
    sobol_structural.v
    mux2_structural.v
    sng_lfsr_structural.v
    sng_sobol_structural.v

Top-level arithmetic cores:

    binary_adder_parameterized.v
    sc_adder_lfsr_structural.v
    sc_adder_sobol_structural.v

Testbench:

    tb_addition_comparison.v

## 4. MUX stochastic addition

The stochastic arithmetic element is a 2:1 MUX:

    Y = A*S + B*(1-S)

with a select stream whose probability is approximately 0.5.

Therefore:

    E[Y] = (A+B)/2

The testbench removes this factor-of-two scaling when it decodes the stochastic stream.

This study intentionally does not use the OR-based stochastic adder.

## 5. N-bit encoding

The SNGs use unipolar encoding:

    P(bit=1) = value / 2^N

The comparator therefore generates a 1 when the generated N-bit sequence value is less than the N-bit input value.

For L stochastic output bits and K ones:

    decoded_sum = 2*K*2^N/L

The exact reference is:

    binary_sum = A+B

The testbench reports the decoded LFSR and Sobol estimates and their errors.

## 6. Parameter N

The arithmetic and sequence hardware is parameterized by N.

Default:

    N = 8
    L = 32 in the testbench

To study another input width, change only the testbench parameter N and use valid test vectors for that width.

For the LFSR, a suitable N-bit primitive-polynomial TAP_MASK should be selected. The default 8-bit mask is the project's P2 feedback mask:

    10110010

The Sobol implementation is a structural 1-D base-2 sequence using a binary counter, Gray-code XOR network and bit reversal.

## 7. Why no stochastic-to-binary converter is inside the DUT?

The stochastic arithmetic core naturally produces one bit per clock. A binary accumulator/decoder would add registers, adders and switching to the synthesized stochastic arithmetic core.

Therefore the testbench performs the L-bit accumulation and decoding. This lets the area/power experiment focus on the actual stochastic arithmetic datapath.

A separate system-level experiment can later include the stochastic-to-binary converter if required.

## 8. Vivado comparison

Use these three synthesis tops:

    binary_adder_parameterized
    sc_adder_lfsr_structural
    sc_adder_sobol_structural

Do not synthesize the testbench.

Keep the following identical whenever possible:

    N
    FPGA part
    clock constraint
    synthesis settings
    implementation settings
    power-analysis assumptions

Record:

    LUTs
    FFs
    other resources
    critical path delay
    power
    latency
    energy per completed operation

The binary adder is combinational. The stochastic adders require L cycles to produce an L-bit stochastic result, so power and energy/operation must be interpreted together with latency.

## 9. Important fairness point

The top-level binary adder has no clock because it is a combinational reference. The stochastic designs necessarily require a clock because their LFSR/Sobol state advances every cycle.

Do not add unused clock, start, done or debug ports to the binary reference merely to make the port lists visually identical. The important common workload is the same A and B operands.

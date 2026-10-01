# Binary vs Stochastic Addition

This directory adds a controlled addition study to the stochastic-computing project.

## Common input
All three implementations accept the same two unsigned N-bit operands:
- A[N-1:0]
- B[N-1:0]

N is a parameter and can be changed later.

## Implementations
1. `binary_adder_parameterized.v`
   - Exact N-bit binary addition.
   - Output is N+1 bits.

2. `sc_adder_lfsr_parameterized.v`
   - Unipolar stochastic addition using mux scaling:
     y = mux(S, A_stream, B_stream), with P(S=1)=0.5.
   - Two LFSR-based SNGs encode A and B.
   - A third LFSR generates the 0.5 select stream.
   - The stochastic output is decoded by counting ones and scaling by 2.
   - The core mux is the stochastic arithmetic element; no OR-gate adder is used.

3. `sc_adder_sobol_parameterized.v`
   - Same mux-based arithmetic interface.
   - A deterministic low-discrepancy Sobol-style sequence is used as the sample source instead of the LFSR RNS.
   - A/B are encoded from the same binary inputs.
   - The select stream is generated with the same sequence family and 0.5 threshold.

## Fair comparison
For synthesis, compare only the DUT top module for each implementation. Use:
- identical FPGA part
- identical clock constraint
- identical synthesis/implementation settings
- identical N
- identical test vectors
- identical stochastic stream length L
- identical input activity assumptions

The stochastic designs include their SNG/conversion logic because the study is intended to measure internal hardware cost, not only the mux itself.

## Output interpretation
Binary:
  binary_sum = A + B

Stochastic:
  sum_estimate ~= 2 * P(Y=1) * 255
for the N-bit normalization X/(2^N-1).

Because the true stochastic sum of two arbitrary normalized values can exceed 1, the mux computes the conventional scaled addition:
  y = (x + z)/2
and the decoded result is multiplied by 2. This keeps the stochastic stream probability in [0,1].
